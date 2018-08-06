//----------------------------------------------------------------------
//  FFT: 1024-Point FFT Using Radix-2^2 Single-Path Delay Feedback
//----------------------------------------------------------------------
module FFT #(
    parameter   WIDTH = 32
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
//  Internal Nets
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
wire            su4_odata_en;
wire[WIDTH-1:0] su4_odata_r;
wire[WIDTH-1:0] su4_odata_i;

//----------------------------------------------------------------------
//  Module Instances
//----------------------------------------------------------------------
SdfUnit #(.N(1024),.M(1024),.WIDTH(WIDTH)) SU1 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (idata_en       ),  //  i
    .idata_r    (idata_r        ),  //  i
    .idata_i    (idata_i        ),  //  i
    .odata_en   (su1_odata_en   ),  //  o
    .odata_r    (su1_odata_r    ),  //  o
    .odata_i    (su1_odata_i    )   //  o
);

SdfUnit #(.N(1024),.M(256),.WIDTH(WIDTH)) SU2 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su1_odata_en   ),  //  i
    .idata_r    (su1_odata_r    ),  //  i
    .idata_i    (su1_odata_i    ),  //  i
    .odata_en   (su2_odata_en   ),  //  o
    .odata_r    (su2_odata_r    ),  //  o
    .odata_i    (su2_odata_i    )   //  o
);

SdfUnit #(.N(1024),.M(64),.WIDTH(WIDTH)) SU3 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su2_odata_en   ),  //  i
    .idata_r    (su2_odata_r    ),  //  i
    .idata_i    (su2_odata_i    ),  //  i
    .odata_en   (su3_odata_en   ),  //  o
    .odata_r    (su3_odata_r    ),  //  o
    .odata_i    (su3_odata_i    )   //  o
);

SdfUnit #(.N(1024),.M(16),.WIDTH(WIDTH)) SU4 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su3_odata_en   ),  //  i
    .idata_r    (su3_odata_r    ),  //  i
    .idata_i    (su3_odata_i    ),  //  i
    .odata_en   (su4_odata_en   ),  //  o
    .odata_r    (su4_odata_r    ),  //  o
    .odata_i    (su4_odata_i    )   //  o
);

SdfUnit #(.N(1024),.M(4),.WIDTH(WIDTH)) SU5 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su4_odata_en   ),  //  i
    .idata_r    (su4_odata_r    ),  //  i
    .idata_i    (su4_odata_i    ),  //  i
    .odata_en   (odata_en       ),  //  o
    .odata_r    (odata_r        ),  //  o
    .odata_i    (odata_i        )   //  o
);

endmodule
