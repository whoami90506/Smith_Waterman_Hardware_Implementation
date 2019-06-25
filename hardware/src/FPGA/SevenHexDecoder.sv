`ifdef SEVNEHEXDECODER 
`else 
`define SEVNEHEXDECODER

module SevenHexDecoder(
  input [3:0] i_data, // SRAM address
  output logic [6:0] o_seven
);

//=======================================================
//----------------Seven Segment Display------------------
//=======================================================

  /* The layout of seven segment display, 1: dark
   *    00
   *   5  1
   *    66
   *   4  2
   *    33
   */
  parameter D0 = 7'b1000000;
  parameter D1 = 7'b1111001;
  parameter D2 = 7'b0100100;
  parameter D3 = 7'b0110000;
  parameter D4 = 7'b0011001;
  parameter D5 = 7'b0010010;
  parameter D6 = 7'b0000010;
  parameter D7 = 7'b1011000;
  parameter D8 = 7'b0000000;
  parameter D9 = 7'b0010000;
  parameter DN = 7'b1111111;

always_comb begin
	case (i_data)
		4'd0 : o_seven = D0;
		4'd1 : o_seven = D1;
		4'd2 : o_seven = D2;
		4'd3 : o_seven = D3;
		4'd4 : o_seven = D4;
		4'd5 : o_seven = D5;
		4'd6 : o_seven = D6;
		4'd7 : o_seven = D7;
		4'd8 : o_seven = D8;
		4'd9 : o_seven = D9;
		default : o_seven = DN;
	endcase
end
endmodule

`endif