//----------------------------------------------------------------------
//  DelayBuffer: Make Constant Data Delay
//----------------------------------------------------------------------
module DelayBuffer #(
    parameter   DEPTH = 32,
    parameter   WIDTH = 16
)(
    input               clock,      //  Master Clock
    input   [WIDTH-1:0] din_r,      //  Data Input (Real)
    input   [WIDTH-1:0] din_i,      //  Data Input (Imag)
    output  [WIDTH-1:0] dout_r,     //  Data Output (Real)
    output  [WIDTH-1:0] dout_i      //  Data Output (Imag)
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
    buf_r[0] <= din_r;
    buf_i[0] <= din_i;
end

assign  dout_r = buf_r[DEPTH-1];
assign  dout_i = buf_i[DEPTH-1];

endmodule
