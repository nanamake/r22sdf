//----------------------------------------------------------------------
//  FFT: 128-Point FFT Using Radix-2^2 Single-Path Delay Feedback
//----------------------------------------------------------------------
module FFT #(
    parameter   WIDTH = 16
)(
    input               clock,      //  Master Clock
    input               reset,      //  Active High Asynchronous Reset
    input               idata_en,   //  Input Data Enable
    input   [WIDTH-1:0] idata_r,    //  Input Data (Real)
    input   [WIDTH-1:0] idata_i,    //  Input Data (Imag)
    output              odata_en,   //  Output Data Enable
    output  [WIDTH-1:0] odata_r,    //  Output Data (Real)
    output  [WIDTH-1:0] odata_i     //  Output Data (Imag)
);
//----------------------------------------------------------------------
//  Data must be input consecutively in natural order.
//  The result is scaled to 1/N and output in bit-reversed order.
//  The output latency is 137 clock cycles.
//----------------------------------------------------------------------

wire            su1_odata_en;
wire[WIDTH-1:0] su1_odata_r;
wire[WIDTH-1:0] su1_odata_i;
wire            su2_odata_en;
wire[WIDTH-1:0] su2_odata_r;
wire[WIDTH-1:0] su2_odata_i;
wire            su3_odata_en;
wire[WIDTH-1:0] su3_odata_r;
wire[WIDTH-1:0] su3_odata_i;

SdfUnit #(.N(128),.M(128),.WIDTH(WIDTH)) SU1 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (idata_en       ),  //  i
    .idata_r    (idata_r        ),  //  i
    .idata_i    (idata_i        ),  //  i
    .odata_en   (su1_odata_en   ),  //  o
    .odata_r    (su1_odata_r    ),  //  o
    .odata_i    (su1_odata_i    )   //  o
);

SdfUnit #(.N(128),.M(32),.WIDTH(WIDTH)) SU2 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su1_odata_en   ),  //  i
    .idata_r    (su1_odata_r    ),  //  i
    .idata_i    (su1_odata_i    ),  //  i
    .odata_en   (su2_odata_en   ),  //  o
    .odata_r    (su2_odata_r    ),  //  o
    .odata_i    (su2_odata_i    )   //  o
);

SdfUnit #(.N(128),.M(8),.WIDTH(WIDTH)) SU3 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su2_odata_en   ),  //  i
    .idata_r    (su2_odata_r    ),  //  i
    .idata_i    (su2_odata_i    ),  //  i
    .odata_en   (su3_odata_en   ),  //  o
    .odata_r    (su3_odata_r    ),  //  o
    .odata_i    (su3_odata_i    )   //  o
);

SdfUnit2 #(.WIDTH(WIDTH)) SU4 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su3_odata_en   ),  //  i
    .idata_r    (su3_odata_r    ),  //  i
    .idata_i    (su3_odata_i    ),  //  i
    .odata_en   (odata_en       ),  //  o
    .odata_r    (odata_r        ),  //  o
    .odata_i    (odata_i        )   //  o
);

endmodule
