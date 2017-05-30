//----------------------------------------------------------------------
//  SdfUnitLast: Radix-2^2 SDF Last Stage
//----------------------------------------------------------------------
module SdfUnitLast #(
    parameter   WIDTH = 16      //  Data Word Length
)(
    input                   clock,      //  Master Clock
    input                   reset,      //  Active High Asynchronous Reset
    input                   idata_en,   //  Input Data Enable
    input       [WIDTH-1:0] idata_r,    //  Input Data (Real)
    input       [WIDTH-1:0] idata_i,    //  Input Data (Imag)
    output  reg             odata_en,   //  Output Data Enable
    output  reg [WIDTH-1:0] odata_r,    //  Output Data (Real)
    output  reg [WIDTH-1:0] odata_i     //  Output Data (Imag)
);

//----------------------------------------------------------------------
//  Internal Regs and Nets
//----------------------------------------------------------------------
reg                 bf_odata_en;    //  Butterfly Output Data Enable
reg                 bf_en;          //  Butterfly Enable
wire[WIDTH-1:0]     dl_idata_r;     //  DelayBuf Input Data (Real)
wire[WIDTH-1:0]     dl_idata_i;     //  DelayBuf Input Data (Imag)
wire[WIDTH-1:0]     dl_odata_r;     //  DelayBuf Output Data (Real)
wire[WIDTH-1:0]     dl_odata_i;     //  DelayBuf Output Data (Imag)
wire[WIDTH-1:0]     bf_odata_r;     //  Butterfly Output Data (Real)
wire[WIDTH-1:0]     bf_odata_i;     //  Butterfly Output Data (Imag)

//----------------------------------------------------------------------
//  Butterfly Control
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf_odata_en <= 1'b0;
        bf_en <= 1'b0;
    end else begin
        bf_odata_en <= idata_en;
        bf_en <= idata_en ? ~bf_en : 1'b0;
    end
end

Butterfly #(.WIDTH(WIDTH)) BF (
    .bf_en      (bf_en      ),  //  i
    .bf_mj_en   (1'b0       ),  //  i
    .idata_r    (idata_r    ),  //  i
    .idata_i    (idata_i    ),  //  i
    .dl_odata_r (dl_odata_r ),  //  i
    .dl_odata_i (dl_odata_i ),  //  i
    .dl_idata_r (dl_idata_r ),  //  o
    .dl_idata_i (dl_idata_i ),  //  o
    .odata_r    (bf_odata_r ),  //  o
    .odata_i    (bf_odata_i )   //  o
);

DelayBuf #(.DEPTH(1),.WIDTH(WIDTH)) DL (
    .clock      (clock      ),  //  i
    .idata_r    (dl_idata_r ),  //  i
    .idata_i    (dl_idata_i ),  //  i
    .odata_r    (dl_odata_r ),  //  o
    .odata_i    (dl_odata_i )   //  o
);

//----------------------------------------------------------------------
//  Data Output
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        odata_en <= 1'b0;
    end else begin
        odata_en <= bf_odata_en;
    end
end

always @(posedge clock) begin
    odata_r <= bf_odata_r;
    odata_i <= bf_odata_i;
end

endmodule
