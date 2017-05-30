//----------------------------------------------------------------------
//  SdfUnit: Radix-2^2 Single-Path Delay Feedback Unit
//----------------------------------------------------------------------
module SdfUnit #(
    parameter   N = 64,
    parameter   STAGE = 1,
    parameter   WIDTH = 16,         //  Data Word Length
    parameter   TW_FF = 0,          //  Twiddle Table Output Register
    parameter   TW_REDUCE = 0       //  Twiddle Table Size Reduction
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

localparam      NN = log2(N);   //  FFT Point Counter Size

//  Butterfly1 Control
reg [NN-1:0]    idata_count;    //  Input Data Count
wire            bf1_en;         //  Butterfly Add/Sub Enable
wire[WIDTH-1:0] de1_idata_r;    //  DelayBuf Input Data (Real)
wire[WIDTH-1:0] de1_idata_i;    //  DelayBuf Input Data (Imag)
wire[WIDTH-1:0] de1_odata_r;    //  DelayBuf Output Data (Real)
wire[WIDTH-1:0] de1_odata_i;    //  DelayBuf Output Data (Imag)
wire[WIDTH-1:0] bf1_odata_r;    //  Butterfly Output Data (Real)
wire[WIDTH-1:0] bf1_odata_i;    //  Butterfly Output Data (Imag)
wire            bf1_start;      //  Butterfly Output Start Timing
reg             bf1_odata_en;   //  Butterfly Output Data Enable
reg [NN-1:0]    bf1_count;      //  Butterfly Output Data Count
wire            bf1_end;        //  End of Butterfly Output Data

//  Butterfly2 Control
reg [WIDTH-1:0] bf2_idata_r;    //  Butterfly Input Data (Real)
reg [WIDTH-1:0] bf2_idata_i;    //  Butterfly Input Data (Imag)
reg             bf2_en;         //  Butterfly Enable
reg             bf2_mj_en;      //  Twiddle (-j) Enable
wire[WIDTH-1:0] de2_idata_r;    //  DelayBuf Input Data (Real)
wire[WIDTH-1:0] de2_idata_i;    //  DelayBuf Input Data (Imag)
wire[WIDTH-1:0] de2_odata_r;    //  DelayBuf Output Data (Real)
wire[WIDTH-1:0] de2_odata_i;    //  DelayBuf Output Data (Imag)
wire[WIDTH-1:0] bf2_odata_r;    //  Butterfly Output Data (Real)
wire[WIDTH-1:0] bf2_odata_i;    //  Butterfly Output Data (Imag)
wire            bf2_start_dec;  //  Butterfly Start Timing Decode
reg             bf2_start;      //  Butterfly Start Timing
wire            bf2_ct_start;   //  Butterfly Count Start Timing
reg             bf2_ct_en;      //  Butterfly Output Count Enable
reg [NN-1:0]    bf2_count;      //  Butterfly Output Count
wire            bf2_ct_end;     //  End of Butterfly Output Count
reg             bf2_ct_en_1d;   //  bf2_ct_en 1T Delay
wire            bf2_odata_en;   //  Butterfly Output Data Enable

//  Twiddle Control
wire[1:0]       tw_sel;         //  Twiddle Select
wire            tw_en;          //  Twiddle Enable
wire[NN-3:0]    tw_num;         //  Twiddle Number
wire[NN-1:0]    tw_addr;        //  Twiddle Address
reg [WIDTH-1:0] tw_data_r;      //  Twiddle Data (Real)
reg [WIDTH-1:0] tw_data_i;      //  Twiddle Data (Imag)
reg [NN-1:0]    tw_tab_addr;    //  Twiddle Table Address
wire[WIDTH-1:0] tw_tab_data_r;  //  Twiddle Table Data (Real)
wire[WIDTH-1:0] tw_tab_data_i;  //  Twiddle Table Data (Imag)
wire[NN-1:0]    tw_red_addr;    //  TabReduce Twiddle Address
wire[WIDTH-1:0] tw_red_data_r;  //  TabReduce Twiddle Data (Real)
wire[WIDTH-1:0] tw_red_data_i;  //  TabReduce Twiddle Data (Imag)
reg [NN-1:0]    tw_addr_1d;     //  tw_addr 1T Delay
wire[NN-1:0]    tw_addr_sel;    //  Twiddle Address for Data Select

