//----------------------------------------------------------------------
//  SdfUnit: Radix-2^2 SDF Unit with Twiddle Conversion
//----------------------------------------------------------------------
module SdfUnit #(
    parameter   N = 64,         //  Number of FFT Point
    parameter   M = 64,         //  Twiddle Resolution
    parameter   WIDTH = 16,     //  Data Bit Length
    parameter   TC_EN = 1,      //  Twiddle Conversion Enable
    parameter   TW_FF = 1       //  Use Twiddle Output Register
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

//  log2 constant function
function integer log2;
    input integer x;
    integer value;
    begin
        value = x-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

localparam  LOG_N = log2(N);    //  Bit Length of N
localparam  LOG_M = log2(M);    //  Bit Length of M

//----------------------------------------------------------------------
//  Internal Regs and Nets
//----------------------------------------------------------------------
//  1st Butterfly
reg [LOG_N-1:0] idata_count;    //  Input Data Count
wire            bf1_bf;         //  Butterfly Add/Sub Enable
wire[WIDTH-1:0] bf1_x0_r;       //  Data #0 to Butterfly (Real)
wire[WIDTH-1:0] bf1_x0_i;       //  Data #0 to Butterfly (Imag)
wire[WIDTH-1:0] bf1_x1_r;       //  Data #1 to Butterfly (Real)
wire[WIDTH-1:0] bf1_x1_i;       //  Data #1 to Butterfly (Imag)
wire[WIDTH-1:0] bf1_y0_r;       //  Data #0 from Butterfly (Real)
wire[WIDTH-1:0] bf1_y0_i;       //  Data #0 from Butterfly (Imag)
wire[WIDTH-1:0] bf1_y1_r;       //  Data #1 from Butterfly (Real)
wire[WIDTH-1:0] bf1_y1_i;       //  Data #1 from Butterfly (Imag)
wire[WIDTH-1:0] db1_din_r;      //  Data to DelayBuffer (Real)
wire[WIDTH-1:0] db1_din_i;      //  Data to DelayBuffer (Imag)
wire[WIDTH-1:0] db1_dout_r;     //  Data from DelayBuffer (Real)
wire[WIDTH-1:0] db1_dout_i;     //  Data from DelayBuffer (Imag)
wire[WIDTH-1:0] bf1_sdout_r;    //  Single-Path Data Output (Real)
wire[WIDTH-1:0] bf1_sdout_i;    //  Single-Path Data Output (Imag)
reg             bf1_count_en;   //  Single-Path Data Count Enable
reg [LOG_N-1:0] bf1_count;      //  Single-Path Data Count
wire            bf1_start;      //  Single-Path Output Trigger
wire            bf1_end;        //  End of Single-Path Data
wire            bf1_mj;         //  Twiddle (-j) Enable
reg [WIDTH-1:0] bf1_odata_r;    //  1st Butterfly Output Data (Real)
reg [WIDTH-1:0] bf1_odata_i;    //  1st Butterfly Output Data (Imag)

