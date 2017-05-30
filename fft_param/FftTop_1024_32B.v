//----------------------------------------------------------------------
//  FftTop: 1024-Point 32-Bit FFT
//----------------------------------------------------------------------
module FftTop #(
    parameter   WIDTH = 32      //  Data Word Length
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
SdfUnit #(.N(1024),.STAGE(1),.WIDTH(WIDTH),.TW_FF(1),.TW_REDUCE(1)) SU1 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (idata_en       ),  //  i
    .idata_r    (idata_r        ),  //  i
    .idata_i    (idata_i        ),  //  i
    .odata_en   (su1_odata_en   ),  //  o
    .odata_r    (su1_odata_r    ),  //  o
    .odata_i    (su1_odata_i    )   //  o
);

SdfUnit #(.N(1024),.STAGE(2),.WIDTH(WIDTH),.TW_FF(1),.TW_REDUCE(1)) SU2 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su1_odata_en   ),  //  i
    .idata_r    (su1_odata_r    ),  //  i
    .idata_i    (su1_odata_i    ),  //  i
    .odata_en   (su2_odata_en   ),  //  o
    .odata_r    (su2_odata_r    ),  //  o
    .odata_i    (su2_odata_i    )   //  o
);

SdfUnit #(.N(1024),.STAGE(3),.WIDTH(WIDTH),.TW_FF(0),.TW_REDUCE(0)) SU3 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su2_odata_en   ),  //  i
    .idata_r    (su2_odata_r    ),  //  i
    .idata_i    (su2_odata_i    ),  //  i
    .odata_en   (su3_odata_en   ),  //  o
    .odata_r    (su3_odata_r    ),  //  o
    .odata_i    (su3_odata_i    )   //  o
);

SdfUnit #(.N(1024),.STAGE(4),.WIDTH(WIDTH),.TW_FF(0),.TW_REDUCE(0)) SU4 (
    .clock      (clock          ),  //  i
    .reset      (reset          ),  //  i
    .idata_en   (su3_odata_en   ),  //  i
    .idata_r    (su3_odata_r    ),  //  i
    .idata_i    (su3_odata_i    ),  //  i
    .odata_en   (su4_odata_en   ),  //  o
    .odata_r    (su4_odata_r    ),  //  o
    .odata_i    (su4_odata_i    )   //  o
);

SdfUnit #(.N(1024),.STAGE(5),.WIDTH(WIDTH),.TW_FF(0),.TW_REDUCE(0)) SU5 (
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
