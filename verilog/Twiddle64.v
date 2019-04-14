//----------------------------------------------------------------------
//  Twiddle: 64-Point Twiddle Table for Radix-2^2 Butterfly
//----------------------------------------------------------------------
module Twiddle #(
    parameter   TW_FF = 1   //  Use Output Register
)(
    input           clock,  //  Master Clock
    input   [5:0]   addr,   //  Twiddle Factor Number
    output  [15:0]  tw_re,  //  Twiddle Factor (Real)
    output  [15:0]  tw_im   //  Twiddle Factor (Imag)
);

wire[15:0]  wn_re[0:63];    //  Twiddle Table (Real)
wire[15:0]  wn_im[0:63];    //  Twiddle Table (Imag)
wire[15:0]  mx_re;          //  Multiplexer output (Real)
wire[15:0]  mx_im;          //  Multiplexer output (Imag)
reg [15:0]  ff_re;          //  Register output (Real)
reg [15:0]  ff_im;          //  Register output (Imag)

assign  mx_re = wn_re[addr];
assign  mx_im = wn_im[addr];

always @(posedge clock) begin
    ff_re <= mx_re;
    ff_im <= mx_im;
end

assign  tw_re = TW_FF ? ff_re : mx_re;
assign  tw_im = TW_FF ? ff_im : mx_im;

