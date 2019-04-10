//----------------------------------------------------------------------
//  SdfUnit: Radix-2^2 Single-Path Delay Feedback Unit for N-Point FFT
//----------------------------------------------------------------------
module SdfUnit #(
    parameter   N = 64,         //  Number of FFT Point
    parameter   M = 64,         //  Twiddle Resolution
    parameter   WIDTH = 16      //  Data Bit Length
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
reg             bf2_start;      //  Single-Path Output Trigger
wire            bf2_end;        //  End of Single-Path Data
reg [WIDTH-1:0] bf2_odata_r;    //  2nd Butterfly Output Data (Real)
reg [WIDTH-1:0] bf2_odata_i;    //  2nd Butterfly Output Data (Imag)
reg             bf2_odata_en;   //  2nd Butterfly Output Data Enable

//  Multiplication
wire[1:0]       tw_sel;         //  Twiddle Select (2n/n/3n)
wire[LOG_N-3:0] tw_num;         //  Twiddle Number (n)
wire[LOG_N-1:0] tw_addr;        //  Twiddle Table Address
wire[WIDTH-1:0] tw_data_r;      //  Twiddle Data from Table (Real)
wire[WIDTH-1:0] tw_data_i;      //  Twiddle Data from Table (Imag)
reg             mu_addr_nz;     //  Multiplication Enable
wire[WIDTH-1:0] mu_idata_r;     //  Multiplier Input (Real)
wire[WIDTH-1:0] mu_idata_i;     //  Multiplier Input (Imag)
wire[WIDTH-1:0] mu_mdata_r;     //  Multiplier Output (Real)
wire[WIDTH-1:0] mu_mdata_i;     //  Multiplier Output (Imag)
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

//  Set unknown value x for verification
assign  bf1_x0_r = bf1_bf ? db1_dout_r : {WIDTH{1'bx}};
assign  bf1_x0_i = bf1_bf ? db1_dout_i : {WIDTH{1'bx}};
assign  bf1_x1_r = bf1_bf ? idata_r : {WIDTH{1'bx}};
assign  bf1_x1_i = bf1_bf ? idata_i : {WIDTH{1'bx}};

Butterfly #(.WIDTH(WIDTH),.RH(0)) BF1 (
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

//  Set unknown value x for verification
assign  bf2_x0_r = bf2_bf ? db2_dout_r : {WIDTH{1'bx}};
assign  bf2_x0_i = bf2_bf ? db2_dout_i : {WIDTH{1'bx}};
assign  bf2_x1_r = bf2_bf ? bf1_odata_r : {WIDTH{1'bx}};
assign  bf2_x1_i = bf2_bf ? bf1_odata_i : {WIDTH{1'bx}};

//  Negative bias occurs when RH=0 and positive bias occurs when RH=1.
//  Using both alternately reduces the overall rounding error.
Butterfly #(.WIDTH(WIDTH),.RH(1)) BF2 (
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

always @(posedge clock) begin
    bf2_start <= (bf1_count == (2**(LOG_M-2)-1)) & bf1_count_en;
end
assign  bf2_end = (bf2_count == (2**LOG_N-1));

always @(posedge clock) begin
    bf2_odata_r  <= bf2_sdout_r;
    bf2_odata_i  <= bf2_sdout_i;
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf2_odata_en <= 1'b0;
    end else begin
        bf2_odata_en <= bf2_count_en;
    end
end

//----------------------------------------------------------------------
//  Multiplication
//----------------------------------------------------------------------
assign  tw_sel[1] = bf2_count[LOG_M-2];
assign  tw_sel[0] = bf2_count[LOG_M-1];
assign  tw_num = bf2_count << (LOG_N-LOG_M);
assign  tw_addr = tw_num * tw_sel;

Twiddle TW (
    .clock  (clock      ),  //  i
    .addr   (tw_addr    ),  //  i
    .data_r (tw_data_r  ),  //  o
    .data_i (tw_data_i  )   //  o
);

//  Set unknown value x for verification
always @(posedge clock) begin
    mu_addr_nz <= (tw_addr != {LOG_N{1'b0}});
end
assign  mu_idata_r = mu_addr_nz ? bf2_odata_r : {WIDTH{1'bx}};
assign  mu_idata_i = mu_addr_nz ? bf2_odata_i : {WIDTH{1'bx}};

Multiply #(.WIDTH(WIDTH)) MU (
    .ar (mu_idata_r ),  //  i
    .ai (mu_idata_i ),  //  i
    .br (tw_data_r  ),  //  i
    .bi (tw_data_i  ),  //  i
    .mr (mu_mdata_r ),  //  o
    .mi (mu_mdata_i )   //  o
);

//  When twiddle number n is not 0, multiplication is performed.
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
