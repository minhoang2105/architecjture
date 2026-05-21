module asconp (
	round_cnt,
	x0_i,
	x1_i,
	x2_i,
	x3_i,
	x4_i,
	x0_o,
	x1_o,
	x2_o,
	x3_o,
	x4_o
);
	input wire [3:0] round_cnt;
	input wire [63:0] x0_i;
	input wire [63:0] x1_i;
	input wire [63:0] x2_i;
	input wire [63:0] x3_i;
	input wire [63:0] x4_i;
	output wire [63:0] x0_o;
	output wire [63:0] x1_o;
	output wire [63:0] x2_o;
	output wire [63:0] x3_o;
	output wire [63:0] x4_o;
	localparam [3:0] UROL = 4;
	wire [(UROL * 64) - 1:0] x0_aff1;
	wire [(UROL * 64) - 1:0] x0_chi;
	wire [(UROL * 64) - 1:0] x0_aff2;
	wire [(UROL * 64) - 1:0] x1_aff1;
	wire [(UROL * 64) - 1:0] x1_chi;
	wire [(UROL * 64) - 1:0] x1_aff2;
	wire [(UROL * 64) - 1:0] x2_aff1;
	wire [(UROL * 64) - 1:0] x2_chi;
	wire [(UROL * 64) - 1:0] x2_aff2;
	wire [(UROL * 64) - 1:0] x3_aff1;
	wire [(UROL * 64) - 1:0] x3_chi;
	wire [(UROL * 64) - 1:0] x3_aff2;
	wire [(UROL * 64) - 1:0] x4_aff1;
	wire [(UROL * 64) - 1:0] x4_chi;
	wire [(UROL * 64) - 1:0] x4_aff2;
	wire [((UROL + 1) * 64) - 1:0] x0;
	wire [((UROL + 1) * 64) - 1:0] x1;
	wire [((UROL + 1) * 64) - 1:0] x2;
	wire [((UROL + 1) * 64) - 1:0] x3;
	wire [((UROL + 1) * 64) - 1:0] x4;
	wire [(UROL * 4) - 1:0] t;
	assign x0[0+:64] = x0_i;
	assign x1[0+:64] = x1_i;
	assign x2[0+:64] = x2_i;
	assign x3[0+:64] = x3_i;
	assign x4[0+:64] = x4_i;
	genvar _gv_i_1;
	generate
		for (_gv_i_1 = 0; _gv_i_1 < UROL; _gv_i_1 = _gv_i_1 + 1) begin : g_asconp
			localparam i = _gv_i_1;
			assign t[i * 4+:4] = 4'hc - (round_cnt - i);
			assign x0_aff1[i * 64+:64] = x0[i * 64+:64] ^ x4[i * 64+:64];
			assign x1_aff1[i * 64+:64] = x1[i * 64+:64];
			assign x2_aff1[i * 64+:64] = (x2[i * 64+:64] ^ x1[i * 64+:64]) ^ {56'd0, 4'hf - t[i * 4+:4], t[i * 4+:4]};
			assign x3_aff1[i * 64+:64] = x3[i * 64+:64];
			assign x4_aff1[i * 64+:64] = x4[i * 64+:64] ^ x3[i * 64+:64];
			assign x0_chi[i * 64+:64] = x0_aff1[i * 64+:64] ^ (~x1_aff1[i * 64+:64] & x2_aff1[i * 64+:64]);
			assign x1_chi[i * 64+:64] = x1_aff1[i * 64+:64] ^ (~x2_aff1[i * 64+:64] & x3_aff1[i * 64+:64]);
			assign x2_chi[i * 64+:64] = x2_aff1[i * 64+:64] ^ (~x3_aff1[i * 64+:64] & x4_aff1[i * 64+:64]);
			assign x3_chi[i * 64+:64] = x3_aff1[i * 64+:64] ^ (~x4_aff1[i * 64+:64] & x0_aff1[i * 64+:64]);
			assign x4_chi[i * 64+:64] = x4_aff1[i * 64+:64] ^ (~x0_aff1[i * 64+:64] & x1_aff1[i * 64+:64]);
			assign x0_aff2[i * 64+:64] = x0_chi[i * 64+:64] ^ x4_chi[i * 64+:64];
			assign x1_aff2[i * 64+:64] = x1_chi[i * 64+:64] ^ x0_chi[i * 64+:64];
			assign x2_aff2[i * 64+:64] = ~x2_chi[i * 64+:64];
			assign x3_aff2[i * 64+:64] = x3_chi[i * 64+:64] ^ x2_chi[i * 64+:64];
			assign x4_aff2[i * 64+:64] = x4_chi[i * 64+:64];
			assign x0[(i + 1) * 64+:64] = (x0_aff2[i * 64+:64] ^ {x0_aff2[(i * 64) + 18-:19], x0_aff2[(i * 64) + 63-:45]}) ^ {x0_aff2[(i * 64) + 27-:28], x0_aff2[(i * 64) + 63-:36]};
			assign x1[(i + 1) * 64+:64] = (x1_aff2[i * 64+:64] ^ {x1_aff2[(i * 64) + 60-:61], x1_aff2[(i * 64) + 63-:3]}) ^ {x1_aff2[(i * 64) + 38-:39], x1_aff2[(i * 64) + 63-:25]};
			assign x2[(i + 1) * 64+:64] = (x2_aff2[i * 64+:64] ^ {x2_aff2[i * 64-:1], x2_aff2[(i * 64) + 63-:63]}) ^ {x2_aff2[(i * 64) + 5-:6], x2_aff2[(i * 64) + 63-:58]};
			assign x3[(i + 1) * 64+:64] = (x3_aff2[i * 64+:64] ^ {x3_aff2[(i * 64) + 9-:10], x3_aff2[(i * 64) + 63-:54]}) ^ {x3_aff2[(i * 64) + 16-:17], x3_aff2[(i * 64) + 63-:47]};
			assign x4[(i + 1) * 64+:64] = (x4_aff2[i * 64+:64] ^ {x4_aff2[(i * 64) + 6-:7], x4_aff2[(i * 64) + 63-:57]}) ^ {x4_aff2[(i * 64) + 40-:41], x4_aff2[(i * 64) + 63-:23]};
		end
	endgenerate
	assign x0_o = x0[UROL * 64+:64];
	assign x1_o = x1[UROL * 64+:64];
	assign x2_o = x2[UROL * 64+:64];
	assign x3_o = x3[UROL * 64+:64];
	assign x4_o = x4[UROL * 64+:64];
