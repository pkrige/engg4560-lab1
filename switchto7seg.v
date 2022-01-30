// By Radu Muresan; May 2021

module Reg8(I, Load, Q, reset);
	input [7:0] I;
	input Load;
	input reset;

	output [7:0] Q;
	reg [7:0] Q1;
	
	always @(posedge Load) begin
		// if(Load == 0)
		if(reset == 0)
			Q1 <= 8'bz;
		else
			Q1 <= I;
	end
	assign Q = Q1;
endmodule

module aes_encrypt(plain_text, ld_plain_text, encrypt, reg_reset, word_sel_enabled, plain_or_encrypted,done, digits);
	input [7:0] plain_text;
	input ld_plain_text;
	input encrypt;
	input reg_reset;
	input word_sel_enabled;
	input plain_or_encrypted;
	
	output done;
	output [27:0] digits;
	
	wire [127:0] plaintext128bit;
	wire [127:0] encrypted128bit;
	wire [127:0] todisplay128bit;
	wire [15:0] todisplay16bit;
	
	wire reg_128bit_full_indicator;
	wire encryption_complete;

	load_128bit_using_8bit_regs(plain_text, ld_plain_text, reg_reset, plaintext128bit, reg_128bit_full_indicator);
	
	display_16bit(plaintext128bit[15:0],digits);
	
	aes(plaintext128bit, reg_128bit_full_indicator, encrypt, encrypted128bit, encryption_complete);
	
	assign done = encryption_complete;
	
	select_128bit_output(plaintext128bit, encrypted128bit, plain_or_encrypted, todisplay128bit);
	
	select_quarter_word(todisplay128bit, plain_text[2:0], word_sel_enabled, encryption_complete, todisplay16bit);
	
endmodule  

module display_16bit(input_16bit, output_28bit);

	input [15:0] input_16bit;

	output [27:0] output_28bit;

	Hexto7seg Hexto7seg_0(input_16bit[3:0], output_28bit[6:0]);
	Hexto7seg Hexto7seg_1(input_16bit[7:4], output_28bit[13:7]);
	Hexto7seg Hexto7seg_2(input_16bit[11:8], output_28bit[20:14]);
	Hexto7seg Hexto7seg_3(input_16bit[15:12], output_28bit[27:21]);

endmodule


module select_quarter_word(to_display_128bit, qword_select, enable, encryption_complete_q, to_display_16bit);
	input [127:0] to_display_128bit;
	input [2:0] qword_select;
	input enable;
	input encryption_complete_q;
	
	output reg [15:0] to_display_16bit; 
	
	always @((enable) & (encryption_complete_q)) begin
		case(qword_select)
			2'b000: to_display_16bit <= to_display_128bit[15:0];
			2'b001: to_display_16bit <= to_display_128bit[31:16];
			2'b010: to_display_16bit <= to_display_128bit[47:32];
			2'b011: to_display_16bit <= to_display_128bit[63:48];
			2'b100: to_display_16bit <= to_display_128bit[78:64];
			2'b101: to_display_16bit <= to_display_128bit[95:79];
			2'b110: to_display_16bit <= to_display_128bit[111:96];
			2'b111: to_display_16bit <= to_display_128bit[127:112];
		endcase
	end	
endmodule



module select_128bit_output(unencrypted_128bit, encrypted_128bit, select_128bit, output_128bit);
	input [127:0] unencrypted_128bit;
	input [127:0] encrypted_128bit;
	input select_128bit;
	
	output reg [127:0] output_128bit;
	
	always @(select_128bit) begin
		case(select_128bit)
			1'b0: output_128bit <= unencrypted_128bit;
			1'b1: output_128bit <= encrypted_128bit;
		endcase
	end
	
endmodule

