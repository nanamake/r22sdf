//----------------------------------------------------------------------
//  SdfUnit: Radix-2^2 Single-Path Delay Feedback Unit
//----------------------------------------------------------------------
module SdfUnit #(
    parameter   STAGE = 1
)(
    input               clock,      //  Master Clock
    input               reset,      //  Active High Asynchronous Reset
    input               idata_en,   //  Input Data Enable
    input       [15:0]  idata_r,    //  Input Data (Real)
    input       [15:0]  idata_i,    //  Input Data (Imag)
    output  reg         odata_en,   //  Output Data Enable
    output  reg [15:0]  odata_r,    //  Output Data (Real)
    output  reg [15:0]  odata_i     //  Output Data (Imag)
);

//----------------------------------------------------------------------
//  Internal Regs and Nets
//----------------------------------------------------------------------
//  Butterfly1 Control
reg [5:0]   idata_count;    //  Input Data Count
wire        bf1_en;         //  Butterfly Add/Sub Enable
wire[15:0]  de1_idata_r;    //  DelayBuf Input Data (Real)
wire[15:0]  de1_idata_i;    //  DelayBuf Input Data (Imag)
wire[15:0]  de1_odata_r;    //  DelayBuf Output Data (Real)
wire[15:0]  de1_odata_i;    //  DelayBuf Output Data (Imag)
wire[15:0]  bf1_odata_r;    //  Butterfly Output Data (Real)
wire[15:0]  bf1_odata_i;    //  Butterfly Output Data (Imag)
wire        bf1_start;      //  Butterfly Output Start Timing
reg         bf1_odata_en;   //  Butterfly Output Data Enable
reg [5:0]   bf1_count;      //  Butterfly Output Data Count
wire        bf1_end;        //  End of Butterfly Output Data

//  Butterfly2 Control
reg [15:0]  bf2_idata_r;    //  Butterfly Input Data (Real)
reg [15:0]  bf2_idata_i;    //  Butterfly Input Data (Imag)
reg         bf2_en;         //  Butterfly Add/Sub Enable
reg         bf2_mj_en;      //  Twiddle (-j) Enable
wire[15:0]  de2_idata_r;    //  DelayBuf Input Data (Real)
wire[15:0]  de2_idata_i;    //  DelayBuf Input Data (Imag)
wire[15:0]  de2_odata_r;    //  DelayBuf Output Data (Real)
wire[15:0]  de2_odata_i;    //  DelayBuf Output Data (Imag)
wire[15:0]  bf2_odata_r;    //  Butterfly Output Data (Real)
wire[15:0]  bf2_odata_i;    //  Butterfly Output Data (Imag)
reg         bf2_start;      //  Butterfly Output Start Timing
reg         bf2_odata_en;   //  Butterfly Output Data Enable
reg [5:0]   bf2_count;      //  Butterfly Output Data Count
wire        bf2_end;        //  End of Butterfly Output Data

//  Twiddle Control
wire[1:0]   tw_sel;         //  Twiddle Select
wire        tw_en;          //  Twiddle Enable
wire[3:0]   tw_num;         //  Twiddle Number
wire[5:0]   tw_taddr;       //  Twiddle Table Address
wire[15:0]  tw_tdata_r;     //  Twiddle Data (Real)
wire[15:0]  tw_tdata_i;     //  Twiddle Data (Imag)

//  Complex Multiplier
reg         cm_idata_en;    //  Multiplier Input Data Enable
reg         cm_en;          //  Multiplier Enable
reg [15:0]  cm_idata_r;     //  Multiplier Data Input (Real)
reg [15:0]  cm_idata_i;     //  Multiplier Data Input (Imag)
reg [15:0]  cm_tdata_r;     //  Multiplier Twiddle Input (Real)
reg [15:0]  cm_tdata_i;     //  Multiplier Twiddle Input (Imag)
wire[15:0]  cm_odata_r;     //  Multiplier Data Output (Real)
wire[15:0]  cm_odata_i;     //  Multiplier Data Output (Imag)