//  2nd Butterfly
reg             bf2_bf;         //  Butterfly Add/Sub Enable
wire[WIDTH-1:0] bf2_x0_r;       //  Data #0 to Butterfly (Real)
wire[WIDTH-1:0] bf2_x0_i;       //  Data #0 to Butterfly (Imag)
wire[WIDTH-1:0] bf2_x1_r;       //  Data #1 to Butterfly (Real)
wire[WIDTH-1:0] bf2_x1_i;       //  Data #1 to Butterfly (Imag)
wire[WIDTH-1:0] bf2_y0_r;       //  Data #0 from Butterfly (Real)
wire[WIDTH-1:0] bf2_y0_i;       //  Data #0 from Butterfly (Imag)
wire[WIDTH-1:0] bf2_y1_r;       //  Data #1 from Butterfly (Real)
wire[WIDTH-1:0] bf2_y1_i;       //  Data #1 from Butterfly (Imag)
wire[WIDTH-1:0] db2_din_r;      //  Data to DelayBuffer (Real)
wire[WIDTH-1:0] db2_din_i;      //  Data to DelayBuffer (Imag)
wire[WIDTH-1:0] db2_dout_r;     //  Data from DelayBuffer (Real)
wire[WIDTH-1:0] db2_dout_i;     //  Data from DelayBuffer (Imag)
wire[WIDTH-1:0] bf2_sdout_r;    //  Single-Path Data Output (Real)
wire[WIDTH-1:0] bf2_sdout_i;    //  Single-Path Data Output (Imag)
reg             bf2_count_en;   //  Single-Path Data Count Enable
reg [LOG_N-1:0] bf2_count;      //  Single-Path Data Count
wire            bf2_trig;       //  Single-Path Output Trigger
reg             bf2_trig_ff;    //  Single-Path Output Trigger
wire            bf2_start;      //  Single-Path Output Trigger
wire            bf2_end;        //  End of Single-Path Data
reg             bf2_count_en_1d;//  Single-Path Data Enable When Using TC
reg             bf2_odata_en;   //  2nd Butterfly Output Data Enable
reg [WIDTH-1:0] bf2_odata_r;    //  2nd Butterfly Output Data (Real)
reg [WIDTH-1:0] bf2_odata_i;    //  2nd Butterfly Output Data (Imag)

//  Multiplication
wire[1:0]       tw_sel;         //  Twiddle Select (2n/n/3n)
wire[LOG_N-3:0] tw_num;         //  Twiddle Number (n)
wire[LOG_N-1:0] tw_addr;        //  Twiddle Table Address
wire[LOG_N-4:0] tc_oaddr;       //  Twiddle Address from TwiddleConvert
wire[LOG_N-1:0] tw_addr_tc;     //  Twiddle Address after TC_EN Switch
wire[WIDTH-1:0] tw_data_r;      //  Twiddle Data from Table (Real)
wire[WIDTH-1:0] tw_data_i;      //  Twiddle Data from Table (Imag)
wire[WIDTH-1:0] tc_odata_r;     //  Twiddle Data from TwiddleConvert (Real)
wire[WIDTH-1:0] tc_odata_i;     //  Twiddle Data from TwiddleConvert (Imag)
wire[WIDTH-1:0] mu_tdata_r;     //  Twiddle Data to Multiplier (Real)
wire[WIDTH-1:0] mu_tdata_i;     //  Twiddle Data to Multiplier (Imag)
wire[WIDTH-1:0] mu_mdata_r;     //  Multiplier Output (Real)
wire[WIDTH-1:0] mu_mdata_i;     //  Multiplier Output (Imag)
reg             tw_addr_nz;     //  Multiplication Enable When not Using TC
reg             tc_addr_nz;     //  Multiplication Enable When Using TC
wire            mu_addr_nz;     //  Multiplication Enable
reg [WIDTH-1:0] mu_odata_r;     //  Multiplication Output Data (Real)
reg [WIDTH-1:0] mu_odata_i;     //  Multiplication Output Data (Imag)
reg             mu_odata_en;    //  Multiplication Output Data Enable

