// SPDX-FileCopyrightText: 2026 Nguyen Vo
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module picosoc_macro_top (
    inout vccd1,
    inout vssd1,

    input clk,
    input resetn,

    output iomem_valid,
    input iomem_ready,
    output [3:0] iomem_wstrb,
    output [31:0] iomem_addr,
    output [31:0] iomem_wdata,
    input [31:0] iomem_rdata,

    input irq_5,
    input irq_6,
    input irq_7,

    output ser_tx,
    input ser_rx,

    output flash_csb,
    output flash_clk,

    output flash_io0_oe,
    output flash_io1_oe,
    output flash_io2_oe,
    output flash_io3_oe,

    output flash_io0_do,
    output flash_io1_do,
    output flash_io2_do,
    output flash_io3_do,

    input flash_io0_di,
    input flash_io1_di,
    input flash_io2_di,
    input flash_io3_di
);

    localparam [31:0] STACKADDR = 32'd1024;
    localparam [31:0] PROGADDR_RESET = 32'h0010_0000;
    localparam [31:0] PROGADDR_IRQ = 32'h0000_0000;

    wire mem_valid;
    wire mem_instr;
    wire mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0] mem_wstrb;
    wire [31:0] mem_rdata;
    wire mem_valid_for_decode;
    wire mem_ready_from_decode;
    wire [31:0] mem_rdata_from_decode;

    wire ascon_reg_sel;
    wire [31:0] ascon_reg_rdata;

    wire spimem_ready;
    wire [31:0] spimem_rdata;
    wire [31:0] ram_rdata;

    wire spimemio_cfgreg_sel;
    wire [31:0] spimemio_cfgreg_do;

    wire simpleuart_reg_div_sel;
    wire [31:0] simpleuart_reg_div_do;

    wire simpleuart_reg_dat_sel;
    wire [31:0] simpleuart_reg_dat_do;
    wire simpleuart_reg_dat_wait;

    wire extra_spimemio_valid;
    wire [3:0] extra_spimemio_cfgreg_we;
    wire [3:0] extra_simpleuart_reg_div_we;
    wire extra_simpleuart_reg_dat_we;
    wire extra_simpleuart_reg_dat_re;
    wire [3:0] extra_picosoc_mem_wen;

    wire [31:0] irq;

    // Reserve 0x0200_0100 - 0x0200_01FF for ASCON MMIO registers.
    assign ascon_reg_sel = mem_valid && (mem_addr[31:8] == 24'h0200_01);
    assign mem_valid_for_decode = mem_valid && !ascon_reg_sel;
    assign mem_ready = ascon_reg_sel ? 1'b1 : mem_ready_from_decode;
    assign mem_rdata = ascon_reg_sel ? ascon_reg_rdata : mem_rdata_from_decode;

    picorv32 u_cpu (
        .clk(clk),
        .resetn(resetn),
        .vccd1(vccd1),
        .vssd1(vssd1),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .irq(irq)
    );

    mem_decode u_mem_decode (
        .clk(clk),
        .vccd1(vccd1),
        .vssd1(vssd1),
        .mem_valid(mem_valid_for_decode),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .spimem_ready(spimem_ready),
        .spimem_rdata(spimem_rdata),
        .ram_rdata(ram_rdata),
        .iomem_valid(iomem_valid),
        .iomem_ready(iomem_ready),
        .iomem_wstrb(iomem_wstrb),
        .iomem_addr(iomem_addr),
        .iomem_wdata(iomem_wdata),
        .iomem_rdata(iomem_rdata),
        .spimemio_cfgreg_sel(spimemio_cfgreg_sel),
        .spimemio_cfgreg_do(spimemio_cfgreg_do),
        .simpleuart_reg_div_sel(simpleuart_reg_div_sel),
        .simpleuart_reg_div_do(simpleuart_reg_div_do),
        .simpleuart_reg_dat_sel(simpleuart_reg_dat_sel),
        .simpleuart_reg_dat_do(simpleuart_reg_dat_do),
        .simpleuart_reg_dat_wait(simpleuart_reg_dat_wait),
        .irq_5(irq_5),
        .irq_6(irq_6),
        .irq_7(irq_7),
        .irq(irq),
        .mem_ready(mem_ready_from_decode),
        .mem_rdata(mem_rdata_from_decode),
        .extra_spimemio_valid(extra_spimemio_valid),
        .extra_spimemio_cfgreg_we(extra_spimemio_cfgreg_we),
        .extra_simpleuart_reg_div_we(extra_simpleuart_reg_div_we),
        .extra_simpleuart_reg_dat_we(extra_simpleuart_reg_dat_we),
        .extra_simpleuart_reg_dat_re(extra_simpleuart_reg_dat_re),
        .extra_picosoc_mem_wen(extra_picosoc_mem_wen)
    );

    ascon_mmio u_ascon_mmio (
        .vccd1(vccd1),
        .vssd1(vssd1),
        .clk(clk),
        .resetn(resetn),
        .reg_sel(ascon_reg_sel),
        .reg_we(mem_wstrb),
        .reg_addr(mem_addr[7:2]),
        .reg_wdata(mem_wdata),
        .reg_rdata(ascon_reg_rdata)
    );

    spimemio u_spimemio (
        .VPWR(vccd1),
        .VGND(vssd1),
        .clk(clk),
        .resetn(resetn),
        .valid(extra_spimemio_valid),
        .ready(spimem_ready),
        .addr(mem_addr[23:0]),
        .rdata(spimem_rdata),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0_oe(flash_io0_oe),
        .flash_io1_oe(flash_io1_oe),
        .flash_io2_oe(flash_io2_oe),
        .flash_io3_oe(flash_io3_oe),
        .flash_io0_do(flash_io0_do),
        .flash_io1_do(flash_io1_do),
        .flash_io2_do(flash_io2_do),
        .flash_io3_do(flash_io3_do),
        .flash_io0_di(flash_io0_di),
        .flash_io1_di(flash_io1_di),
        .flash_io2_di(flash_io2_di),
        .flash_io3_di(flash_io3_di),
        .cfgreg_we(extra_spimemio_cfgreg_we),
        .cfgreg_di(mem_wdata),
        .cfgreg_do(spimemio_cfgreg_do)
    );

    simpleuart u_simpleuart (
        .VPWR(vccd1),
        .VGND(vssd1),
        .clk(clk),
        .resetn(resetn),
        .ser_tx(ser_tx),
        .ser_rx(ser_rx),
        .reg_div_we(extra_simpleuart_reg_div_we),
        .reg_div_di(mem_wdata),
        .reg_div_do(simpleuart_reg_div_do),
        .reg_dat_we(extra_simpleuart_reg_dat_we),
        .reg_dat_re(extra_simpleuart_reg_dat_re),
        .reg_dat_di(mem_wdata),
        .reg_dat_do(simpleuart_reg_dat_do),
        .reg_dat_wait(simpleuart_reg_dat_wait)
    );

    picosoc_mem u_picosoc_mem (
        .clk(clk),
        .vccd1(vccd1),
        .vssd1(vssd1),
        .wen(extra_picosoc_mem_wen),
        .addr(mem_addr[23:2]),
        .wdata(mem_wdata),
        .rdata(ram_rdata)
    );

endmodule

`default_nettype wire
