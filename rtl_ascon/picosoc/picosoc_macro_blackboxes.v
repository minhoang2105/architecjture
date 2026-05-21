// SPDX-FileCopyrightText: 2026 Nguyen Vo
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

(* blackbox *)
module picorv32 (
    input clk,
    input resetn,
    input vccd1,
    input vssd1,

    output mem_valid,
    output mem_instr,
    output mem_la_read,
    output mem_la_write,
    input mem_ready,

    output [31:0] mem_addr,
    output [31:0] mem_la_addr,
    output [31:0] mem_wdata,
    output [31:0] mem_la_wdata,
    output [3:0] mem_wstrb,
    output [3:0] mem_la_wstrb,
    input [31:0] mem_rdata,

    output trap,
    output trace_valid,
    output pcpi_valid,
    input pcpi_ready,
    input pcpi_wait,
    input pcpi_wr,

    input [31:0] irq,
    output [31:0] eoi,
    output [31:0] pcpi_insn,
    input [31:0] pcpi_rd,
    output [31:0] pcpi_rs1,
    output [31:0] pcpi_rs2,
    output [35:0] trace_data
);
endmodule

(* blackbox *)
module mem_decode (
    input clk,
    input vccd1,
    input vssd1,

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
endmodule

(* blackbox *)
module spimemio (
    input VPWR,
    input VGND,
    input clk,
    input resetn,

    input valid,
    output ready,
    input [23:0] addr,
    output [31:0] rdata,

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
    input flash_io3_di,

    input [3:0] cfgreg_we,
    input [31:0] cfgreg_di,
    output [31:0] cfgreg_do
);
endmodule

(* blackbox *)
module simpleuart (
    input VPWR,
    input VGND,
    input clk,
    input resetn,

    output ser_tx,
    input ser_rx,

    input [3:0] reg_div_we,
    input [31:0] reg_div_di,
    output [31:0] reg_div_do,

    input reg_dat_we,
    input reg_dat_re,
    input [31:0] reg_dat_di,
    output [31:0] reg_dat_do,
    output reg_dat_wait
);
endmodule

(* blackbox *)
module picosoc_mem (
    input clk,
    input vccd1,
    input vssd1,
    input [3:0] wen,
    input [21:0] addr,
    input [31:0] wdata,
    output [31:0] rdata
);
endmodule

(* blackbox *)
module ascon_mmio (
    input vccd1,
    input vssd1,
    input clk,
    input resetn,
    input reg_sel,
    input [3:0] reg_we,
    input [5:0] reg_addr,
    input [31:0] reg_wdata,
    output [31:0] reg_rdata
);
endmodule

`default_nettype wire