//----------------------------------------------------------------------
//  1st Butterfly
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        idata_count <= {LOG_N{1'b0}};
    end else begin
        idata_count <= idata_en ? (idata_count + 1'b1) : {LOG_N{1'b0}};
    end
end
assign  bf1_bf = idata_count[LOG_M-1];

//  The following logic is redundant, but makes it easier to check the waveform.
//  It may also reduce power consumption slightly.
assign  bf1_x0_r = bf1_bf ? db1_dout_r : {WIDTH{1'b0}};
assign  bf1_x0_i = bf1_bf ? db1_dout_i : {WIDTH{1'b0}};
assign  bf1_x1_r = bf1_bf ? idata_r : {WIDTH{1'b0}};
assign  bf1_x1_i = bf1_bf ? idata_i : {WIDTH{1'b0}};

Butterfly #(.WIDTH(WIDTH)) BF1 (
    .x0_r   (bf1_x0_r   ),  //  i
    .x0_i   (bf1_x0_i   ),  //  i
    .x1_r   (bf1_x1_r   ),  //  i
    .x1_i   (bf1_x1_i   ),  //  i
    .y0_r   (bf1_y0_r   ),  //  o
    .y0_i   (bf1_y0_i   ),  //  o
    .y1_r   (bf1_y1_r   ),  //  o
    .y1_i   (bf1_y1_i   )   //  o
);

DelayBuffer #(.DEPTH(2**(LOG_M-1)),.WIDTH(WIDTH)) DB1 (
    .clock  (clock      ),  //  i
    .din_r  (db1_din_r  ),  //  i
    .din_i  (db1_din_i  ),  //  i
    .dout_r (db1_dout_r ),  //  o
    .dout_i (db1_dout_i )   //  o
);

assign  db1_din_r = bf1_bf ? bf1_y1_r : idata_r;
assign  db1_din_i = bf1_bf ? bf1_y1_i : idata_i;
assign  bf1_sdout_r = bf1_bf ? bf1_y0_r : bf1_mj ?  db1_dout_i : db1_dout_r;
assign  bf1_sdout_i = bf1_bf ? bf1_y0_i : bf1_mj ? -db1_dout_r : db1_dout_i;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf1_count_en <= 1'b0;
        bf1_count    <= {LOG_N{1'b0}};
    end else begin
        bf1_count_en <= bf1_start ? 1'b1 : bf1_end ? 1'b0 : bf1_count_en;
        bf1_count    <= bf1_count_en ? (bf1_count + 1'b1) : {LOG_N{1'b0}};
    end
end
assign  bf1_start = (idata_count == (2**(LOG_M-1)-1));
assign  bf1_end = (bf1_count == (2**LOG_N-1));
assign  bf1_mj = (bf1_count[LOG_M-1:LOG_M-2] == 2'd3);

always @(posedge clock) begin
    bf1_odata_r <= bf1_sdout_r;
    bf1_odata_i <= bf1_sdout_i;
end

//----------------------------------------------------------------------
//  2nd Butterfly
//----------------------------------------------------------------------
always @(posedge clock) begin
    bf2_bf <= bf1_count[LOG_M-2];
end

//  The following logic is redundant, but makes it easier to check the waveform.
//  It may also reduce power consumption slightly.
assign  bf2_x0_r = bf2_bf ? db2_dout_r : {WIDTH{1'b0}};
assign  bf2_x0_i = bf2_bf ? db2_dout_i : {WIDTH{1'b0}};
assign  bf2_x1_r = bf2_bf ? bf1_odata_r : {WIDTH{1'b0}};
assign  bf2_x1_i = bf2_bf ? bf1_odata_i : {WIDTH{1'b0}};

Butterfly #(.WIDTH(WIDTH)) BF2 (
    .x0_r   (bf2_x0_r   ),  //  i
    .x0_i   (bf2_x0_i   ),  //  i
    .x1_r   (bf2_x1_r   ),  //  i
    .x1_i   (bf2_x1_i   ),  //  i
    .y0_r   (bf2_y0_r   ),  //  o
    .y0_i   (bf2_y0_i   ),  //  o
    .y1_r   (bf2_y1_r   ),  //  o
    .y1_i   (bf2_y1_i   )   //  o
);

DelayBuffer #(.DEPTH(2**(LOG_M-2)),.WIDTH(WIDTH)) DB2 (
    .clock  (clock      ),  //  i
    .din_r  (db2_din_r  ),  //  i
    .din_i  (db2_din_i  ),  //  i
    .dout_r (db2_dout_r ),  //  o
    .dout_i (db2_dout_i )   //  o
);

assign  db2_din_r = bf2_bf ? bf2_y1_r : bf1_odata_r;
assign  db2_din_i = bf2_bf ? bf2_y1_i : bf1_odata_i;
assign  bf2_sdout_r = bf2_bf ? bf2_y0_r : db2_dout_r;
assign  bf2_sdout_i = bf2_bf ? bf2_y0_i : db2_dout_i;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf2_count_en <= 1'b0;
        bf2_count    <= {LOG_N{1'b0}};
    end else begin
        bf2_count_en <= bf2_start ? 1'b1 : bf2_end ? 1'b0 : bf2_count_en;
        bf2_count    <= bf2_count_en ? (bf2_count + 1'b1) : {LOG_N{1'b0}};
    end
end

assign  bf2_trig = (bf1_count == (2**(LOG_M-2)-1)) & bf1_count_en;
always @(posedge clock) begin
    bf2_trig_ff <= bf2_trig;
end
//  When using TwiddleConvert and Twiddle register, start counting 1T earlier
assign  bf2_start = (TC_EN & TW_FF) ? bf2_trig : bf2_trig_ff;
assign  bf2_end = (bf2_count == (2**LOG_N-1));

always @(posedge clock) begin
    bf2_count_en_1d <= bf2_count_en;
    bf2_odata_en <= (TC_EN & TW_FF) ? bf2_count_en_1d : bf2_count_en;
    bf2_odata_r  <= bf2_sdout_r;
    bf2_odata_i  <= bf2_sdout_i;
end

//----------------------------------------------------------------------
//  Multiplication
//----------------------------------------------------------------------
assign  tw_sel[1] = bf2_count[LOG_M-2];
assign  tw_sel[0] = bf2_count[LOG_M-1];
assign  tw_num = bf2_count << (LOG_N-LOG_M);
assign  tw_addr = tw_num * tw_sel;

Twiddle #(.TW_FF(TW_FF)) TW (
    .clock  (clock      ),  //  i
    .addr   (tw_addr_tc ),  //  i
    .data_r (tw_data_r  ),  //  o
    .data_i (tw_data_i  )   //  o
);

TwiddleConvert #(.LOG_N(LOG_N),.WIDTH(WIDTH),.TW_FF(TW_FF)) TC (
    .clock  (clock      ),  //  i
    .iaddr  (tw_addr    ),  //  i
    .idata_r(tw_data_r  ),  //  i
    .idata_i(tw_data_i  ),  //  i
    .oaddr  (tc_oaddr   ),  //  o
    .odata_r(tc_odata_r ),  //  o
    .odata_i(tc_odata_i )   //  o
);

assign  tw_addr_tc = TC_EN ? {3'd0, tc_oaddr} : tw_addr;
assign  mu_tdata_r = TC_EN ? tc_odata_r : tw_data_r;
assign  mu_tdata_i = TC_EN ? tc_odata_i : tw_data_i;

Multiply #(.WIDTH(WIDTH)) MU (
    .ar (bf2_odata_r),  //  i
    .ai (bf2_odata_i),  //  i
    .br (mu_tdata_r ),  //  i
    .bi (mu_tdata_i ),  //  i
    .mr (mu_mdata_r ),  //  o
    .mi (mu_mdata_i )   //  o
);

//  When twiddle number n is not 0, multiplication is performed.
always @(posedge clock) begin
    tw_addr_nz <= (tw_addr != {LOG_N{1'b0}});
    tc_addr_nz <= tw_addr_nz;
end
//  When using TwiddleConvert and Twiddle register, address generated 1T Earlier
assign  mu_addr_nz = (TC_EN & TW_FF) ? tc_addr_nz : tw_addr_nz;

always @(posedge clock) begin
    mu_odata_r <= mu_addr_nz ? mu_mdata_r : bf2_odata_r;
    mu_odata_i <= mu_addr_nz ? mu_mdata_i : bf2_odata_i;
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        mu_odata_en <= 1'b0;
    end else begin
        mu_odata_en <= bf2_odata_en;
    end
end

//  No multiplication required at final stage
assign  odata_en = (LOG_M == 2) ? bf2_odata_en : mu_odata_en;
assign  odata_r  = (LOG_M == 2) ? bf2_odata_r  : mu_odata_r;
assign  odata_i  = (LOG_M == 2) ? bf2_odata_i  : mu_odata_i;

endmodule
