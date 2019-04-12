`ifdef PEARRAY
`else
`define PEARRAY

`include "PE.v"

module PEArray2 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [1:0] enable,
	input newLineIn,
	output newLineOut,
	input [3:0] s,
	input [1:0] tIn,
	output [1:0] tOut,
	input [`V_E_F_Bit-1:0] vIn,
	output [`V_E_F_Bit-1:0] vOut,
	input [`V_E_F_Bit-1:0] vIn_alpha,
	output [`V_E_F_Bit-1:0] vOut_alpha,
	input [`V_E_F_Bit-1:0] fIn,
	output [`V_E_F_Bit-1:0] fOut,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	output [`V_E_F_Bit-1:0] result
);

wire newLine_w;
wire [1:0] t_w;
wire [`V_E_F_Bit-1:0] v_w, v_alpha_w, f_w;

PE PE_1 (.clk(clk), .rst(rst_n), .enable(enable[0]), .newLineIn(newLineIn), .newLineOut(newLine_w), .s(s[1:0]), .tIn(tIn), 
	.tOut(t_w), .vIn(vIn), .vOut(v_w), .vIn_alpha(vIn_alpha), .vOut_alpha(v_alpha_w), .fIn(fIn), .fOut(f_w), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch));
PE PE_2 (.clk(clk), .rst(rst_n), .enable(enable[1]), .newLineIn(newLine_w), .newLineOut(newLineOut), .s(s[3:2]), .tIn(t_w), 
	.tOut(tOut), .vIn(v_w), .vOut(vOut), .vIn_alpha(v_alpha_w), .vOut_alpha(vOut_alpha), .fIn(f_w), .fOut(fOut), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch));
myMax ans (.a     (v_w), .b     (vOut), .result(result));
endmodule

module PEArray4 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [3:0] enable,
	input newLineIn,
	output newLineOut,
	input [7:0] s,
	input [1:0] tIn,
	output [1:0] tOut,
	input [`V_E_F_Bit-1:0] vIn,
	output [`V_E_F_Bit-1:0] vOut,
	input [`V_E_F_Bit-1:0] vIn_alpha,
	output [`V_E_F_Bit-1:0] vOut_alpha,
	input [`V_E_F_Bit-1:0] fIn,
	output [`V_E_F_Bit-1:0] fOut,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	output [`V_E_F_Bit-1:0] result
);

wire newLine_w;
wire [1:0] t_w;
wire [`V_E_F_Bit-1:0] v_w, v_alpha_w, f_w, result1, result2;

PEArray2 PE_1 (.clk(clk), .rst(rst_n), .enable(enable[1:0]), .newLineIn(newLineIn), .newLineOut(newLine_w), .s(s[3:0]), .tIn(tIn), 
	.tOut(t_w), .vIn(vIn), .vOut(v_w), .vIn_alpha(vIn_alpha), .vOut_alpha(v_alpha_w), .fIn(fIn), .fOut(f_w), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result1));
PEArray2 PE_2 (.clk(clk), .rst(rst_n), .enable(enable[3:2]), .newLineIn(newLine_w), .newLineOut(newLineOut), .s(s[7:4]), .tIn(t_w), 
	.tOut(tOut), .vIn(v_w), .vOut(vOut), .vIn_alpha(v_alpha_w), .vOut_alpha(vOut_alpha), .fIn(f_w), .fOut(fOut), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result2));
myMax ans (.a     (result1), .b     (result2), .result(result));
endmodule

module PEArray8 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [7:0] enable,
	input newLineIn,
	output newLineOut,
	input [15:0] s,
	input [1:0] tIn,
	output [1:0] tOut,
	input [`V_E_F_Bit-1:0] vIn,
	output [`V_E_F_Bit-1:0] vOut,
	input [`V_E_F_Bit-1:0] vIn_alpha,
	output [`V_E_F_Bit-1:0] vOut_alpha,
	input [`V_E_F_Bit-1:0] fIn,
	output [`V_E_F_Bit-1:0] fOut,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	output [`V_E_F_Bit-1:0] result
);

wire newLine_w;
wire [1:0] t_w;
wire [`V_E_F_Bit-1:0] v_w, v_alpha_w, f_w, result1, result2;

PEArray4 PE_1 (.clk(clk), .rst(rst_n), .enable(enable[3:0]), .newLineIn(newLineIn), .newLineOut(newLine_w), .s(s[7:0]), .tIn(tIn), 
	.tOut(t_w), .vIn(vIn), .vOut(v_w), .vIn_alpha(vIn_alpha), .vOut_alpha(v_alpha_w), .fIn(fIn), .fOut(f_w), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result1));
PEArray4 PE_2 (.clk(clk), .rst(rst_n), .enable(enable[7:4]), .newLineIn(newLine_w), .newLineOut(newLineOut), .s(s[15:8]), .tIn(t_w), 
	.tOut(tOut), .vIn(v_w), .vOut(vOut), .vIn_alpha(v_alpha_w), .vOut_alpha(vOut_alpha), .fIn(f_w), .fOut(fOut), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result2));
myMax ans (.a     (result1), .b     (result2), .result(result));
endmodule
`endif