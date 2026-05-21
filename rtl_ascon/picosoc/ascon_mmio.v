`default_nettype none
module ascon_mmio (
	vccd1,
	vssd1,
	clk,
	resetn,
	reg_sel,
	reg_we,
	reg_addr,
	reg_wdata,
	reg_rdata
);
	reg _sv2v_0;
	input wire vccd1;
	input wire vssd1;
	input wire clk;
	input wire resetn;
	input wire reg_sel;
	input wire [3:0] reg_we;
	input wire [5:0] reg_addr;
	input wire [31:0] reg_wdata;
	output reg [31:0] reg_rdata;
	reg [63:0] key_reg;
	reg [63:0] bdi_reg;
	reg [7:0] bdi_valid_reg;
	reg [3:0] mode_reg;
	reg [3:0] bdi_type_reg;
	reg bdi_eot_reg;
	reg bdi_eoi_reg;
	reg bdo_eoo_reg;
	reg pulse_core_rst;
	reg pulse_key_valid;
	reg pulse_bdi_push;
	reg pulse_bdo_ready;
	wire [63:0] bdo;
	wire bdo_valid;
	wire [3:0] bdo_type;
	wire bdo_eot;
	wire auth;
	wire auth_valid;
	wire key_ready;
	wire bdi_ready;
	wire core_rst;
	wire [7:0] bdi_valid_pulse;
	assign core_rst = !resetn || pulse_core_rst;
	assign bdi_valid_pulse = (pulse_bdi_push ? bdi_valid_reg : 8'h00);
	always @(posedge clk or negedge resetn)
		if (!resetn) begin
			key_reg <= 64'h0000000000000000;
			bdi_reg <= 64'h0000000000000000;
			bdi_valid_reg <= 8'h00;
			mode_reg <= 4'h0;
			bdi_type_reg <= 4'h0;
			bdi_eot_reg <= 1'b0;
			bdi_eoi_reg <= 1'b0;
			bdo_eoo_reg <= 1'b0;
			pulse_core_rst <= 1'b0;
			pulse_key_valid <= 1'b0;
			pulse_bdi_push <= 1'b0;
			pulse_bdo_ready <= 1'b0;
		end
		else begin
			pulse_core_rst <= 1'b0;
			pulse_key_valid <= 1'b0;
			pulse_bdi_push <= 1'b0;
			pulse_bdo_ready <= 1'b0;
			if (reg_sel && (reg_we != 4'b0000))
				(* full_case, parallel_case *)
				case (reg_addr)
					6'h00: begin
						pulse_core_rst <= reg_wdata[0];
						pulse_key_valid <= reg_wdata[1];
						pulse_bdi_push <= reg_wdata[2];
						pulse_bdo_ready <= reg_wdata[3];
					end
					6'h02: begin
						mode_reg <= reg_wdata[3:0];
						bdi_type_reg <= reg_wdata[7:4];
						bdi_eot_reg <= reg_wdata[8];
						bdi_eoi_reg <= reg_wdata[9];
						bdo_eoo_reg <= reg_wdata[10];
					end
					6'h03: key_reg[31:0] <= reg_wdata;
					6'h04: key_reg[63:32] <= reg_wdata;
					6'h05: bdi_reg[31:0] <= reg_wdata;
					6'h06: bdi_reg[63:32] <= reg_wdata;
					6'h07: bdi_valid_reg <= reg_wdata[7:0];
					default:
						;
				endcase
		end
	always @(*) begin
		if (_sv2v_0)
			;
		reg_rdata = 32'h00000000;
		(* full_case, parallel_case *)
		case (reg_addr)
			6'h01: reg_rdata = {27'h0000000, auth, auth_valid, bdo_valid, bdi_ready, key_ready};
			6'h02: reg_rdata = {21'h000000, bdo_eoo_reg, bdi_eoi_reg, bdi_eot_reg, bdi_type_reg, mode_reg};
			6'h03: reg_rdata = key_reg[31:0];
			6'h04: reg_rdata = key_reg[63:32];
			6'h05: reg_rdata = bdi_reg[31:0];
			6'h06: reg_rdata = bdi_reg[63:32];
			6'h07: reg_rdata = {24'h000000, bdi_valid_reg};
			6'h08: reg_rdata = bdo[31:0];
			6'h09: reg_rdata = bdo[63:32];
			6'h0a: reg_rdata = {27'h0000000, bdo_eot, bdo_type};
			6'h3f: reg_rdata = 32'h4153434e;
			default: reg_rdata = 32'h00000000;
		endcase
	end
	ascon_core u_ascon_core(
		.clk(clk),
		.rst(core_rst),
		.key(key_reg),
		.key_valid(pulse_key_valid),
		.key_ready(key_ready),
		.bdi(bdi_reg),
		.bdi_valid(bdi_valid_pulse),
		.bdi_ready(bdi_ready),
		.bdi_type(bdi_type_reg),
		.bdi_eot(bdi_eot_reg),
		.bdi_eoi(bdi_eoi_reg),
		.mode(mode_reg),
		.bdo(bdo),
		.bdo_valid(bdo_valid),
		.bdo_ready(pulse_bdo_ready),
		.bdo_type(bdo_type),
		.bdo_eot(bdo_eot),
		.bdo_eoo(bdo_eoo_reg),
		.auth(auth),
		.auth_valid(auth_valid)
	);
	initial _sv2v_0 = 0;
endmodule
`default_nettype wire
