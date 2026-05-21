/// sta-blackbox
module soc_rom (
    input  wire        clk,
    input  wire        valid,
    input  wire [31:0] addr,
    output wire        ready,
    output wire [31:0] rdata
);

    // Chuyển parameter thành localparam để cố định cấu hình cho Hard Macro (ASIC)
    localparam MEMFILE    = "";
    localparam ADDR_WIDTH = 14;
    localparam INIT_NOP   = 1;

    // If USE_OPENRAM is defined, treat this module as a wrapper
    // so the OpenRAM-generated macro can be linked in during P&R.
`ifdef USE_OPENRAM
    // Instantiate the actual OpenRAM macro cell (output_name = soc_rom_2kb)
    // ROM is generally single port SRAM tied to read-only logic
    soc_rom_2kb u_macro (
        .clk0(clk),
        .csb0(~valid),
        .web0(1'b1), // Never write (Tie high)
        .wmask0(4'b0000), // No write mask
        .addr0(addr[ADDR_WIDTH-1:0]),
        .din0(32'h0),
        .dout0(rdata)
    );
    assign ready = valid;
`else
    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [31:0] mem [0:DEPTH-1];

    wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];

    assign ready = valid;
    
    // Inferred ROM model (synchronous read to match ASIC macro behavior realistically, 
    // although originally combinational, ASIC memories need clk)
    reg [31:0] rdata_reg;
    always @(posedge clk) begin
        if (valid) rdata_reg <= mem[word_addr];
    end
    assign rdata = rdata_reg;

    // Inferred ROM model for academic/project use.
    // This wrapper can be replaced by a foundry ROM macro in ASIC flow.
    integer i;
    initial begin
        if (INIT_NOP) begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] = 32'h0000_0013; // NOP (addi x0, x0, 0)
        end

        if (MEMFILE != "")
            $readmemh(MEMFILE, mem);
    end
`endif
endmodule