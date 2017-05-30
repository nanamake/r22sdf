//----------------------------------------------------------------------
//  Butterfly: Radix-2^2 SDF Butterfly
//----------------------------------------------------------------------
module Butterfly #(
    parameter   WIDTH = 16
)(
    input               bf_en,          //  Butterfly Add/Sub Enable
    input               bf_mj_en,       //  Twiddle (-j) Enable
    input   [WIDTH-1:0] idata_r,        //  Input Data (Real)
    input   [WIDTH-1:0] idata_i,        //  Input Data (Imag)
    input   [WIDTH-1:0] dl_odata_r,     //  DelayBuf Output Data (Real)
    input   [WIDTH-1:0] dl_odata_i,     //  DelayBuf Output Data (Imag)
    output  [WIDTH-1:0] dl_idata_r,     //  DelayBuf Input Data (Real)
    output  [WIDTH-1:0] dl_idata_i,     //  DelayBuf Input Data (Imag)
    output  [WIDTH-1:0] odata_r,        //  Output Data (Real)
    output  [WIDTH-1:0] odata_i         //  Output Data (Imag)
);

//  Internal Nets
wire signed [WIDTH-1:0] x0_r, x0_i, x1_r, x1_i;
wire signed [WIDTH:0]   add_r, add_i, sub_r, sub_i;
wire signed [WIDTH-1:0] y0_r, y0_i, y1_r, y1_i;

//  Butterfly Input Select
assign  x0_r = bf_en ? dl_odata_r : {WIDTH{1'b0}};
assign  x0_i = bf_en ? dl_odata_i : {WIDTH{1'b0}};
assign  x1_r = bf_mj_en ?  idata_i : bf_en ? idata_r : {WIDTH{1'b0}};
assign  x1_i = bf_mj_en ? -idata_r : bf_en ? idata_i : {WIDTH{1'b0}};

//  Butterfly Add/Sub
assign  add_r = x0_r + x1_r;
assign  add_i = x0_i + x1_i;
assign  sub_r = x0_r - x1_r;
assign  sub_i = x0_i - x1_i;

//  Scaling and Output
assign  y0_r = (add_r + 1'b1) >> 1;
assign  y0_i = (add_i + 1'b1) >> 1;
assign  y1_r = (sub_r + 1'b1) >> 1;
assign  y1_i = (sub_i + 1'b1) >> 1;

//  DelayBuf Input Select
assign  dl_idata_r = bf_en ? y1_r : idata_r;
assign  dl_idata_i = bf_en ? y1_i : idata_i;

//  Single-Path Butterfly Output
assign  odata_r = bf_en ? y0_r : dl_odata_r;
assign  odata_i = bf_en ? y0_i : dl_odata_i;

endmodule
