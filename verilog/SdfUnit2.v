//----------------------------------------------------------------------
//  SdfUnit2: Radix-2 SDF Dedicated for Twiddle Resolution M = 2
//----------------------------------------------------------------------
module SdfUnit2 #(
    parameter   WIDTH = 16      //  Data Bit Length
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
reg             bf_en;          //  Butterfly Add/Sub Enable
wire[WIDTH-1:0] x0_r;           //  Data #0 to Butterfly (Real)
wire[WIDTH-1:0] x0_i;           //  Data #0 to Butterfly (Imag)
wire[WIDTH-1:0] x1_r;           //  Data #1 to Butterfly (Real)
wire[WIDTH-1:0] x1_i;           //  Data #1 to Butterfly (Imag)
wire[WIDTH-1:0] y0_r;           //  Data #0 from Butterfly (Real)
wire[WIDTH-1:0] y0_i;           //  Data #0 from Butterfly (Imag)
wire[WIDTH-1:0] y1_r;           //  Data #1 from Butterfly (Real)
wire[WIDTH-1:0] y1_i;           //  Data #1 from Butterfly (Imag)
wire[WIDTH-1:0] db_din_r;       //  Data to DelayBuffer (Real)
wire[WIDTH-1:0] db_din_i;       //  Data to DelayBuffer (Imag)
wire[WIDTH-1:0] db_dout_r;      //  Data from DelayBuffer (Real)
wire[WIDTH-1:0] db_dout_i;      //  Data from DelayBuffer (Imag)
wire[WIDTH-1:0] sdout_r;        //  Single-Path Data Output (Real)
wire[WIDTH-1:0] sdout_i;        //  Single-Path Data Output (Imag)
reg             sdout_en;       //  Single-Path Data Enable

//----------------------------------------------------------------------
//  Butterfly Add/Sub
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf_en <= 1'b0;
    end else begin
        bf_en <= idata_en ? ~bf_en : 1'b0;
    end
end

//  The following logic is redundant, but makes it easier to check the waveform.
assign  x0_r = bf_en ? db_dout_r : {WIDTH{1'b0}};
assign  x0_i = bf_en ? db_dout_i : {WIDTH{1'b0}};
assign  x1_r = bf_en ? idata_r : {WIDTH{1'b0}};
assign  x1_i = bf_en ? idata_i : {WIDTH{1'b0}};

Butterfly #(.WIDTH(WIDTH)) BF (
    .x0_r   (x0_r   ),  //  i
    .x0_i   (x0_i   ),  //  i
    .x1_r   (x1_r   ),  //  i
    .x1_i   (x1_i   ),  //  i
    .y0_r   (y0_r   ),  //  o
    .y0_i   (y0_i   ),  //  o
    .y1_r   (y1_r   ),  //  o
    .y1_i   (y1_i   )   //  o
);

DelayBuffer #(.DEPTH(1),.WIDTH(WIDTH)) DB (
    .clock  (clock      ),  //  i
    .din_r  (db_din_r   ),  //  i
    .din_i  (db_din_i   ),  //  i
    .dout_r (db_dout_r  ),  //  o
    .dout_i (db_dout_i  )   //  o
);

assign  db_din_r = bf_en ? y1_r : idata_r;
assign  db_din_i = bf_en ? y1_i : idata_i;
assign  sdout_r = bf_en ? y0_r : db_dout_r;
assign  sdout_i = bf_en ? y0_i : db_dout_i;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        sdout_en <= 1'b0;
        odata_en <= 1'b0;
    end else begin
        sdout_en <= idata_en;
        odata_en <= sdout_en;
    end
end

always @(posedge clock) begin
    odata_r <= sdout_r;
    odata_i <= sdout_i;
end

endmodule