endmodule
module register (
	clk,
	rst,
	data_d,
	data_q
);
	parameter DATA_WIDTH = 0;
	function automatic [DATA_WIDTH - 1:0] sv2v_cast_DD846;
		input reg [DATA_WIDTH - 1:0] inp;
		sv2v_cast_DD846 = inp;
	endfunction
	parameter RST_VALUE = sv2v_cast_DD846('d0);
	input wire clk;
	input wire rst;
	input wire [DATA_WIDTH - 1:0] data_d;
	output reg [DATA_WIDTH - 1:0] data_q;
	always @(posedge clk or posedge rst) begin : register_update
		if (rst)
			data_q <= RST_VALUE;
		else
			data_q <= data_d;
	end
endmodule
module ascon_core (
	clk,
	rst,
	key,
	key_valid,
	key_ready,
	bdi,
	bdi_valid,
	bdi_ready,
	bdi_type,
	bdi_eot,
	bdi_eoi,
	mode,
	bdo,
	bdo_valid,
	bdo_ready,
	bdo_type,
	bdo_eot,
	bdo_eoo,
	auth,
	auth_valid
);
	reg _sv2v_0;
	input wire clk;
	input wire rst;
	localparam CCW = 64;
	input wire [CCW - 1:0] key;
	input wire key_valid;
	output reg key_ready;
	input wire [CCW - 1:0] bdi;
	input wire [(CCW / 8) - 1:0] bdi_valid;
	output reg bdi_ready;
	input wire [3:0] bdi_type;
	input wire bdi_eot;
	input wire bdi_eoi;
	input wire [3:0] mode;
	output reg [CCW - 1:0] bdo;
	output reg bdo_valid;
	input wire bdo_ready;
	output reg [3:0] bdo_type;
	output reg bdo_eot;
	input wire bdo_eoo;
	output reg auth;
	output reg auth_valid;
	localparam [3:0] W128 = (CCW == 32 ? 4'd4 : 4'd2);
	reg [(W128 * CCW) - 1:0] key_d;
	wire [(W128 * CCW) - 1:0] key_q;
	localparam LANES = 5;
	localparam [3:0] W64 = (CCW == 32 ? 4'd2 : 4'd1);
	reg [((LANES * W64) * CCW) - 1:0] state_d;
	wire [((LANES * W64) * CCW) - 1:0] state_q;
	reg [3:0] round_cnt_d;
	reg [3:0] word_cnt_d;
	wire [3:0] round_cnt_q;
	wire [3:0] word_cnt_q;
	reg [1:0] hash_cnt_d;
	wire [1:0] hash_cnt_q;
	reg [4:0] fsm_d;
	wire [4:0] fsm_q;
	reg [3:0] mode_d;
	wire [3:0] mode_q;
	reg auth_d;
	reg auth_intern_d;
	reg auth_valid_d;
	wire auth_q;
	wire auth_intern_q;
	wire auth_valid_q;
	reg ad_eot_d;
	reg ad_pad_d;
	reg msg_pad_d;
	reg eoi_d;
	wire ad_eot_q;
	wire ad_pad_q;
	wire msg_pad_q;
	wire eoi_q;
	register #(.DATA_WIDTH('d128)) reg_key_i(
		.clk(clk),
		.rst(rst),
		.data_d(key_d),
		.data_q(key_q)
	);
	register #(.DATA_WIDTH('d320)) reg_state_i(
		.clk(clk),
		.rst(rst),
		.data_d(state_d),
		.data_q(state_q)
	);
	register #(.DATA_WIDTH('d10)) reg_cnt_i(
		.clk(clk),
		.rst(rst),
		.data_d({round_cnt_d, word_cnt_d, hash_cnt_d}),
		.data_q({round_cnt_q, word_cnt_q, hash_cnt_q})
	);
	register #(
		.DATA_WIDTH('d5),
		.RST_VALUE(5'd1)
	) reg_fsm_i(
		.clk(clk),
		.rst(rst),
		.data_d(fsm_d),
		.data_q(fsm_q)
	);
	register #(.DATA_WIDTH('d11)) reg_flags_i(
		.clk(clk),
		.rst(rst),
		.data_d({auth_d, auth_intern_d, auth_valid_d, ad_eot_d, ad_pad_d, msg_pad_d, eoi_d, mode_d}),
		.data_q({auth_q, auth_intern_q, auth_valid_q, ad_eot_q, ad_pad_q, msg_pad_q, eoi_q, mode_q})
	);
	wire last_abs_blk;
	wire add_ad_pad;
	wire add_msg_pad;
	wire mode_enc_dec;
	wire mode_hash_xof;
	assign mode_enc_dec = (mode_q == 4'd1) || (mode_q == 4'd2);
	assign mode_hash_xof = ((mode_q == 4'd3) || (mode_q == 4'd4)) || (mode_q == 4'd5);
	wire idle_done;
	wire ld_key;
	wire ld_key_done;
	wire ld_npub;
	wire ld_npub_done;
	wire init;
	wire init_done;
	wire kadd_2_done;
	assign idle_done = (fsm_q == 5'd1) && (mode > 'd0);
	assign ld_key = ((fsm_q == 5'd2) && key_valid) && key_ready;
	assign ld_key_done = ld_key && (word_cnt_q == (W128 - 1));
	assign ld_npub = (((fsm_q == 5'd3) && (bdi_type == 4'd1)) && (bdi_valid > 'd0)) && bdi_ready;
	assign ld_npub_done = ld_npub && (word_cnt_q == (W128 - 1));
	assign init = fsm_q == 5'd4;
	localparam [3:0] UROL = 4;
	assign init_done = init && (round_cnt_q == UROL);
	assign kadd_2_done = (fsm_q == 5'd5) && (eoi_q || (bdi_valid > 'd0));
	wire abs_ad;
	wire abs_ad_done;
	wire pro_ad;
	wire pro_ad_done;
	assign abs_ad = (((fsm_q == 5'd6) && (bdi_type == 4'd2)) && (bdi_valid > 'd0)) && bdi_ready;
	assign abs_ad_done = abs_ad && (last_abs_blk || bdi_eot);
	assign pro_ad = fsm_q == 5'd8;
	assign pro_ad_done = pro_ad && (round_cnt_q == UROL);
	wire dom_sep_done;
	assign dom_sep_done = fsm_q == 5'd9;
	wire abs_msg_part;
	wire abs_msg;
	wire abs_msg_done;
	wire pro_msg;
	wire pro_msg_done;
	assign abs_msg_part = (((fsm_q == 5'd10) && (bdi_type == 4'd3)) && (bdi_valid != 'd0)) && bdi_ready;
	assign abs_msg = abs_msg_part && ((bdo_valid && bdo_ready) || !mode_enc_dec);
	assign abs_msg_done = abs_msg && (last_abs_blk || bdi_eot);
	assign pro_msg = fsm_q == 5'd12;
	assign pro_msg_done = (round_cnt_q == UROL) && pro_msg;
	wire kadd_3_done;
	wire fin;
	wire fin_done;
	wire kadd_4_done;
	assign kadd_3_done = fsm_q == 5'd13;
	assign fin = fsm_q == 5'd14;
	assign fin_done = (round_cnt_q == UROL) && fin;
	assign kadd_4_done = fsm_q == 5'd15;
	wire sqz_hash;
	wire sqz_hash_done1;
	wire sqz_hash_done2;
	wire sqz_tag;
	wire sqz_tag_done;
	wire ver_tag;
	wire ver_tag_done;
	assign sqz_hash = ((fsm_q == 5'd17) && bdo_valid) && bdo_ready;
	assign sqz_hash_done1 = (word_cnt_q == (W64 - 1)) && sqz_hash;
	assign sqz_hash_done2 = ((hash_cnt_q == 'd3) && sqz_hash_done1) || (sqz_hash && bdo_eoo);
	assign sqz_tag = ((fsm_q == 5'd16) && bdo_valid) && bdo_ready;
	assign sqz_tag_done = (word_cnt_q == (W128 - 1)) && sqz_tag;
	assign ver_tag = (((fsm_q == 5'd18) && (bdi_type == 4'd4)) && bdi_ready) && (bdi_valid != 'd0);
	assign ver_tag_done = (word_cnt_q == (W128 - 1)) && ver_tag;
	assign last_abs_blk = ((((abs_ad && mode_enc_dec) && (word_cnt_q == (W128 - 1))) || ((abs_ad && (mode_q == 4'd5)) && (word_cnt_q == (W64 - 1)))) || ((abs_msg && mode_enc_dec) && (word_cnt_q == (W128 - 1)))) || ((abs_msg && mode_hash_xof) && (word_cnt_q == (W64 - 1)));
	assign add_ad_pad = (fsm_q == 5'd7) || (abs_ad && (bdi_valid != {CCW / 8 {1'sb1}}));
	assign add_msg_pad = ((fsm_q == 5'd11) || (dom_sep_done && eoi_q)) || (abs_msg && (bdi_valid != {CCW / 8 {1'sb1}}));
	reg [3:0] state_idx;
	wire [3:0] lane_idx;
	wire [3:0] word_idx;
	reg [CCW - 1:0] state_slice_nx;
	wire [CCW - 1:0] state_slice;
	reg [CCW - 1:0] bdi_pad;
	assign word_idx = (CCW == 64 ? 'd0 : state_idx % 2);
	assign lane_idx = (CCW == 64 ? state_idx : state_idx / 2);
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	assign state_slice = state_q[((sv2v_cast_32_signed(lane_idx) * W64) + sv2v_cast_32_signed(word_idx)) * CCW+:CCW];
	wire [((LANES * W64) * CCW) - 1:0] asconp_o;
	asconp asconp_i(
		.round_cnt(round_cnt_q),
		.x0_i(state_q[0+:CCW * W64]),
		.x1_i(state_q[CCW * W64+:CCW * W64]),
		.x2_i(state_q[CCW * (2 * W64)+:CCW * W64]),
		.x3_i(state_q[CCW * (3 * W64)+:CCW * W64]),
		.x4_i(state_q[CCW * (4 * W64)+:CCW * W64]),
		.x0_o(asconp_o[0+:CCW * W64]),
		.x1_o(asconp_o[CCW * W64+:CCW * W64]),
		.x2_o(asconp_o[CCW * (2 * W64)+:CCW * W64]),
		.x3_o(asconp_o[CCW * (3 * W64)+:CCW * W64]),
		.x4_o(asconp_o[CCW * (4 * W64)+:CCW * W64])
	);
	localparam [3:0] W192 = (CCW == 32 ? 4'd6 : 4'd3);
	function automatic [CCW - 1:0] mask;
		input reg [CCW - 1:0] in1;
		input reg [(CCW / 8) - 1:0] val;
		reg signed [31:0] i;
		for (i = 0; i < (CCW / 8); i = i + 1)
			mask[i * 8+:8] = (val[i] ? in1[i * 8+:8] : 'd0);
	endfunction
	function automatic [CCW - 1:0] pad;
		input reg [CCW - 1:0] in;
		input reg [(CCW / 8) - 1:0] val;
		begin
			pad[7:0] = (val[0] ? in[7:0] : 'd0);
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 1; i < (CCW / 8); i = i + 1)
					pad[i * 8+:8] = (val[i] ? in[i * 8+:8] : (val[i - 1] ? 'd1 : 'd0));
			end
		end
	endfunction
	function automatic [CCW - 1:0] pad2;
		input reg [CCW - 1:0] in1;
		input reg [CCW - 1:0] in2;
		input reg [(CCW / 8) - 1:0] val;
		begin
			pad2[7:0] = (val[0] ? in1[7:0] : in2[7:0]);
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 1; i < (CCW / 8); i = i + 1)
					pad2[i * 8+:8] = (val[i] ? in1[i * 8+:8] : (val[i - 1] ? 'd1 ^ in2[i * 8+:8] : in2[i * 8+:8]));
			end
		end
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		state_slice_nx = 'd0;
		state_idx = 'd0;
		key_ready = 'd0;
		bdi_ready = 'd0;
		bdo = 'd0;
		bdo_valid = 'd0;
		bdo_type = 4'd0;
		bdo_eot = 'd0;
		bdi_pad = 'd0;
		auth = auth_q;
		auth_valid = auth_valid_q;
		(* full_case, parallel_case *)
		case (fsm_q)
			5'd2: key_ready = 'd1;
			5'd3: begin
				state_idx = word_cnt_q + W192;
				bdi_ready = 'd1;
				state_slice_nx = bdi;
			end
			5'd6: begin
				state_idx = word_cnt_q;
				bdi_ready = 'd1;
				bdi_pad = pad(bdi, bdi_valid);
				state_slice_nx = state_slice ^ bdi_pad;
			end
			5'd7, 5'd11: state_idx = word_cnt_q;
			5'd10: begin
				state_idx = word_cnt_q;
				if ((mode_q == 4'd1) || mode_hash_xof) begin
					bdi_pad = pad(bdi, bdi_valid);
					state_slice_nx = state_slice ^ bdi_pad;
					bdo = mask(state_slice_nx, bdi_valid);
				end
				else if (mode_q == 4'd2) begin
					bdi_pad = pad2(bdi, state_slice, bdi_valid);
					state_slice_nx = bdi_pad;
					bdo = mask(state_slice ^ state_slice_nx, bdi_valid);
				end
				bdi_ready = (mode_enc_dec ? bdo_ready : 'd1);
				bdo_valid = (mode_enc_dec && (bdi_valid != 'd0) ? 'd1 : 'd0);
				bdo_type = (mode_enc_dec ? 4'd3 : 4'd0);
				bdo_eot = (mode_enc_dec ? bdi_eot : 'd0);
				if (mode_q == 4'd3)
					bdo = 'd0;
			end
			5'd16: begin
				state_idx = word_cnt_q + W192;
				bdo = state_slice;
				bdo_valid = 'd1;
				bdo_type = 4'd4;
				bdo_eot = word_cnt_q == (W128 - 1);
			end
			5'd17: begin
				state_idx = word_cnt_q;
				bdo = state_slice;
				bdo_valid = 'd1;
				bdo_type = 4'd5;
				bdo_eot = (hash_cnt_q == 'd3) && (word_cnt_q == (W64 - 1));
			end
			5'd18: begin
				state_idx = word_cnt_q + W192;
				bdi_ready = 'd1;
			end
			default:
				;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		fsm_d = fsm_q;
		if (idle_done) begin
			if ((mode == 4'd1) || (mode == 4'd2))
				fsm_d = (key_valid ? 5'd2 : 5'd3);
			if (((mode == 4'd3) || (mode == 4'd4)) || (mode == 4'd5))
				fsm_d = 5'd4;
		end
		if (ld_key_done)
			fsm_d = 5'd3;
		if (ld_npub_done)
			fsm_d = 5'd4;
		if (init_done) begin
			if (mode_enc_dec)
				fsm_d = 5'd5;
			if ((mode_q == 4'd3) || (mode_q == 4'd4))
				fsm_d = (eoi_q ? 5'd11 : 5'd10);
			if (mode_q == 4'd5)
				fsm_d = 5'd6;
		end
		if (kadd_2_done) begin
			if (eoi_q)
				fsm_d = 5'd9;
			else if (bdi_type == 4'd2)
				fsm_d = 5'd6;
			else if (bdi_type == 4'd3)
				fsm_d = 5'd9;
		end
		if (abs_ad_done) begin
			if (bdi_valid != {CCW / 8 {1'sb1}})
				fsm_d = 5'd8;
			else if ((word_cnt_q != (W128 - 1)) && mode_enc_dec)
				fsm_d = 5'd7;
			else if ((word_cnt_q != (W64 - 1)) && mode_hash_xof)
				fsm_d = 5'd7;
			else
				fsm_d = 5'd8;
		end
		if (fsm_q == 5'd7)
			fsm_d = 5'd8;
		if (pro_ad_done) begin
			if (ad_eot_q == 0)
				fsm_d = 5'd6;
			else if (ad_pad_q == 0)
				fsm_d = 5'd7;
			else if (mode_enc_dec)
				fsm_d = 5'd9;
			else if (mode_q == 4'd5)
				fsm_d = (ad_eot_q ? (eoi_q ? 5'd11 : 5'd10) : 5'd10);
		end
		if (dom_sep_done)
			fsm_d = (eoi_q ? 5'd13 : 5'd10);
		if (abs_msg_done) begin
			if (bdi_valid != {CCW / 8 {1'sb1}}) begin
				if (mode_hash_xof)
					fsm_d = 5'd14;
				else
					fsm_d = 5'd13;
			end
			else if (mode_enc_dec && (word_cnt_q != (W128 - 1)))
				fsm_d = 5'd11;
			else if ((word_cnt_q != (W64 - 1)) && mode_hash_xof)
				fsm_d = 5'd11;
			else
				fsm_d = 5'd12;
		end
		if (fsm_q == 5'd11) begin
			if (mode_hash_xof)
				fsm_d = 5'd14;
			else
				fsm_d = 5'd13;
		end
		if (pro_msg_done) begin
			if (eoi_q == 0)
				fsm_d = 5'd10;
			else if (msg_pad_q == 0)
				fsm_d = 5'd11;
		end
		if (kadd_3_done)
			fsm_d = 5'd14;
		if (fin_done) begin
			if (mode_q == 4'd3)
				fsm_d = 5'd17;
			else if ((mode_q == 4'd4) || (mode_q == 4'd5))
				fsm_d = 5'd17;
			else
				fsm_d = 5'd15;
		end
		if (kadd_4_done)
			fsm_d = (mode_q == 4'd2 ? 5'd18 : 5'd16);
		if (sqz_hash_done1)
			fsm_d = 5'd14;
		if (sqz_hash_done2)
			fsm_d = 5'd1;
		if (sqz_tag_done)
			fsm_d = 5'd1;
		if (ver_tag_done)
			fsm_d = 5'd1;
	end
	localparam [63:0] IV_AEAD = 64'h00001000808c0001;
	localparam [63:0] IV_CXOF = 64'h0000080000cc0004;
	localparam [63:0] IV_HASH = 64'h0000080100cc0002;
	localparam [63:0] IV_XOF = 64'h0000080000cc0003;
	always @(*) begin
		if (_sv2v_0)
			;
		state_d = state_q;
		if ((ld_npub || abs_ad) || abs_msg)
			state_d[((sv2v_cast_32_signed(lane_idx) * W64) + sv2v_cast_32_signed(word_idx)) * CCW+:CCW] = state_slice_nx;
		if ((fsm_q == 5'd7) || (fsm_q == 5'd11))
			state_d[((sv2v_cast_32_signed(lane_idx) * W64) + sv2v_cast_32_signed(word_idx)) * CCW+:CCW] = state_slice ^ 'd1;
		if (idle_done && (((mode == 4'd3) || (mode == 4'd4)) || (mode == 4'd5))) begin
			state_d = 1'sb0;
			(* full_case, parallel_case *)
			case (mode)
				4'd3: state_d[0+:CCW * W64] = IV_HASH[0+:64];
				4'd4: state_d[0+:CCW * W64] = IV_XOF[0+:64];
				4'd5: state_d[0+:CCW * W64] = IV_CXOF[0+:64];
				default:
					;
			endcase
		end
		if (ld_npub_done) begin
			state_d[0+:CCW * W64] = IV_AEAD[0+:64];
			state_d[CCW * W64+:CCW * W64] = key_q[0+:CCW * W64];
			state_d[CCW * (2 * W64)+:CCW * W64] = key_q[CCW * W64+:CCW * W64];
		end
		if (((init || pro_ad) || pro_msg) || fin)
			state_d = asconp_o;
		if (kadd_2_done || kadd_4_done) begin
			state_d[CCW * (3 * W64)+:CCW * W64] = state_q[CCW * (3 * W64)+:CCW * W64] ^ key_q[0+:CCW * W64];
			state_d[CCW * (4 * W64)+:CCW * W64] = state_q[CCW * (4 * W64)+:CCW * W64] ^ key_q[CCW * W64+:CCW * W64];
		end
		if (dom_sep_done) begin
			state_d[CCW * (4 * W64)+:CCW * W64] = state_q[CCW * (4 * W64)+:CCW * W64] ^ 64'h8000000000000000;
			if (eoi_q)
				state_d[0+:CCW * W64] = state_q[0+:CCW * W64] ^ 'd1;
		end
		if (kadd_3_done) begin
			state_d[CCW * (2 * W64)+:CCW * W64] = state_q[CCW * (2 * W64)+:CCW * W64] ^ key_q[0+:CCW * W64];
			state_d[CCW * (3 * W64)+:CCW * W64] = state_q[CCW * (3 * W64)+:CCW * W64] ^ key_q[CCW * W64+:CCW * W64];
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		key_d = key_q;
		if (ld_key)
			key_d[word_cnt_q[(64 / CCW) - 1:0] * CCW+:CCW] = key;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		word_cnt_d = word_cnt_q;
		if ((((((ld_key || ld_npub) || abs_ad) || abs_msg) || sqz_tag) || sqz_hash) || ver_tag)
			word_cnt_d = word_cnt_q + 'd1;
		if ((((ld_key_done || ld_npub_done) || sqz_tag_done) || sqz_hash_done1) || ver_tag_done)
			word_cnt_d = 'd0;
		if (abs_ad_done || abs_msg_done) begin
			if ((fsm_d == 5'd7) || (fsm_d == 5'd11))
				word_cnt_d = word_cnt_q + 'd1;
			else
				word_cnt_d = 'd0;
		end
		if (fsm_q == 5'd7)
			word_cnt_d = 'd0;
		if (fsm_q == 5'd11)
			word_cnt_d = 'd0;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		hash_cnt_d = hash_cnt_q;
		if (mode_q == 4'd3) begin
			if (sqz_hash_done1)
				hash_cnt_d = hash_cnt_q + 'd1;
			if (abs_ad_done && bdi_eoi)
				hash_cnt_d = 'd0;
		end
	end
	localparam ROUNDS_A = 12;
	localparam ROUNDS_B = 8;
	always @(*) begin
		if (_sv2v_0)
			;
		round_cnt_d = round_cnt_q;
		(* full_case, parallel_case *)
		case (fsm_d)
			5'd4: round_cnt_d = ROUNDS_A;
			5'd8: round_cnt_d = (mode_q == 4'd5 ? ROUNDS_A : ROUNDS_B);
			5'd12: round_cnt_d = (mode_hash_xof ? ROUNDS_A : ROUNDS_B);
			5'd14: round_cnt_d = ROUNDS_A;
			default:
				;
		endcase
		if (((init || pro_ad) || pro_msg) || fin)
			round_cnt_d = round_cnt_q - UROL;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		auth_d = auth_q;
		auth_intern_d = auth_intern_q;
		auth_valid_d = auth_valid_q;
		ad_eot_d = ad_eot_q;
		ad_pad_d = ad_pad_q;
		eoi_d = eoi_q;
		msg_pad_d = msg_pad_q;
		mode_d = mode_q;
		if (idle_done) begin
			auth_d = 'd0;
			auth_intern_d = 'd0;
			auth_valid_d = 'd0;
			ad_eot_d = 'd0;
			ad_pad_d = 'd0;
			eoi_d = bdi_eoi;
			msg_pad_d = 'd0;
			mode_d = mode;
		end
		if (ld_npub_done) begin
			if (bdi_eoi)
				eoi_d = 'd1;
		end
		if (abs_ad_done) begin
			if (bdi_eot)
				ad_eot_d = 'd1;
			if (bdi_eoi)
				eoi_d = 'd1;
		end
		if (add_ad_pad)
			ad_pad_d = 'd1;
		if (add_msg_pad)
			ad_pad_d = 'd1;
		if (abs_msg_done && bdi_eoi)
			eoi_d = 'd1;
		if (kadd_4_done && (mode_q == 4'd2))
			auth_intern_d = 'd1;
		if (ver_tag)
			auth_intern_d = auth_intern_d && (bdi == state_slice);
		if (ver_tag_done) begin
			auth_d = auth_intern_q && auth_intern_d;
			auth_valid_d = 'd1;
		end
	end
	wire [63:0] x0;
	wire [63:0] x1;
	wire [63:0] x2;
	wire [63:0] x3;
	wire [63:0] x4;
	assign x0 = state_q[0+:CCW * W64];
	assign x1 = state_q[CCW * W64+:CCW * W64];
	assign x2 = state_q[CCW * (2 * W64)+:CCW * W64];
	assign x3 = state_q[CCW * (3 * W64)+:CCW * W64];
	assign x4 = state_q[CCW * (4 * W64)+:CCW * W64];
	initial _sv2v_0 = 0;
endmodule