//  Complex Multiplier
reg             cm_idata_en;    //  Multiplier Input Data Enable
reg             cm_en;          //  Multiplier Enable
reg [WIDTH-1:0] cm_idata_r;     //  Multiplier Data Input (Real)
reg [WIDTH-1:0] cm_idata_i;     //  Multiplier Data Input (Imag)
reg [WIDTH-1:0] cm_tdata_r;     //  Multiplier Twiddle Input (Real)
reg [WIDTH-1:0] cm_tdata_i;     //  Multiplier Twiddle Input (Imag)
wire[WIDTH-1:0] cm_odata_r;     //  Multiplier Data Output (Real)
wire[WIDTH-1:0] cm_odata_i;     //  Multiplier Data Output (Imag)

//----------------------------------------------------------------------
//  Butterfly1 Control
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        idata_count <= {NN{1'b0}};
    end else begin
        idata_count <= idata_en ? (idata_count + 1'b1) : {NN{1'b0}};
    end
end

assign  bf1_en = idata_count[NN-(2*STAGE)+1];

Butterfly #(.WIDTH(WIDTH)) BF1 (
    .bf_en      (bf1_en     ),  //  i
    .bf_mj_en   (1'b0       ),  //  i
    .idata_r    (idata_r    ),  //  i
    .idata_i    (idata_i    ),  //  i
    .dl_odata_r (de1_odata_r),  //  i
    .dl_odata_i (de1_odata_i),  //  i
    .dl_idata_r (de1_idata_r),  //  o
    .dl_idata_i (de1_idata_i),  //  o
    .odata_r    (bf1_odata_r),  //  o
    .odata_i    (bf1_odata_i)   //  o
);

DelayBuf #(.DEPTH(2**(NN-(2*STAGE)+1)),.WIDTH(WIDTH)) DL1 (
    .clock      (clock      ),  //  i
    .idata_r    (de1_idata_r),  //  i
    .idata_i    (de1_idata_i),  //  i
    .odata_r    (de1_odata_r),  //  o
    .odata_i    (de1_odata_i)   //  o
);

assign  bf1_start = (idata_count == (2**(NN-(2*STAGE)+1)-1));

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf1_odata_en <= 1'b0;
        bf1_count    <= {NN{1'b0}};
    end else begin
        bf1_odata_en <= bf1_start ? 1'b1 : bf1_end ? 1'b0 : bf1_odata_en;
        bf1_count    <= bf1_odata_en ? (bf1_count + 1'b1) : {NN{1'b0}};
    end
end
assign  bf1_end = (bf1_count == (2**NN-1));

//----------------------------------------------------------------------
//  Butterfly2 Control
//----------------------------------------------------------------------
always @(posedge clock) begin
    bf2_idata_r <= bf1_odata_r;
    bf2_idata_i <= bf1_odata_i;
end

always @(posedge clock) begin
    bf2_en    <= bf1_count[NN-(2*STAGE)];
    bf2_mj_en <= bf1_count[NN-(2*STAGE)+1] & bf1_count[NN-(2*STAGE)];
end

Butterfly #(.WIDTH(WIDTH)) BF2 (
    .bf_en      (bf2_en     ),  //  i
    .bf_mj_en   (bf2_mj_en  ),  //  i
    .idata_r    (bf2_idata_r),  //  i
    .idata_i    (bf2_idata_i),  //  i
    .dl_odata_r (de2_odata_r),  //  i
    .dl_odata_i (de2_odata_i),  //  i
    .dl_idata_r (de2_idata_r),  //  o
    .dl_idata_i (de2_idata_i),  //  o
    .odata_r    (bf2_odata_r),  //  o
    .odata_i    (bf2_odata_i)   //  o
);

DelayBuf #(.DEPTH(2**(NN-(2*STAGE))),.WIDTH(WIDTH)) DL2 (
    .clock      (clock      ),  //  i
    .idata_r    (de2_idata_r),  //  i
    .idata_i    (de2_idata_i),  //  i
    .odata_r    (de2_odata_r),  //  o
    .odata_i    (de2_odata_i)   //  o
);

//  Butterfly Output Count Control
//  When Using TW_FF, Start Counting 1T Earlier
assign  bf2_start_dec = (bf1_count == (2**(NN-(2*STAGE))-1)) & bf1_odata_en;
always @(posedge clock) begin
    bf2_start <= bf2_start_dec;
