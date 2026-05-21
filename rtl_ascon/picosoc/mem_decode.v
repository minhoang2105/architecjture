module mem_decode #(
    parameter integer MEM_WORDS = 256
) (
    input clk,

    input mem_valid,
    input [31:0] mem_addr,
    input [31:0] mem_wdata,
    input [3:0] mem_wstrb,

    input spimem_ready,
    input [31:0] spimem_rdata,

    input [31:0] ram_rdata,

    output iomem_valid,
    input iomem_ready,
    output [3:0] iomem_wstrb,
    output [31:0] iomem_addr,
    output [31:0] iomem_wdata,
    input [31:0] iomem_rdata,

    output spimemio_cfgreg_sel,
    input [31:0] spimemio_cfgreg_do,

    output simpleuart_reg_div_sel,
    input [31:0] simpleuart_reg_div_do,

    output simpleuart_reg_dat_sel,
    input [31:0] simpleuart_reg_dat_do,
    input simpleuart_reg_dat_wait,

    input irq_5,
    input irq_6,
    input irq_7,
    output [31:0] irq,

    output mem_ready,
    output [31:0] mem_rdata,

    output extra_spimemio_valid,
    output [3:0] extra_spimemio_cfgreg_we,
    output [3:0] extra_simpleuart_reg_div_we,
    output extra_simpleuart_reg_dat_we,
    output extra_simpleuart_reg_dat_re,
    output [3:0] extra_picosoc_mem_wen
);

    reg ram_ready;

    assign iomem_valid = mem_valid && (mem_addr[31:24] > 8'h01);
    assign iomem_wstrb = mem_wstrb;
    assign iomem_addr = mem_addr;
    assign iomem_wdata = mem_wdata;

    assign spimemio_cfgreg_sel = mem_valid && (mem_addr == 32'h0200_0000);
    assign simpleuart_reg_div_sel = mem_valid && (mem_addr == 32'h0200_0004);
    assign simpleuart_reg_dat_sel = mem_valid && (mem_addr == 32'h0200_0008);

    assign mem_ready = (iomem_valid && iomem_ready) || spimem_ready || ram_ready || spimemio_cfgreg_sel ||
        simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait);

    assign mem_rdata = (iomem_valid && iomem_ready) ? iomem_rdata :
        spimem_ready ? spimem_rdata :
        ram_ready ? ram_rdata :
        spimemio_cfgreg_sel ? spimemio_cfgreg_do :
        simpleuart_reg_div_sel ? simpleuart_reg_div_do :
        simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 32'h0000_0000;

    always @(posedge clk)
        ram_ready <= mem_valid && !mem_ready && mem_addr < (4 * MEM_WORDS);

    assign extra_spimemio_valid = mem_valid && mem_addr >= (4 * MEM_WORDS) && mem_addr < 32'h0200_0000;
    assign extra_spimemio_cfgreg_we = spimemio_cfgreg_sel ? mem_wstrb : 4'b0000;
    assign extra_simpleuart_reg_div_we = simpleuart_reg_div_sel ? mem_wstrb : 4'b0000;
    assign extra_simpleuart_reg_dat_we = simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b0;
    assign extra_simpleuart_reg_dat_re = simpleuart_reg_dat_sel && !mem_wstrb;
    assign extra_picosoc_mem_wen = (mem_valid && !mem_ready && mem_addr < (4 * MEM_WORDS)) ? mem_wstrb : 4'b0000;

    assign irq = {24'h000000, irq_7, irq_6, irq_5, 5'b00000};

endmodule
