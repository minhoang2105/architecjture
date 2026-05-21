/// sta-blackbox
module soc_ram (
    input  wire        clk,
    input  wire        resetn,
    input  wire        valid,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    input  wire [3:0]  wstrb,
    output wire        ready,
    output wire [31:0] rdata
);

    // Chuyển parameter thành localparam để cố định cấu hình cho Hard Macro (ASIC)
    localparam ADDR_WIDTH = 14;
    localparam INIT_ZERO  = 1;

    // If USE_OPENRAM is defined, treat this module as a wrapper
    // so the OpenRAM-generated macro can be linked in during P&R.
`ifdef USE_OPENRAM
    // Instantiate the actual OpenRAM macro cell (output_name = soc_ram_2kb)
    soc_ram_2kb u_macro (
        .clk0(clk),
        .csb0(~valid),
        .web0(~(|wstrb)),
        .wmask0(wstrb),
        .addr0(addr[ADDR_WIDTH-1:0]),
        .din0(wdata),
        .dout0(rdata)
    );
    assign ready = valid;
`else
    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [31:0] mem [0:DEPTH-1];

    wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];

    // Inferred SRAM model for academic/project use.
    // Interface is kept macro-friendly for later ASIC memory replacement.
    assign ready = valid;
    assign rdata = mem[word_addr];

    always @(posedge clk) begin
        if (valid && |wstrb) begin
            if (wstrb[0]) mem[word_addr][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[word_addr][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[word_addr][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[word_addr][31:24] <= wdata[31:24];
        end
    end

    // NOTE:
    // Do not clear full RAM on reset in synthesizable logic.
    // Large reset loops are not representative of SRAM macro behavior.
    // Optional initialization below is for simulation convenience only.
    integer i;
    initial begin
        if (INIT_ZERO) begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] = 32'h0000_0000;
        end
    end

    // Keep reset pin for interface compatibility with future SRAM macro wrappers.
    wire _unused_resetn = resetn;
`endif
endmodule