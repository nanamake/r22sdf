//----------------------------------------------------------------------
//  TwiddleConvert4: Convert Twiddle Value to Reduce Table Size to 1/4
//----------------------------------------------------------------------
module TwiddleConvert4 #(
    parameter   LOG_N = 6,      //  Address Bit Length
    parameter   WIDTH = 16,     //  Data Bit Length
    parameter   TW_FF = 1,      //  Use Twiddle Output Register
    parameter   TC_FF = 1       //  Use Output Register
)(
    input               clock,      //  Master Clock
    input   [LOG_N-1:0] iaddr,      //  Twiddle Number
    input   [WIDTH-1:0] idata_r,    //  Twiddle Value (Real)
    input   [WIDTH-1:0] idata_i,    //  Twiddle Value (Imag)
    output  [LOG_N-1:0] oaddr,      //  Converted Twiddle Number
    output  [WIDTH-1:0] odata_r,    //  Converted Twiddle Value (Real)
    output  [WIDTH-1:0] odata_i     //  Converted Twiddle Value (Imag)
);

//  Internal Nets
reg [LOG_N-1:0] ff_iaddr;
wire[LOG_N-1:0] sel_addr;
reg [WIDTH-1:0] mx_odata_r;
reg [WIDTH-1:0] mx_odata_i;
reg [WIDTH-1:0] ff_odata_r;
reg [WIDTH-1:0] ff_odata_i;

//  Convert Twiddle Number
assign  oaddr[LOG_N-1:LOG_N-2] = 2'd0;
assign  oaddr[LOG_N-3:0] = iaddr[LOG_N-3:0];

//  Convert Twiddle Value
always @(posedge clock) begin
    ff_iaddr <= iaddr;
end
assign  sel_addr = TW_FF ? ff_iaddr : iaddr;

always @* begin
    if (sel_addr[LOG_N-3:0] == {LOG_N-2{1'b0}}) begin
        //  When twiddle number n is 0, multiplication is not performed.
        //  Setting wn_r[0] = 0 and wn_i[0] = 0 makes it easier to check the waveform.
        //  It may also reduce power consumption slightly.
        case (sel_addr[LOG_N-1:LOG_N-2])
        2'd0    : {mx_odata_r, mx_odata_i} <= {{WIDTH{1'b0}}, {WIDTH{1'b0}}};
        2'd1    : {mx_odata_r, mx_odata_i} <= {{WIDTH{1'b0}}, {1'b1,{WIDTH-1{1'b0}}}};
        default : {mx_odata_r, mx_odata_i} <= {{WIDTH{1'bx}}, {WIDTH{1'bx}}};
        endcase
    end else begin
        case (sel_addr[LOG_N-1:LOG_N-2])
        2'd0    : {mx_odata_r, mx_odata_i} <= { idata_r,  idata_i};
        2'd1    : {mx_odata_r, mx_odata_i} <= { idata_i, -idata_r};
        2'd2    : {mx_odata_r, mx_odata_i} <= {-idata_r, -idata_i};
        default : {mx_odata_r, mx_odata_i} <= {{WIDTH{1'bx}}, {WIDTH{1'bx}}};
        endcase
    end
end
always @(posedge clock) begin
    ff_odata_r <= mx_odata_r;
    ff_odata_i <= mx_odata_i;
end

assign  odata_r = TC_FF ? ff_odata_r : mx_odata_r;
assign  odata_i = TC_FF ? ff_odata_i : mx_odata_i;

endmodule
