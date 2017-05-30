//----------------------------------------------------------------------
//  DelayBuf: Data Delay Buffer
//----------------------------------------------------------------------
module DelayBuf #(
    parameter   DEPTH = 32,
    parameter   WIDTH = 16
)(
    input               clock,      //  Master Clock
    input   [WIDTH-1:0] idata_r,    //  Input Data (Real)
    input   [WIDTH-1:0] idata_i,    //  Input Data (Imag)
    output  [WIDTH-1:0] odata_r,    //  Output Data (Real)
    output  [WIDTH-1:0] odata_i     //  Output Data (Imag)
);

reg [WIDTH-1:0] buf_r[0:DEPTH-1];   //  Memory Array (Real)
reg [WIDTH-1:0] buf_i[0:DEPTH-1];   //  Memory Array (Imag)
integer     n;

//  Shift Buffer
always @(posedge clock) begin
    for (n = DEPTH-1; n > 0; n = n - 1) begin
        buf_r[n] <= buf_r[n-1];
        buf_i[n] <= buf_i[n-1];
    end
    buf_r[0] <= idata_r;
    buf_i[0] <= idata_i;
end

assign  odata_r = buf_r[DEPTH-1];
assign  odata_i = buf_i[DEPTH-1];

endmodule
