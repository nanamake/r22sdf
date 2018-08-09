//----------------------------------------------------------------------
//  TwiddleConvert8: Convert Twiddle Value to Reduce Table Size to 1/8
//----------------------------------------------------------------------
module TwiddleConvert8 #(
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

//  Define Constants
localparam[WIDTH-1:0] COSMQ = (((32'h5A82799A<<1) >> (32-WIDTH)) + 1)>>1; // cos(-pi/4)
localparam[WIDTH-1:0] SINMH = 32'h80000000 >> (32-WIDTH); // sin(-pi/2)

//  Internal Nets
reg [LOG_N-1:0] ff_iaddr;
wire[LOG_N-1:0] sel_addr;
reg [WIDTH-1:0] mx_odata_r;
reg [WIDTH-1:0] mx_odata_i;
reg [WIDTH-1:0] ff_odata_r;
reg [WIDTH-1:0] ff_odata_i;

//  Convert Twiddle Number
assign  oaddr[LOG_N-1:LOG_N-3] = 3'd0;
assign  oaddr[LOG_N-4:0] = iaddr[LOG_N-3] ? -iaddr[LOG_N-4:0] : iaddr[LOG_N-4:0];

//  Convert Twiddle Value
always @(posedge clock) begin
    ff_iaddr <= iaddr;
end
assign  sel_addr = TW_FF ? ff_iaddr : iaddr;

always @* begin
    if (sel_addr[LOG_N-4:0] == {LOG_N-3{1'b0}}) begin
        //  When twiddle number n is 0, multiplication is not performed.
        //  Setting wn_r[0] = 0 and wn_i[0] = 0 makes it easier to check the waveform.
        //  It may also reduce power consumption slightly.
        case (sel_addr[LOG_N-1:LOG_N-3])
        3'd0    : {mx_odata_r, mx_odata_i} <= {{WIDTH{1'b0}}, {WIDTH{1'b0}}};
        3'd1    : {mx_odata_r, mx_odata_i} <= { COSMQ       , -COSMQ       };
        3'd2    : {mx_odata_r, mx_odata_i} <= {{WIDTH{1'b0}},  SINMH       };
        3'd3    : {mx_odata_r, mx_odata_i} <= {-COSMQ       , -COSMQ       };
        default : {mx_odata_r, mx_odata_i} <= {{WIDTH{1'bx}}, {WIDTH{1'bx}}};
        endcase
    end else begin
        case (sel_addr[LOG_N-1:LOG_N-3])
        3'd0    : {mx_odata_r, mx_odata_i} <= { idata_r,  idata_i};
        3'd1    : {mx_odata_r, mx_odata_i} <= {-idata_i, -idata_r};
        3'd2    : {mx_odata_r, mx_odata_i} <= { idata_i, -idata_r};
        3'd3    : {mx_odata_r, mx_odata_i} <= {-idata_r,  idata_i};
        3'd4    : {mx_odata_r, mx_odata_i} <= {-idata_r, -idata_i};
        3'd5    : {mx_odata_r, mx_odata_i} <= { idata_i,  idata_r};
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
