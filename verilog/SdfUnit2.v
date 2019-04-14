//----------------------------------------------------------------------
//  SdfUnit2: Radix-2 SDF Dedicated for Twiddle Resolution M = 2
//----------------------------------------------------------------------
module SdfUnit2 #(
    parameter   WIDTH = 16, //  Data Bit Length
    parameter   BF_RH = 0   //  Butterfly Round Half Up
)(
    input                   clock,  //  Master Clock
    input                   reset,  //  Active High Asynchronous Reset
    input                   di_en,  //  Input Data Enable
    input       [WIDTH-1:0] di_re,  //  Input Data (Real)
    input       [WIDTH-1:0] di_im,  //  Input Data (Imag)
    output  reg             do_en,  //  Output Data Enable
    output  reg [WIDTH-1:0] do_re,  //  Output Data (Real)
    output  reg [WIDTH-1:0] do_im   //  Output Data (Imag)
);

//----------------------------------------------------------------------
//  Internal Regs and Nets
//----------------------------------------------------------------------
reg             bf_en;      //  Butterfly Add/Sub Enable
wire[WIDTH-1:0] x0_re;      //  Data #0 to Butterfly (Real)
wire[WIDTH-1:0] x0_im;      //  Data #0 to Butterfly (Imag)
wire[WIDTH-1:0] x1_re;      //  Data #1 to Butterfly (Real)
wire[WIDTH-1:0] x1_im;      //  Data #1 to Butterfly (Imag)
wire[WIDTH-1:0] y0_re;      //  Data #0 from Butterfly (Real)
wire[WIDTH-1:0] y0_im;      //  Data #0 from Butterfly (Imag)
wire[WIDTH-1:0] y1_re;      //  Data #1 from Butterfly (Real)
wire[WIDTH-1:0] y1_im;      //  Data #1 from Butterfly (Imag)
wire[WIDTH-1:0] db_di_re;   //  Data to DelayBuffer (Real)
wire[WIDTH-1:0] db_di_im;   //  Data to DelayBuffer (Imag)
wire[WIDTH-1:0] db_do_re;   //  Data from DelayBuffer (Real)
wire[WIDTH-1:0] db_do_im;   //  Data from DelayBuffer (Imag)
wire[WIDTH-1:0] bf_sp_re;   //  Single-Path Data Output (Real)
wire[WIDTH-1:0] bf_sp_im;   //  Single-Path Data Output (Imag)
reg             bf_sp_en;   //  Single-Path Data Enable

//----------------------------------------------------------------------
//  Butterfly Add/Sub
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf_en <= 1'b0;
    end else begin
        bf_en <= di_en ? ~bf_en : 1'b0;
    end
end

//  Set unknown value x for verification
assign  x0_re = bf_en ? db_do_re : {WIDTH{1'bx}};
assign  x0_im = bf_en ? db_do_im : {WIDTH{1'bx}};
assign  x1_re = bf_en ? di_re : {WIDTH{1'bx}};
assign  x1_im = bf_en ? di_im : {WIDTH{1'bx}};

Butterfly #(.WIDTH(WIDTH),.RH(BF_RH)) BF (
    .x0_re  (x0_re  ),  //  i
    .x0_im  (x0_im  ),  //  i
    .x1_re  (x1_re  ),  //  i
    .x1_im  (x1_im  ),  //  i
    .y0_re  (y0_re  ),  //  o
    .y0_im  (y0_im  ),  //  o
    .y1_re  (y1_re  ),  //  o
    .y1_im  (y1_im  )   //  o
);

DelayBuffer #(.DEPTH(1),.WIDTH(WIDTH)) DB (
    .clock  (clock      ),  //  i
    .di_re  (db_di_re   ),  //  i
    .di_im  (db_di_im   ),  //  i
    .do_re  (db_do_re   ),  //  o
    .do_im  (db_do_im   )   //  o
);

assign  db_di_re = bf_en ? y1_re : di_re;
assign  db_di_im = bf_en ? y1_im : di_im;
assign  bf_sp_re = bf_en ? y0_re : db_do_re;
assign  bf_sp_im = bf_en ? y0_im : db_do_im;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf_sp_en <= 1'b0;
        do_en <= 1'b0;
    end else begin
        bf_sp_en <= di_en;
        do_en <= bf_sp_en;
    end
end

always @(posedge clock) begin
    do_re <= bf_sp_re;
    do_im <= bf_sp_im;
end

endmodule
