`timescale 1ns / 1ps

// ============================================================================
// Module: real_uart_mmio
// Mô tả: Một khối UART thực sự (Synthesizable) có thể chạy trên FPGA/ASIC.
// Bao gồm:
// - TX: Thanh ghi dịch để truyền từng bit ra chân uart_tx.
// - RX: Máy trạng thái dò bit start và lấy mẫu dữ liệu từ chân uart_rx.
// - MMIO: Giao tiếp Memory-Mapped IO 32-bit.
// ============================================================================
module real_uart_mmio #(
    // Thông số mặc định (ví dụ clk 50MHz, Baud 115200)
    // Tần số Clock chia cho Baud Rate: 50,000,000 / 115200 ≈ 434
    parameter CLK_DIV = 434 
) (
    input  wire        clk,
    input  wire        resetn,
    input  wire        valid,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [3:0]  wstrb,
    output wire        ready,
    output reg  [31:0] rdata,
    
    output reg         uart_tx,
    input  wire        uart_rx
);

    // ------------------------------------------------------------------------
    // Tín hiệu giải mã Bus (Bus Decoding)
    // ------------------------------------------------------------------------
    wire wr_en = valid && (|wstrb);
    wire rd_en = valid && !(|wstrb);
    wire [3:0] reg_word = addr[5:2];

    assign ready = valid; // Mặc định đáp ứng ngay lập tức (1 chu kỳ)

    // ------------------------------------------------------------------------
    // Mạch phát (TX Logic)
    // ------------------------------------------------------------------------
    reg [31:0] tx_clk_cnt;
    reg [3:0]  tx_bit_cnt;
    reg [9:0]  tx_shift_reg; // 1 bit Start (0), 8 bit Data, 1 bit Stop (1)
    reg        tx_busy;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tx_clk_cnt   <= 0;
            tx_bit_cnt   <= 0;
            tx_shift_reg <= 10'h3FF; // Tất cả là 1 (Idle)
            tx_busy      <= 1'b0;
            uart_tx      <= 1'b1;
        end else begin
            if (tx_busy) begin
                // Đang truyền dữ liệu
                if (tx_clk_cnt == CLK_DIV - 1) begin
                    tx_clk_cnt <= 0;
                    uart_tx    <= tx_shift_reg[0]; // Đẩy bit thấp nhất ra chân TX
                    tx_shift_reg <= {1'b1, tx_shift_reg[9:1]}; // Dịch phải
                    
                    if (tx_bit_cnt == 9) begin
                        tx_busy <= 1'b0; // Đã truyền xong 10 bit (Start + 8 Data + Stop)
                    end else begin
                        tx_bit_cnt <= tx_bit_cnt + 1;
                    end
                end else begin
                    tx_clk_cnt <= tx_clk_cnt + 1;
                end
            end else begin
                // Trạng thái nghỉ (Idle)
                uart_tx <= 1'b1;
                // Nếu CPU ra lệnh Ghi vào địa chỉ 0x0
                if (wr_en && reg_word == 4'h0) begin
                    tx_shift_reg <= {1'b1, wdata[7:0], 1'b0}; // Stop(1), Data(8), Start(0)
                    tx_clk_cnt   <= 0;
                    tx_bit_cnt   <= 0;
                    tx_busy      <= 1'b1;
                end
            end
        end
    end

    // ------------------------------------------------------------------------
    // Mạch nhận (RX Logic)
    // Lấy mẫu (Sample) ở giữa chu kỳ baud để đảm bảo độ chính xác
    // ------------------------------------------------------------------------
    reg [31:0] rx_clk_cnt;
    reg [3:0]  rx_bit_cnt;
    reg [7:0]  rx_data_reg;
    reg        rx_busy;
    reg        rx_valid_flag; // Cờ báo hiệu có dữ liệu mới

    // Synchronizer để chống Metastability cho chân uart_rx
    reg rx_sync_1, rx_sync_2;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) {rx_sync_2, rx_sync_1} <= 2'b11;
        else         {rx_sync_2, rx_sync_1} <= {rx_sync_1, uart_rx};
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rx_clk_cnt    <= 0;
            rx_bit_cnt    <= 0;
            rx_data_reg   <= 8'h00;
            rx_busy       <= 1'b0;
            rx_valid_flag <= 1'b0;
        end else begin
            // Xóa cờ valid khi CPU đọc thanh ghi RX (địa chỉ 0x8)
            if (rd_en && reg_word == 4'h2) begin
                rx_valid_flag <= 1'b0; 
            end

            if (rx_busy) begin
                if (rx_clk_cnt == CLK_DIV - 1) begin
                    rx_clk_cnt <= 0;
                    if (rx_bit_cnt == 8) begin
                        // Bit Stop
                        rx_busy <= 1'b0;
                        rx_valid_flag <= 1'b1; // Kích hoạt cờ đã nhận xong byte
                    end else begin
                        // Lấy mẫu 8 bit Data
                        rx_data_reg <= {rx_sync_2, rx_data_reg[7:1]};
                        rx_bit_cnt  <= rx_bit_cnt + 1;
                    end
                end else begin
                    rx_clk_cnt <= rx_clk_cnt + 1;
                end
            end else begin
                // Dò tìm sườn xuống của bit Start
                if (rx_sync_2 == 1'b0) begin
                    // Phát hiện Start bit, đếm nửa chu kỳ để lấy mẫu ở chính giữa bit
                    if (rx_clk_cnt == (CLK_DIV / 2) - 1) begin
                        if (rx_sync_2 == 1'b0) begin // Kiểm tra lại chắc chắn là Start bit
                            rx_clk_cnt <= 0;
                            rx_bit_cnt <= 0;
                            rx_busy    <= 1'b1;
                        end else begin
                            rx_clk_cnt <= 0; // Nhiễu (Glitch), bỏ qua
                        end
                    end else begin
                        rx_clk_cnt <= rx_clk_cnt + 1;
                    end
                end else begin
                    rx_clk_cnt <= 0;
                end
            end
        end
    end

    // ------------------------------------------------------------------------
    // Trả về dữ liệu cho CPU (Read Logic)
    // ------------------------------------------------------------------------
    always @(*) begin
        rdata = 32'h0000_0000;
        if (rd_en) begin
            case (reg_word)
                // 0x0: Đọc không có ý nghĩa nhiều, ta trả về 0
                4'h0: rdata = 32'h0000_0000; 
                // 0x4: Trạng thái TX (1 = sẵn sàng truyền, 0 = đang bận)
                4'h1: rdata = {31'h0, !tx_busy};
                // 0x8: Dữ liệu RX. 
                // bit [7:0] là byte nhận được. bit [31] là cờ valid báo có dữ liệu mới
                4'h2: rdata = {rx_valid_flag, 23'h0, rx_data_reg};
                default: rdata = 32'h0000_0000;
            endcase
        end
    end

endmodule