//----------------------------------------------------------------------
//  Twiddle Factor Value
//----------------------------------------------------------------------
//  Multiplication is bypassed when twiddle address is 0.
//  Setting wn_re[0] = 0 and wn_im[0] = 0 makes it easier to check the waveform.
//  It may also reduce power consumption slightly.
//
//      wn_re = cos(-2pi*n/64)          wn_im = sin(-2pi*n/64)
assign  wn_re[ 0] = 16'h0000;   assign  wn_im[ 0] = 16'h0000;   //  0  1.000 -0.000
assign  wn_re[ 1] = 16'h7F62;   assign  wn_im[ 1] = 16'hF374;   //  1  0.995 -0.098
assign  wn_re[ 2] = 16'h7D8A;   assign  wn_im[ 2] = 16'hE707;   //  2  0.981 -0.195
assign  wn_re[ 3] = 16'h7A7D;   assign  wn_im[ 3] = 16'hDAD8;   //  3  0.957 -0.290
assign  wn_re[ 4] = 16'h7642;   assign  wn_im[ 4] = 16'hCF04;   //  4  0.924 -0.383
assign  wn_re[ 5] = 16'h70E3;   assign  wn_im[ 5] = 16'hC3A9;   //  5  0.882 -0.471
assign  wn_re[ 6] = 16'h6A6E;   assign  wn_im[ 6] = 16'hB8E3;   //  6  0.831 -0.556
assign  wn_re[ 7] = 16'h62F2;   assign  wn_im[ 7] = 16'hAECC;   //  7  0.773 -0.634
assign  wn_re[ 8] = 16'h5A82;   assign  wn_im[ 8] = 16'hA57E;   //  8  0.707 -0.707
assign  wn_re[ 9] = 16'h5134;   assign  wn_im[ 9] = 16'h9D0E;   //  9  0.634 -0.773
assign  wn_re[10] = 16'h471D;   assign  wn_im[10] = 16'h9592;   // 10  0.556 -0.831
assign  wn_re[11] = 16'h3C57;   assign  wn_im[11] = 16'h8F1D;   // 11  0.471 -0.882
assign  wn_re[12] = 16'h30FC;   assign  wn_im[12] = 16'h89BE;   // 12  0.383 -0.924
assign  wn_re[13] = 16'h2528;   assign  wn_im[13] = 16'h8583;   // 13  0.290 -0.957
assign  wn_re[14] = 16'h18F9;   assign  wn_im[14] = 16'h8276;   // 14  0.195 -0.981
assign  wn_re[15] = 16'h0C8C;   assign  wn_im[15] = 16'h809E;   // 15  0.098 -0.995
assign  wn_re[16] = 16'h0000;   assign  wn_im[16] = 16'h8000;   // 16  0.000 -1.000
assign  wn_re[17] = 16'hxxxx;   assign  wn_im[17] = 16'hxxxx;   // 17 -0.098 -0.995
assign  wn_re[18] = 16'hE707;   assign  wn_im[18] = 16'h8276;   // 18 -0.195 -0.981
assign  wn_re[19] = 16'hxxxx;   assign  wn_im[19] = 16'hxxxx;   // 19 -0.290 -0.957
assign  wn_re[20] = 16'hCF04;   assign  wn_im[20] = 16'h89BE;   // 20 -0.383 -0.924
assign  wn_re[21] = 16'hC3A9;   assign  wn_im[21] = 16'h8F1D;   // 21 -0.471 -0.882
assign  wn_re[22] = 16'hB8E3;   assign  wn_im[22] = 16'h9592;   // 22 -0.556 -0.831
assign  wn_re[23] = 16'hxxxx;   assign  wn_im[23] = 16'hxxxx;   // 23 -0.634 -0.773
assign  wn_re[24] = 16'hA57E;   assign  wn_im[24] = 16'hA57E;   // 24 -0.707 -0.707
assign  wn_re[25] = 16'hxxxx;   assign  wn_im[25] = 16'hxxxx;   // 25 -0.773 -0.634
assign  wn_re[26] = 16'h9592;   assign  wn_im[26] = 16'hB8E3;   // 26 -0.831 -0.556
assign  wn_re[27] = 16'h8F1D;   assign  wn_im[27] = 16'hC3A9;   // 27 -0.882 -0.471
assign  wn_re[28] = 16'h89BE;   assign  wn_im[28] = 16'hCF04;   // 28 -0.924 -0.383
assign  wn_re[29] = 16'hxxxx;   assign  wn_im[29] = 16'hxxxx;   // 29 -0.957 -0.290
assign  wn_re[30] = 16'h8276;   assign  wn_im[30] = 16'hE707;   // 30 -0.981 -0.195
assign  wn_re[31] = 16'hxxxx;   assign  wn_im[31] = 16'hxxxx;   // 31 -0.995 -0.098
assign  wn_re[32] = 16'hxxxx;   assign  wn_im[32] = 16'hxxxx;   // 32 -1.000 -0.000
assign  wn_re[33] = 16'h809E;   assign  wn_im[33] = 16'h0C8C;   // 33 -0.995  0.098
assign  wn_re[34] = 16'hxxxx;   assign  wn_im[34] = 16'hxxxx;   // 34 -0.981  0.195
assign  wn_re[35] = 16'hxxxx;   assign  wn_im[35] = 16'hxxxx;   // 35 -0.957  0.290
assign  wn_re[36] = 16'h89BE;   assign  wn_im[36] = 16'h30FC;   // 36 -0.924  0.383
assign  wn_re[37] = 16'hxxxx;   assign  wn_im[37] = 16'hxxxx;   // 37 -0.882  0.471
assign  wn_re[38] = 16'hxxxx;   assign  wn_im[38] = 16'hxxxx;   // 38 -0.831  0.556
assign  wn_re[39] = 16'h9D0E;   assign  wn_im[39] = 16'h5134;   // 39 -0.773  0.634
assign  wn_re[40] = 16'hxxxx;   assign  wn_im[40] = 16'hxxxx;   // 40 -0.707  0.707
assign  wn_re[41] = 16'hxxxx;   assign  wn_im[41] = 16'hxxxx;   // 41 -0.634  0.773
assign  wn_re[42] = 16'hB8E3;   assign  wn_im[42] = 16'h6A6E;   // 42 -0.556  0.831
assign  wn_re[43] = 16'hxxxx;   assign  wn_im[43] = 16'hxxxx;   // 43 -0.471  0.882
assign  wn_re[44] = 16'hxxxx;   assign  wn_im[44] = 16'hxxxx;   // 44 -0.383  0.924
assign  wn_re[45] = 16'hDAD8;   assign  wn_im[45] = 16'h7A7D;   // 45 -0.290  0.957
assign  wn_re[46] = 16'hxxxx;   assign  wn_im[46] = 16'hxxxx;   // 46 -0.195  0.981
assign  wn_re[47] = 16'hxxxx;   assign  wn_im[47] = 16'hxxxx;   // 47 -0.098  0.995
assign  wn_re[48] = 16'hxxxx;   assign  wn_im[48] = 16'hxxxx;   // 48 -0.000  1.000
assign  wn_re[49] = 16'hxxxx;   assign  wn_im[49] = 16'hxxxx;   // 49  0.098  0.995
assign  wn_re[50] = 16'hxxxx;   assign  wn_im[50] = 16'hxxxx;   // 50  0.195  0.981
assign  wn_re[51] = 16'hxxxx;   assign  wn_im[51] = 16'hxxxx;   // 51  0.290  0.957
assign  wn_re[52] = 16'hxxxx;   assign  wn_im[52] = 16'hxxxx;   // 52  0.383  0.924
assign  wn_re[53] = 16'hxxxx;   assign  wn_im[53] = 16'hxxxx;   // 53  0.471  0.882
assign  wn_re[54] = 16'hxxxx;   assign  wn_im[54] = 16'hxxxx;   // 54  0.556  0.831
assign  wn_re[55] = 16'hxxxx;   assign  wn_im[55] = 16'hxxxx;   // 55  0.634  0.773
assign  wn_re[56] = 16'hxxxx;   assign  wn_im[56] = 16'hxxxx;   // 56  0.707  0.707
assign  wn_re[57] = 16'hxxxx;   assign  wn_im[57] = 16'hxxxx;   // 57  0.773  0.634
assign  wn_re[58] = 16'hxxxx;   assign  wn_im[58] = 16'hxxxx;   // 58  0.831  0.556
assign  wn_re[59] = 16'hxxxx;   assign  wn_im[59] = 16'hxxxx;   // 59  0.882  0.471
assign  wn_re[60] = 16'hxxxx;   assign  wn_im[60] = 16'hxxxx;   // 60  0.924  0.383
assign  wn_re[61] = 16'hxxxx;   assign  wn_im[61] = 16'hxxxx;   // 61  0.957  0.290
assign  wn_re[62] = 16'hxxxx;   assign  wn_im[62] = 16'hxxxx;   // 62  0.981  0.195
assign  wn_re[63] = 16'hxxxx;   assign  wn_im[63] = 16'hxxxx;   // 63  0.995  0.098

endmodule