end
assign  bf2_ct_start = TW_FF ? bf2_start_dec : bf2_start;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf2_ct_en <= 1'b0;
        bf2_count <= {NN{1'b0}};
    end else begin
        bf2_ct_en <= bf2_ct_start ? 1'b1 : bf2_ct_end ? 1'b0 : bf2_ct_en;
        bf2_count <= bf2_ct_en ? (bf2_count + 1'b1) : {NN{1'b0}};
    end
end
assign  bf2_ct_end = (bf2_count == (2**NN-1));

always @(posedge clock) begin
    bf2_ct_en_1d <= bf2_ct_en;
end
assign  bf2_odata_en = TW_FF ? bf2_ct_en_1d : bf2_ct_en;

//----------------------------------------------------------------------
//  Twiddle Control
//----------------------------------------------------------------------
assign  tw_sel[1] = bf2_count[NN-(2*STAGE)];
assign  tw_sel[0] = bf2_count[NN-(2*STAGE)+1];
assign  tw_en = (tw_sel != 2'd0);

assign  tw_num = bf2_count << ((2*STAGE)-2);
assign  tw_addr = tw_en ? (tw_num * tw_sel) : {NN{1'b0}};

TwiddleTab #(.FFOUT(TW_FF)) TW (
    .clock      (clock          ),  //  i
    .taddr      (tw_tab_addr    ),  //  i
    .tdata_r    (tw_tab_data_r  ),  //  o
    .tdata_i    (tw_tab_data_i  )   //  o
);

TabReduce #(.NN(NN),.WIDTH(WIDTH)) TR (
    .taddr          (tw_addr        ),  //  i
    .taddr_sel      (tw_addr_sel    ),  //  i
    .tdata_r        (tw_tab_data_r  ),  //  i
    .tdata_i        (tw_tab_data_i  ),  //  i
    .red_taddr      (tw_red_addr    ),  //  o
    .red_tdata_r    (tw_red_data_r  ),  //  o
    .red_tdata_i    (tw_red_data_i  )   //  o
);

//  Connect to TabReduce Logic
integer i;
always @* begin
    if (TW_REDUCE) begin
        tw_tab_addr = tw_red_addr;
        tw_data_r   = tw_red_data_r;
        tw_data_i   = tw_red_data_i;
    end else begin
        tw_tab_addr = tw_addr;
        tw_data_r   = tw_tab_data_r;
        tw_data_i   = tw_tab_data_i;
    end
    //  Redundant Logic for Synthesis Optimization
    for (i = 0; i < ((2*STAGE)-2); i = i + 1) begin
        tw_tab_addr[i] = 1'b0;
    end
end

always @(posedge clock) begin
    tw_addr_1d <= tw_addr;
end
assign  tw_addr_sel = TW_FF ? tw_addr_1d : tw_addr;

//----------------------------------------------------------------------
//  Complex Multiplier
//----------------------------------------------------------------------
always @(posedge clock) begin
    cm_idata_en <= bf2_odata_en;
    cm_en <= (tw_addr_sel != {NN{1'b0}});
end

always @(posedge clock) begin
    cm_idata_r <= bf2_odata_r;
    cm_idata_i <= bf2_odata_i;
    cm_tdata_r <= tw_data_r;
    cm_tdata_i <= tw_data_i;
end

ComplexMul #(.WIDTH(WIDTH)) CM (
    .ar (cm_idata_r ),  //  i
    .ai (cm_idata_i ),  //  i
    .br (cm_tdata_r ),  //  i
    .bi (cm_tdata_i ),  //  i
    .mr (cm_odata_r ),  //  o
    .mi (cm_odata_i )   //  o
);

//----------------------------------------------------------------------
//  Data Output
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        odata_en <= 1'b0;
    end else begin
        if ((NN-(2*STAGE)) == 0) begin
            odata_en <= bf2_odata_en;
        end else begin
            odata_en <= cm_idata_en;
        end
    end
end

always @(posedge clock) begin
    //  Multiplier Bypassed on Last Stage
    if ((NN-(2*STAGE)) == 0) begin
        odata_r <= bf2_odata_r;
        odata_i <= bf2_odata_i;
    end else begin
        odata_r <= cm_en ? cm_odata_r : cm_idata_r;
        odata_i <= cm_en ? cm_odata_i : cm_idata_i;
    end
end

endmodule
