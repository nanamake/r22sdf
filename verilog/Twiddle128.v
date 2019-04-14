//----------------------------------------------------------------------
//  Twiddle: 128-Point Twiddle Table for Radix-2^2 Butterfly
//----------------------------------------------------------------------
module Twiddle #(
    parameter   TW_FF = 1   //  Use Output Register
)(
    input           clock,  //  Master Clock
    input   [6:0]   addr,   //  Twiddle Factor Number
    output  [15:0]  tw_re,  //  Twiddle Factor (Real)
    output  [15:0]  tw_im   //  Twiddle Factor (Imag)
);

wire[15:0]  wn_re[0:127];   //  Twiddle Table (Real)
wire[15:0]  wn_im[0:127];   //  Twiddle Table (Imag)
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
//      wn_re = cos(-2pi*n/128)         wn_im = sin(-2pi*n/128)
assign  wn_re[ 0] = 16'h0000;   assign  wn_im[ 0] = 16'h0000;   //  0  1.000 -0.000
assign  wn_re[ 1] = 16'h7FD9;   assign  wn_im[ 1] = 16'hF9B8;   //  1  0.999 -0.049
assign  wn_re[ 2] = 16'h7F62;   assign  wn_im[ 2] = 16'hF374;   //  2  0.995 -0.098
assign  wn_re[ 3] = 16'h7E9D;   assign  wn_im[ 3] = 16'hED38;   //  3  0.989 -0.147
assign  wn_re[ 4] = 16'h7D8A;   assign  wn_im[ 4] = 16'hE707;   //  4  0.981 -0.195
assign  wn_re[ 5] = 16'h7C2A;   assign  wn_im[ 5] = 16'hE0E6;   //  5  0.970 -0.243
assign  wn_re[ 6] = 16'h7A7D;   assign  wn_im[ 6] = 16'hDAD8;   //  6  0.957 -0.290
assign  wn_re[ 7] = 16'h7885;   assign  wn_im[ 7] = 16'hD4E1;   //  7  0.942 -0.337
assign  wn_re[ 8] = 16'h7642;   assign  wn_im[ 8] = 16'hCF04;   //  8  0.924 -0.383
assign  wn_re[ 9] = 16'h73B6;   assign  wn_im[ 9] = 16'hC946;   //  9  0.904 -0.428
assign  wn_re[10] = 16'h70E3;   assign  wn_im[10] = 16'hC3A9;   // 10  0.882 -0.471
assign  wn_re[11] = 16'h6DCA;   assign  wn_im[11] = 16'hBE32;   // 11  0.858 -0.514
assign  wn_re[12] = 16'h6A6E;   assign  wn_im[12] = 16'hB8E3;   // 12  0.831 -0.556
assign  wn_re[13] = 16'h66D0;   assign  wn_im[13] = 16'hB3C0;   // 13  0.803 -0.596
assign  wn_re[14] = 16'h62F2;   assign  wn_im[14] = 16'hAECC;   // 14  0.773 -0.634
assign  wn_re[15] = 16'h5ED7;   assign  wn_im[15] = 16'hAA0A;   // 15  0.741 -0.672
assign  wn_re[16] = 16'h5A82;   assign  wn_im[16] = 16'hA57E;   // 16  0.707 -0.707
assign  wn_re[17] = 16'h55F6;   assign  wn_im[17] = 16'hA129;   // 17  0.672 -0.741
assign  wn_re[18] = 16'h5134;   assign  wn_im[18] = 16'h9D0E;   // 18  0.634 -0.773
assign  wn_re[19] = 16'h4C40;   assign  wn_im[19] = 16'h9930;   // 19  0.596 -0.803
assign  wn_re[20] = 16'h471D;   assign  wn_im[20] = 16'h9592;   // 20  0.556 -0.831
assign  wn_re[21] = 16'h41CE;   assign  wn_im[21] = 16'h9236;   // 21  0.514 -0.858
assign  wn_re[22] = 16'h3C57;   assign  wn_im[22] = 16'h8F1D;   // 22  0.471 -0.882
assign  wn_re[23] = 16'h36BA;   assign  wn_im[23] = 16'h8C4A;   // 23  0.428 -0.904
assign  wn_re[24] = 16'h30FC;   assign  wn_im[24] = 16'h89BE;   // 24  0.383 -0.924
assign  wn_re[25] = 16'h2B1F;   assign  wn_im[25] = 16'h877B;   // 25  0.337 -0.942
assign  wn_re[26] = 16'h2528;   assign  wn_im[26] = 16'h8583;   // 26  0.290 -0.957
assign  wn_re[27] = 16'h1F1A;   assign  wn_im[27] = 16'h83D6;   // 27  0.243 -0.970
assign  wn_re[28] = 16'h18F9;   assign  wn_im[28] = 16'h8276;   // 28  0.195 -0.981
assign  wn_re[29] = 16'h12C8;   assign  wn_im[29] = 16'h8163;   // 29  0.147 -0.989
assign  wn_re[30] = 16'h0C8C;   assign  wn_im[30] = 16'h809E;   // 30  0.098 -0.995
assign  wn_re[31] = 16'h0648;   assign  wn_im[31] = 16'h8027;   // 31  0.049 -0.999
assign  wn_re[32] = 16'h0000;   assign  wn_im[32] = 16'h8000;   // 32  0.000 -1.000
assign  wn_re[33] = 16'hF9B8;   assign  wn_im[33] = 16'h8027;   // 33 -0.049 -0.999
assign  wn_re[34] = 16'hF374;   assign  wn_im[34] = 16'h809E;   // 34 -0.098 -0.995
assign  wn_re[35] = 16'hxxxx;   assign  wn_im[35] = 16'hxxxx;   // 35 -0.147 -0.989
assign  wn_re[36] = 16'hE707;   assign  wn_im[36] = 16'h8276;   // 36 -0.195 -0.981
assign  wn_re[37] = 16'hxxxx;   assign  wn_im[37] = 16'hxxxx;   // 37 -0.243 -0.970
assign  wn_re[38] = 16'hDAD8;   assign  wn_im[38] = 16'h8583;   // 38 -0.290 -0.957
assign  wn_re[39] = 16'hD4E1;   assign  wn_im[39] = 16'h877B;   // 39 -0.337 -0.942
assign  wn_re[40] = 16'hCF04;   assign  wn_im[40] = 16'h89BE;   // 40 -0.383 -0.924
assign  wn_re[41] = 16'hxxxx;   assign  wn_im[41] = 16'hxxxx;   // 41 -0.428 -0.904
assign  wn_re[42] = 16'hC3A9;   assign  wn_im[42] = 16'h8F1D;   // 42 -0.471 -0.882
assign  wn_re[43] = 16'hxxxx;   assign  wn_im[43] = 16'hxxxx;   // 43 -0.514 -0.858
assign  wn_re[44] = 16'hB8E3;   assign  wn_im[44] = 16'h9592;   // 44 -0.556 -0.831
assign  wn_re[45] = 16'hB3C0;   assign  wn_im[45] = 16'h9930;   // 45 -0.596 -0.803
assign  wn_re[46] = 16'hAECC;   assign  wn_im[46] = 16'h9D0E;   // 46 -0.634 -0.773
assign  wn_re[47] = 16'hxxxx;   assign  wn_im[47] = 16'hxxxx;   // 47 -0.672 -0.741
assign  wn_re[48] = 16'hA57E;   assign  wn_im[48] = 16'hA57E;   // 48 -0.707 -0.707
assign  wn_re[49] = 16'hxxxx;   assign  wn_im[49] = 16'hxxxx;   // 49 -0.741 -0.672
assign  wn_re[50] = 16'h9D0E;   assign  wn_im[50] = 16'hAECC;   // 50 -0.773 -0.634
assign  wn_re[51] = 16'h9930;   assign  wn_im[51] = 16'hB3C0;   // 51 -0.803 -0.596
assign  wn_re[52] = 16'h9592;   assign  wn_im[52] = 16'hB8E3;   // 52 -0.831 -0.556
assign  wn_re[53] = 16'hxxxx;   assign  wn_im[53] = 16'hxxxx;   // 53 -0.858 -0.514
assign  wn_re[54] = 16'h8F1D;   assign  wn_im[54] = 16'hC3A9;   // 54 -0.882 -0.471
assign  wn_re[55] = 16'hxxxx;   assign  wn_im[55] = 16'hxxxx;   // 55 -0.904 -0.428
assign  wn_re[56] = 16'h89BE;   assign  wn_im[56] = 16'hCF04;   // 56 -0.924 -0.383
assign  wn_re[57] = 16'h877B;   assign  wn_im[57] = 16'hD4E1;   // 57 -0.942 -0.337
assign  wn_re[58] = 16'h8583;   assign  wn_im[58] = 16'hDAD8;   // 58 -0.957 -0.290
assign  wn_re[59] = 16'hxxxx;   assign  wn_im[59] = 16'hxxxx;   // 59 -0.970 -0.243
assign  wn_re[60] = 16'h8276;   assign  wn_im[60] = 16'hE707;   // 60 -0.981 -0.195
assign  wn_re[61] = 16'hxxxx;   assign  wn_im[61] = 16'hxxxx;   // 61 -0.989 -0.147
assign  wn_re[62] = 16'h809E;   assign  wn_im[62] = 16'hF374;   // 62 -0.995 -0.098
assign  wn_re[63] = 16'h8027;   assign  wn_im[63] = 16'hF9B8;   // 63 -0.999 -0.049
assign  wn_re[64] = 16'hxxxx;   assign  wn_im[64] = 16'hxxxx;   // 64 -1.000 -0.000
assign  wn_re[65] = 16'hxxxx;   assign  wn_im[65] = 16'hxxxx;   // 65 -0.999  0.049
assign  wn_re[66] = 16'h809E;   assign  wn_im[66] = 16'h0C8C;   // 66 -0.995  0.098
assign  wn_re[67] = 16'hxxxx;   assign  wn_im[67] = 16'hxxxx;   // 67 -0.989  0.147
assign  wn_re[68] = 16'hxxxx;   assign  wn_im[68] = 16'hxxxx;   // 68 -0.981  0.195
assign  wn_re[69] = 16'h83D6;   assign  wn_im[69] = 16'h1F1A;   // 69 -0.970  0.243
assign  wn_re[70] = 16'hxxxx;   assign  wn_im[70] = 16'hxxxx;   // 70 -0.957  0.290
assign  wn_re[71] = 16'hxxxx;   assign  wn_im[71] = 16'hxxxx;   // 71 -0.942  0.337
assign  wn_re[72] = 16'h89BE;   assign  wn_im[72] = 16'h30FC;   // 72 -0.924  0.383
assign  wn_re[73] = 16'hxxxx;   assign  wn_im[73] = 16'hxxxx;   // 73 -0.904  0.428
assign  wn_re[74] = 16'hxxxx;   assign  wn_im[74] = 16'hxxxx;   // 74 -0.882  0.471
assign  wn_re[75] = 16'h9236;   assign  wn_im[75] = 16'h41CE;   // 75 -0.858  0.514
assign  wn_re[76] = 16'hxxxx;   assign  wn_im[76] = 16'hxxxx;   // 76 -0.831  0.556
assign  wn_re[77] = 16'hxxxx;   assign  wn_im[77] = 16'hxxxx;   // 77 -0.803  0.596
assign  wn_re[78] = 16'h9D0E;   assign  wn_im[78] = 16'h5134;   // 78 -0.773  0.634
assign  wn_re[79] = 16'hxxxx;   assign  wn_im[79] = 16'hxxxx;   // 79 -0.741  0.672
assign  wn_re[80] = 16'hxxxx;   assign  wn_im[80] = 16'hxxxx;   // 80 -0.707  0.707
assign  wn_re[81] = 16'hAA0A;   assign  wn_im[81] = 16'h5ED7;   // 81 -0.672  0.741
assign  wn_re[82] = 16'hxxxx;   assign  wn_im[82] = 16'hxxxx;   // 82 -0.634  0.773
assign  wn_re[83] = 16'hxxxx;   assign  wn_im[83] = 16'hxxxx;   // 83 -0.596  0.803
assign  wn_re[84] = 16'hB8E3;   assign  wn_im[84] = 16'h6A6E;   // 84 -0.556  0.831
assign  wn_re[85] = 16'hxxxx;   assign  wn_im[85] = 16'hxxxx;   // 85 -0.514  0.858
assign  wn_re[86] = 16'hxxxx;   assign  wn_im[86] = 16'hxxxx;   // 86 -0.471  0.882
assign  wn_re[87] = 16'hC946;   assign  wn_im[87] = 16'h73B6;   // 87 -0.428  0.904
assign  wn_re[88] = 16'hxxxx;   assign  wn_im[88] = 16'hxxxx;   // 88 -0.383  0.924
assign  wn_re[89] = 16'hxxxx;   assign  wn_im[89] = 16'hxxxx;   // 89 -0.337  0.942
assign  wn_re[90] = 16'hDAD8;   assign  wn_im[90] = 16'h7A7D;   // 90 -0.290  0.957
assign  wn_re[91] = 16'hxxxx;   assign  wn_im[91] = 16'hxxxx;   // 91 -0.243  0.970
assign  wn_re[92] = 16'hxxxx;   assign  wn_im[92] = 16'hxxxx;   // 92 -0.195  0.981
assign  wn_re[93] = 16'hED38;   assign  wn_im[93] = 16'h7E9D;   // 93 -0.147  0.989
assign  wn_re[94] = 16'hxxxx;   assign  wn_im[94] = 16'hxxxx;   // 94 -0.098  0.995
assign  wn_re[95] = 16'hxxxx;   assign  wn_im[95] = 16'hxxxx;   // 95 -0.049  0.999
assign  wn_re[96] = 16'hxxxx;   assign  wn_im[96] = 16'hxxxx;   // 96 -0.000  1.000
assign  wn_re[97] = 16'hxxxx;   assign  wn_im[97] = 16'hxxxx;   // 97  0.049  0.999
assign  wn_re[98] = 16'hxxxx;   assign  wn_im[98] = 16'hxxxx;   // 98  0.098  0.995
assign  wn_re[99] = 16'hxxxx;   assign  wn_im[99] = 16'hxxxx;   // 99  0.147  0.989
assign  wn_re[100] = 16'hxxxx;   assign  wn_im[100] = 16'hxxxx;   // 100  0.195  0.981
assign  wn_re[101] = 16'hxxxx;   assign  wn_im[101] = 16'hxxxx;   // 101  0.243  0.970
assign  wn_re[102] = 16'hxxxx;   assign  wn_im[102] = 16'hxxxx;   // 102  0.290  0.957
assign  wn_re[103] = 16'hxxxx;   assign  wn_im[103] = 16'hxxxx;   // 103  0.337  0.942
assign  wn_re[104] = 16'hxxxx;   assign  wn_im[104] = 16'hxxxx;   // 104  0.383  0.924
assign  wn_re[105] = 16'hxxxx;   assign  wn_im[105] = 16'hxxxx;   // 105  0.428  0.904
assign  wn_re[106] = 16'hxxxx;   assign  wn_im[106] = 16'hxxxx;   // 106  0.471  0.882
assign  wn_re[107] = 16'hxxxx;   assign  wn_im[107] = 16'hxxxx;   // 107  0.514  0.858
assign  wn_re[108] = 16'hxxxx;   assign  wn_im[108] = 16'hxxxx;   // 108  0.556  0.831
assign  wn_re[109] = 16'hxxxx;   assign  wn_im[109] = 16'hxxxx;   // 109  0.596  0.803
assign  wn_re[110] = 16'hxxxx;   assign  wn_im[110] = 16'hxxxx;   // 110  0.634  0.773
assign  wn_re[111] = 16'hxxxx;   assign  wn_im[111] = 16'hxxxx;   // 111  0.672  0.741
assign  wn_re[112] = 16'hxxxx;   assign  wn_im[112] = 16'hxxxx;   // 112  0.707  0.707
assign  wn_re[113] = 16'hxxxx;   assign  wn_im[113] = 16'hxxxx;   // 113  0.741  0.672
assign  wn_re[114] = 16'hxxxx;   assign  wn_im[114] = 16'hxxxx;   // 114  0.773  0.634
assign  wn_re[115] = 16'hxxxx;   assign  wn_im[115] = 16'hxxxx;   // 115  0.803  0.596
assign  wn_re[116] = 16'hxxxx;   assign  wn_im[116] = 16'hxxxx;   // 116  0.831  0.556
assign  wn_re[117] = 16'hxxxx;   assign  wn_im[117] = 16'hxxxx;   // 117  0.858  0.514
assign  wn_re[118] = 16'hxxxx;   assign  wn_im[118] = 16'hxxxx;   // 118  0.882  0.471
assign  wn_re[119] = 16'hxxxx;   assign  wn_im[119] = 16'hxxxx;   // 119  0.904  0.428
assign  wn_re[120] = 16'hxxxx;   assign  wn_im[120] = 16'hxxxx;   // 120  0.924  0.383
assign  wn_re[121] = 16'hxxxx;   assign  wn_im[121] = 16'hxxxx;   // 121  0.942  0.337
assign  wn_re[122] = 16'hxxxx;   assign  wn_im[122] = 16'hxxxx;   // 122  0.957  0.290
assign  wn_re[123] = 16'hxxxx;   assign  wn_im[123] = 16'hxxxx;   // 123  0.970  0.243
assign  wn_re[124] = 16'hxxxx;   assign  wn_im[124] = 16'hxxxx;   // 124  0.981  0.195
assign  wn_re[125] = 16'hxxxx;   assign  wn_im[125] = 16'hxxxx;   // 125  0.989  0.147
assign  wn_re[126] = 16'hxxxx;   assign  wn_im[126] = 16'hxxxx;   // 126  0.995  0.098
assign  wn_re[127] = 16'hxxxx;   assign  wn_im[127] = 16'hxxxx;   // 127  0.999  0.049

endmodule