module load_128bit_using_8bit_regs(input_8bit, ld_plain_text, reset_8bit, output_128bit, output_128bit_full);
	// Inputs
	integer i;

	input [7:0] input_8bit;
	input ld_plain_text;
	input reset_8bit;

	// Outputs
	output [127:0] output_128bit;
	output reg output_128bit_full;
	
	Reg8 Reg8_0(input_8bit, ld_plain_text, output_128bit[7:0], reset_8bit);
	Reg8 Reg8_1(output_128bit[7:0], ld_plain_text, output_128bit[15:8], reset_8bit);
	Reg8 Reg8_2(output_128bit[15:8], ld_plain_text, output_128bit[23:16], reset_8bit);
	Reg8 Reg8_3(output_128bit[23:16], ld_plain_text, output_128bit[31:23], reset_8bit);
	Reg8 Reg8_4(output_128bit[31:23], ld_plain_text, output_128bit[39:31], reset_8bit);
	Reg8 Reg8_5(output_128bit[39:31], ld_plain_text, output_128bit[47:39], reset_8bit);
	Reg8 Reg8_6(output_128bit[47:39], ld_plain_text, output_128bit[55:47], reset_8bit);
	Reg8 Reg8_7(output_128bit[55:47], ld_plain_text, output_128bit[63:55], reset_8bit);
	Reg8 Reg8_8(output_128bit[63:55], ld_plain_text, output_128bit[71:63], reset_8bit);	
	Reg8 Reg8_9(output_128bit[71:63], ld_plain_text, output_128bit[79:71], reset_8bit);	
	Reg8 Reg8_10(output_128bit[79:71], ld_plain_text, output_128bit[87:79], reset_8bit);		
	Reg8 Reg8_11(output_128bit[87:79], ld_plain_text, output_128bit[95:87], reset_8bit);		
	Reg8 Reg8_12(output_128bit[95:87], ld_plain_text, output_128bit[103:95], reset_8bit);		
	Reg8 Reg8_13(output_128bit[103:95], ld_plain_text, output_128bit[111:103], reset_8bit);		
	Reg8 Reg8_14(output_128bit[111:103], ld_plain_text, output_128bit[119:111], reset_8bit);		
	Reg8 Reg8_15(output_128bit[119:111], ld_plain_text, output_128bit[127:119], reset_8bit);
	
	
	always @(posedge ld_plain_text) begin;
	
		  if(i < 16) begin
				i = i + 1;
				output_128bit_full = 0;
		  end else begin
				output_128bit_full = 1;
		  end
	end
	
endmodule

module aes(plaintext_128bit, regfull, encrypt, encrypted_128bit, encryption_complete_aes);
	input [127:0] plaintext_128bit; 
	input regfull;
	input encrypt;	

	output reg [127:0] encrypted_128bit;
	output reg encryption_complete_aes;
	
	always @ (posedge encrypt) begin
		if(encrypt && regfull)		
			encrypted_128bit <= ~plaintext_128bit;
			encryption_complete_aes <= 0;
	end
	
endmodule

module Hexto7seg(H, Seven);
//module Hexto7seg(H, store);
	input [3:0] H;
	output [7:0] Seven;
	// output reg [7:0] store;
	reg [7:0] store;
	
	always @(H) begin 
		case (H)
			4'b0000: store <= 8'b11000000; //display 0 8'b01111110;
			4'b0001: store <= 8'b11111001; //display 1 8'b00110000;
			4'b0010: store <= 8'b10100100; //display 2 8'b01101101;
			4'b0011: store <= 8'b10110000; //display 3 8'b01111001;
			4'b0100: store <= 8'b10011001; //display 4 8'b00110011;
			4'b0101: store <= 8'b10010010; //display 5 8'b01011011;
			4'b0110: store <= 8'b10000010; //display 6 8'b01011111;
			4'b0111: store <= 8'b11111000; //display 7 8'b01110000;
			4'b1000: store <= 8'b10000000; //display 8 8'b01111111;
			4'b1001: store <= 8'b10010000; //display 9 8'b01111011;
			4'b1010: store <= 8'b10001000; //display A 8'b01110111;
			4'b1011: store <= 8'b10000011; //display B 8'b00111110;
			4'b1100: store <= 8'b10100111; //display C 8'b01001110;
			4'b1101: store <= 8'b10100001; //display D 8'b01111101;
			4'b1110: store <= 8'b10000110; //display E 8'b01001111;
			4'b1111: store <= 8'b10001110; //display F 8'b01000111;
		endcase
	end

	assign Seven = store;
endmodule

module switchto7seg(I, key0, key1, key3, sw8, sw9, led, seg_disp);
	input [7:0] I;
	
	input key0, key1, key3, sw8, sw9;

	output [28:0] seg_disp;
	output led;
	
	// plain_text, ld_plain_text, encrypt, reg_reset, word_sel_enabled, plain_or_encrypted,done, digits
	aes_encrypt(I, key0, key1, key3, sw9, sw8, led, seg_disp);
	
endmodule