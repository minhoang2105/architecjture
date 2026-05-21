`timescale 1ns/1ps

module tb_real_uart;
    reg clk;
    reg resetn;
    reg valid;
    reg [31:0] addr;
    reg [31:0] wdata;
    reg [3:0] wstrb;
    wire ready;
    wire [31:0] rdata;
    
    wire uart_tx;
    wire uart_rx;

    // -----------------------------------------------------------
    // Kỹ thuật Loopback: Nối thẳng ngõ ra TX vào ngõ vào RX
    // Để UART tự phát và tự nhận, test luôn 2 khối cùng lúc!
    // -----------------------------------------------------------
    assign uart_rx = uart_tx;

    // Cấu hình CLK_DIV nhỏ đi rất nhiều để mô phỏng chạy nhanh hơn.
    // Thực tế có thể là 434, nhưng trong mô phỏng (simulation) 
    // ta để là 4 để không phải chờ hàng triệu chu kỳ clock.
    localparam SIM_CLK_DIV = 4;

    // Khởi tạo module UART thực tế
    real_uart_mmio #(
        .CLK_DIV(SIM_CLK_DIV)
    ) u_uart (
        .clk(clk),
        .resetn(resetn),
        .valid(valid),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .ready(ready),
        .rdata(rdata),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx)
    );

    // Tạo xung nhịp 100MHz (Chu kỳ 10ns)
    always #5 clk = ~clk;

    // Task giao dịch Ghi
    task bus_write;
        input [31:0] wr_addr;
        input [31:0] wr_data;
        begin
            valid = 1'b1;
            addr = wr_addr;
            wdata = wr_data;
            wstrb = 4'hF;
            @(posedge clk);
            valid = 1'b0;
            wstrb = 4'h0;
            @(posedge clk);
        end
    endtask

    // Task giao dịch Đọc
    task bus_read;
        input [31:0] rd_addr;
        output [31:0] rd_data;
        begin
            valid = 1'b1;
            addr = rd_addr;
            wstrb = 4'h0;
            @(posedge clk);
            rd_data = rdata;
            valid = 1'b0;
            wstrb = 4'h0;
            @(posedge clk);
        end
    endtask

    // Task mô phỏng CPU chờ đợi TX rảnh (Polling)
    // CPU sẽ liên tục đọc địa chỉ 0x2000_0004 cho đến khi bít [0] = 1
    task wait_tx_ready;
        reg [31:0] status;
        begin
            status = 0;
            while (status[0] == 1'b0) begin
                bus_read(32'h2000_0004, status);
            end
        end
    endtask

    reg [31:0] rd;

    initial begin
        // Khởi tạo ban đầu
        clk = 1'b0;
        resetn = 1'b0;
        valid = 1'b0;
        addr = 32'h0;
        wdata = 32'h0;
        wstrb = 4'h0;

        // Lưu sóng ra file VCD
        $dumpfile("results/phase3/tb_real_uart.vcd");
        $dumpvars(0, tb_real_uart);

        // Chạy reset 10 chu kỳ
        repeat (10) @(posedge clk);
        resetn = 1'b1;
        repeat (10) @(posedge clk);

        $display("========================================");
        $display(" BAT DAU TEST MODULE UART THUC TE");
        $display("========================================");

        // 1. Ghi ký tự 'A' (0x41)
        $display("1. CPU Gui ky tu 'A' (0x41) vao TX");
        bus_write(32'h2000_0000, 32'h0000_0041);
        
        // 2. Chờ khối phần cứng dịch và truyền xong (polling)
        $display("2. CPU dang lap (polling) cho UART ranh...");
        wait_tx_ready();
        $display("   -> UART TX da truyen xong!");

        // 3. Đợi thêm 1 vài clock cho bộ nhận RX chốt dữ liệu
        // Do mạch RX lấy mẫu giữa chu kỳ, nó sẽ kết thúc trễ hơn TX 1 chút xíu
        repeat (SIM_CLK_DIV * 2) @(posedge clk);

        // 4. CPU đọc thanh ghi RX để lấy dữ liệu
        bus_read(32'h2000_0008, rd);
        $display("3. CPU doc thanh ghi RX. Du lieu tho tra ve: 0x%08x", rd);
        
        // Kiểm tra bit 31 (rx_valid) và bit [7:0] (data)
        if (rd[31] !== 1'b1) begin
            $display("[FAIL] Co rx_valid chua duoc bat! RX khong nhan duoc gi.");
        end else if (rd[7:0] !== 8'h41) begin
            $display("[FAIL] Du lieu RX sai. Mong doi: 0x41, Nhan duoc: 0x%02x", rd[7:0]);
        end else begin
            $display("[PASS] TEST 1 OK! Phat (TX) va Nhan (RX) thanh cong ky tu 'A'.");
        end

        // 5. Gửi tiếp ký tự 'Z' (0x5A) để chắc chắn mọi thứ hoạt động liên tục
        $display("\n4. CPU Gui tiep ky tu 'Z' (0x5A) vao TX");
        bus_write(32'h2000_0000, 32'h0000_005A);
        wait_tx_ready();
        repeat (SIM_CLK_DIV * 2) @(posedge clk);
        
        bus_read(32'h2000_0008, rd);
        if (rd[7:0] === 8'h5A) begin
            $display("[PASS] TEST 2 OK! Nhan thanh cong ky tu 'Z'.");
        end else begin
            $display("[FAIL] Loi khi nhan ky tu thu 2.");
        end

        $display("========================================");
        $display(" KET THUC TEST");
        $display("========================================");
        
        // Chạy dư ra 10 chu kỳ cho waveform đẹp rồi tắt
        repeat (10) @(posedge clk);
        $finish;
    end
endmodule