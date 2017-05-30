//----------------------------------------------------------------------
//  ComplexMul: Complex Multiplier
//----------------------------------------------------------------------
module ComplexMul #(
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
wire signed [WIDTH-1:0]     trn_arbr, trn_arbi, trn_aibr, trn_aibi;

//  Complex Multiplier
assign  arbr = ar * br;
assign  arbi = ar * bi;
assign  aibr = ai * br;
assign  aibi = ai * bi;

assign  trn_arbr = arbr >>> (WIDTH-1);
assign  trn_arbi = arbi >>> (WIDTH-1);
assign  trn_aibr = aibr >>> (WIDTH-1);
assign  trn_aibi = aibi >>> (WIDTH-1);

assign  mr = trn_arbr - trn_aibi;
assign  mi = trn_arbi + trn_aibr;

endmodule
