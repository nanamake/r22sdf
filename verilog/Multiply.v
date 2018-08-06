//----------------------------------------------------------------------
//  Multiply: Complex Multiplier
//----------------------------------------------------------------------
module Multiply #(
    parameter   WIDTH = 16
)(
    input   signed  [WIDTH-1:0] ar,
    input   signed  [WIDTH-1:0] ai,
    input   signed  [WIDTH-1:0] br,
    input   signed  [WIDTH-1:0] bi,
    output  signed  [WIDTH-1:0] mr,
    output  signed  [WIDTH-1:0] mi
);

//  Internal Nets
wire signed [WIDTH*2-1:0]   arbr, arbi, aibr, aibi;
wire signed [WIDTH-1:0]     sc_arbr, sc_arbi, sc_aibr, sc_aibi;

//  Signed Multiplication
assign  arbr = ar * br;
assign  arbi = ar * bi;
assign  aibr = ai * br;
assign  aibi = ai * bi;

//  Scaling
assign  sc_arbr = arbr >>> (WIDTH-1);
assign  sc_arbi = arbi >>> (WIDTH-1);
assign  sc_aibr = aibr >>> (WIDTH-1);
assign  sc_aibi = aibi >>> (WIDTH-1);

//  These add/sub may overflow if unnormalized data is input.
assign  mr = sc_arbr - sc_aibi;
assign  mi = sc_arbi + sc_aibr;

endmodule
