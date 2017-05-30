//----------------------------------------------------------------------
//  TabReduce: Twiddle Table Size Reduction Logic
//----------------------------------------------------------------------
module TabReduce #(
    parameter   NN = 6,         //  Table Address Size log2(N)
    parameter   WIDTH = 16      //  Data Word Length
)(
    input       [NN-1:0]    taddr,      //  Original Twiddle Address
    input       [NN-1:0]    taddr_sel,  //  Address for Data Select
    input       [WIDTH-1:0] tdata_r,    //  Twiddle Table Data (Real)
    input       [WIDTH-1:0] tdata_i,    //  Twiddle Table Data (Imag)
    output      [NN-1:0]    red_taddr,  //  Alternate Twiddle Address
    output  reg [WIDTH-1:0] red_tdata_r,//  Required Twiddle Value (Real)
    output  reg [WIDTH-1:0] red_tdata_i //  Required Twiddle Value (Imag)
);

localparam[WIDTH-1:0] COSMQ = (((32'h5A82799A<<1) >> (32-WIDTH)) + 1) >> 1; // cos(-pi/4)
localparam[WIDTH-1:0] SINMH = 32'h80000000 >> (32-WIDTH); // sin(-pi/2)

assign  red_taddr[NN-1:NN-3] = 3'd0;
assign  red_taddr[NN-4:0] = taddr[NN-3] ? -taddr[NN-4:0] : taddr[NN-4:0];

always @* begin
    if (taddr_sel[NN-4:0] == {NN-3{1'b0}}) begin
        case (taddr_sel[NN-1:NN-3])
        3'd0    : {red_tdata_r, red_tdata_i} = {{WIDTH{1'b0}}, {WIDTH{1'b0}}};
        3'd1    : {red_tdata_r, red_tdata_i} = { COSMQ       , -COSMQ       };
        3'd2    : {red_tdata_r, red_tdata_i} = {{WIDTH{1'b0}},  SINMH       };
        3'd3    : {red_tdata_r, red_tdata_i} = {-COSMQ       , -COSMQ       };
        3'd4    : {red_tdata_r, red_tdata_i} = { SINMH       , {WIDTH{1'b0}}};
        default : {red_tdata_r, red_tdata_i} = {{WIDTH{1'bx}}, {WIDTH{1'bx}}};
        endcase
    end else begin
        case (taddr_sel[NN-1:NN-3])
        3'd0    : {red_tdata_r, red_tdata_i} = { tdata_r,  tdata_i};
        3'd1    : {red_tdata_r, red_tdata_i} = {-tdata_i, -tdata_r};
        3'd2    : {red_tdata_r, red_tdata_i} = { tdata_i, -tdata_r};
        3'd3    : {red_tdata_r, red_tdata_i} = {-tdata_r,  tdata_i};
        3'd4    : {red_tdata_r, red_tdata_i} = {-tdata_r, -tdata_i};
        3'd5    : {red_tdata_r, red_tdata_i} = { tdata_i,  tdata_r};
        default : {red_tdata_r, red_tdata_i} = {{WIDTH{1'bx}}, {WIDTH{1'bx}}};
        endcase
    end
end

endmodule
