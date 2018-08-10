//----------------------------------------------------------------------
//  Butterfly: Add/Sub and Scaling
//----------------------------------------------------------------------
module Butterfly #(
    parameter   WIDTH = 16,
    parameter   RH = 0          //  Round Half Up
)(
    input   signed  [WIDTH-1:0] x0_r,   //  Input Data #0 (Real)
    input   signed  [WIDTH-1:0] x0_i,   //  Input Data #0 (Imag)
    input   signed  [WIDTH-1:0] x1_r,   //  Input Data #1 (Real)
    input   signed  [WIDTH-1:0] x1_i,   //  Input Data #1 (Imag)
    output  signed  [WIDTH-1:0] y0_r,   //  Output Data #0 (Real)
    output  signed  [WIDTH-1:0] y0_i,   //  Output Data #0 (Imag)
    output  signed  [WIDTH-1:0] y1_r,   //  Output Data #1 (Real)
    output  signed  [WIDTH-1:0] y1_i    //  Output Data #1 (Imag)
);

//  Internal Nets
wire signed [WIDTH:0]   add_r, add_i, sub_r, sub_i;

//  Add/Sub
assign  add_r = x0_r + x1_r;
assign  add_i = x0_i + x1_i;
assign  sub_r = x0_r - x1_r;
assign  sub_i = x0_i - x1_i;

//  Scaling
assign  y0_r = (add_r + RH) >>> 1;
assign  y0_i = (add_i + RH) >>> 1;
assign  y1_r = (sub_r + RH) >>> 1;
assign  y1_i = (sub_i + RH) >>> 1;

endmodule
