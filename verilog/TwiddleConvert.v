//----------------------------------------------------------------------
//  TwiddleConvert: Convert Twiddle Number and Value to Save Resources
//----------------------------------------------------------------------
module TwiddleConvert #(
    parameter   LOG_N = 6,      //  Address Bit Length
    parameter   WIDTH = 16,     //  Data Bit Length
    parameter   TW_FF = 1       //  Use Twiddle Output Register
)(
    input                   clock,      //  Master Clock
    input       [LOG_N-1:0] iaddr,      //  Twiddle Number
    input       [WIDTH-1:0] idata_r,    //  Twiddle Value (Real)
    input       [WIDTH-1:0] idata_i,    //  Twiddle Value (Imag)
    output      [LOG_N-4:0] oaddr,      //  Converted Twiddle Number
    output  reg [WIDTH-1:0] odata_r,    //  Converted Twiddle Value (Real)
    output  reg [WIDTH-1:0] odata_i     //  Converted Twiddle Value (Imag)
);

//  Define Constants
localparam[WIDTH-1:0] COSMQ = (((32'h5A82799A<<1) >> (32-WIDTH)) + 1)>>1; // cos(-pi/4)
localparam[WIDTH-1:0] SINMH = 32'h80000000 >> (32-WIDTH); // sin(-pi/2)

//  Internal Nets
reg [LOG_N-1:0] ff_iaddr;
wire[LOG_N-1:0] sel_addr;

//  Convert Twiddle Number
assign  oaddr[LOG_N-4:0] = iaddr[LOG_N-3] ? -iaddr[LOG_N-4:0] : iaddr[LOG_N-4:0];

//  Convert Twiddle Value
always @(posedge clock) begin
    ff_iaddr <= iaddr;
end
assign  sel_addr = TW_FF ? ff_iaddr : iaddr;

always @(posedge clock) begin
    if (sel_addr[LOG_N-4:0] == {LOG_N-3{1'b0}}) begin
        case (sel_addr[LOG_N-1:LOG_N-3])
        3'd0    : {odata_r, odata_i} <= {{WIDTH{1'b0}}, {WIDTH{1'b0}}};
        3'd1    : {odata_r, odata_i} <= { COSMQ       , -COSMQ       };
        3'd2    : {odata_r, odata_i} <= {{WIDTH{1'b0}},  SINMH       };
        3'd3    : {odata_r, odata_i} <= {-COSMQ       , -COSMQ       };
        default : {odata_r, odata_i} <= {{WIDTH{1'bx}}, {WIDTH{1'bx}}};
        endcase
    end else begin
        case (sel_addr[LOG_N-1:LOG_N-3])
        3'd0    : {odata_r, odata_i} <= { idata_r,  idata_i};
        3'd1    : {odata_r, odata_i} <= {-idata_i, -idata_r};
        3'd2    : {odata_r, odata_i} <= { idata_i, -idata_r};
        3'd3    : {odata_r, odata_i} <= {-idata_r,  idata_i};
        3'd4    : {odata_r, odata_i} <= {-idata_r, -idata_i};
        3'd5    : {odata_r, odata_i} <= { idata_i,  idata_r};
        default : {odata_r, odata_i} <= {{WIDTH{1'bx}}, {WIDTH{1'bx}}};
        endcase
    end
end

endmodule