//----------------------------------------------------------------------
//  Butterfly1 Control
//----------------------------------------------------------------------
always @(posedge clock or posedge reset) begin
    if (reset) begin
        idata_count <= 6'd0;
    end else begin
        idata_count <= idata_en ? (idata_count + 1'b1) : 6'd0;
    end
end

assign  bf1_en = idata_count[6-(2*STAGE)+1];

Butterfly BF1 (
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

DelayBuf #(.DEPTH(2**(6-(2*STAGE)+1))) DL1 (
    .clock      (clock      ),  //  i
    .idata_r    (de1_idata_r),  //  i
    .idata_i    (de1_idata_i),  //  i
    .odata_r    (de1_odata_r),  //  o
    .odata_i    (de1_odata_i)   //  o
);

assign  bf1_start = (idata_count == (2**(6-(2*STAGE)+1)-1));

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf1_odata_en <= 1'b0;
        bf1_count    <= 6'd0;
    end else begin
        bf1_odata_en <= bf1_start ? 1'b1 : bf1_end ? 1'b0 : bf1_odata_en;
        bf1_count    <= bf1_odata_en ? (bf1_count + 1'b1) : 6'd0;
    end
end
assign  bf1_end = (bf1_count == (2**6-1));

//----------------------------------------------------------------------
//  Butterfly2 Control
//----------------------------------------------------------------------
always @(posedge clock) begin
    bf2_idata_r <= bf1_odata_r;
    bf2_idata_i <= bf1_odata_i;
end

always @(posedge clock) begin
    bf2_en    <= bf1_count[6-(2*STAGE)];
    bf2_mj_en <= bf1_count[6-(2*STAGE)+1] & bf1_count[6-(2*STAGE)];
end

Butterfly BF2 (
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

DelayBuf #(.DEPTH(2**(6-(2*STAGE)))) DL2 (
    .clock      (clock      ),  //  i
    .idata_r    (de2_idata_r),  //  i
    .idata_i    (de2_idata_i),  //  i
    .odata_r    (de2_odata_r),  //  o
    .odata_i    (de2_odata_i)   //  o
);

always @(posedge clock) begin
    bf2_start <= (bf1_count == (2**(6-(2*STAGE))-1)) & bf1_odata_en;
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf2_odata_en <= 1'b0;
        bf2_count    <= 6'd0;
    end else begin
        bf2_odata_en <= bf2_start ? 1'b1 : bf2_end ? 1'b0 : bf2_odata_en;
        bf2_count    <= bf2_odata_en ? (bf2_count + 1'b1) : 6'd0;
    end
end
assign  bf2_end = (bf2_count == (2**6-1));

//----------------------------------------------------------------------
//  Twiddle Control
//----------------------------------------------------------------------
assign  tw_sel[1] = bf2_count[6-(2*STAGE)];
assign  tw_sel[0] = bf2_count[6-(2*STAGE)+1];
assign  tw_en = (tw_sel != 2'd0);

assign  tw_num = bf2_count << ((2*STAGE)-2);
assign  tw_taddr = tw_en ? (tw_num * tw_sel) : 6'd0;

TwiddleTab TW (
    .taddr      (tw_taddr   ),  //  i
    .tdata_r    (tw_tdata_r ),  //  o
    .tdata_i    (tw_tdata_i )   //  o
);

//----------------------------------------------------------------------
//  Complex Multiplier
//----------------------------------------------------------------------
always @(posedge clock) begin
    cm_idata_en <= bf2_odata_en;
    cm_en <= (tw_taddr != 6'd0);
end

always @(posedge clock) begin
    cm_idata_r <= bf2_odata_r;
    cm_idata_i <= bf2_odata_i;
    cm_tdata_r <= tw_tdata_r;
    cm_tdata_i <= tw_tdata_i;
end

ComplexMul CM (
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
        if ((6-(2*STAGE)) == 0) begin
            odata_en <= bf2_odata_en;
        end else begin
            odata_en <= cm_idata_en;
        end
    end
end

always @(posedge clock) begin
    //  Multiplier Bypassed on Last Stage
    if ((6-(2*STAGE)) == 0) begin
        odata_r <= bf2_odata_r;
        odata_i <= bf2_odata_i;
    end else begin
        odata_r <= cm_en ? cm_odata_r : cm_idata_r;
        odata_i <= cm_en ? cm_odata_i : cm_idata_i;
    end
end

endmodule
