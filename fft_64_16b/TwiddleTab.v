//----------------------------------------------------------------------
//  TwiddleTab: Radix-2^2 64-Point Twiddle Factor Table
//----------------------------------------------------------------------
module TwiddleTab (
    input   [5:0]   taddr,      //  Twiddle Table Address
    output  [15:0]  tdata_r,    //  Twiddle Factor (Real)
    output  [15:0]  tdata_i     //  Twiddle Factor (Imag)
);

wire[15:0]  wn_r[0:63];     //  Data Array (Real)
wire[15:0]  wn_i[0:63];     //  Data Array (Imag)

//  Data Output
assign  tdata_r = wn_r[taddr];
assign  tdata_i = wn_i[taddr];

//----------------------------------------------------------------------
//  Twiddle Data
//----------------------------------------------------------------------
//      wn_r = cos(-2pi*n/64)           wn_i = sin(-2pi*n/64)
assign  wn_r[ 0] = 16'h 0000;   assign  wn_i[ 0] = 16'h 0000;   //  0  1.000 -0.000
assign  wn_r[ 1] = 16'h 7F62;   assign  wn_i[ 1] = 16'h F374;   //  1  0.995 -0.098
assign  wn_r[ 2] = 16'h 7D8A;   assign  wn_i[ 2] = 16'h E707;   //  2  0.981 -0.195
assign  wn_r[ 3] = 16'h 7A7D;   assign  wn_i[ 3] = 16'h DAD8;   //  3  0.957 -0.290
assign  wn_r[ 4] = 16'h 7642;   assign  wn_i[ 4] = 16'h CF04;   //  4  0.924 -0.383
assign  wn_r[ 5] = 16'h 70E3;   assign  wn_i[ 5] = 16'h C3A9;   //  5  0.882 -0.471
assign  wn_r[ 6] = 16'h 6A6E;   assign  wn_i[ 6] = 16'h B8E3;   //  6  0.831 -0.556
assign  wn_r[ 7] = 16'h 62F2;   assign  wn_i[ 7] = 16'h AECC;   //  7  0.773 -0.634
assign  wn_r[ 8] = 16'h 5A82;   assign  wn_i[ 8] = 16'h A57E;   //  8  0.707 -0.707
assign  wn_r[ 9] = 16'h 5134;   assign  wn_i[ 9] = 16'h 9D0E;   //  9  0.634 -0.773
assign  wn_r[10] = 16'h 471D;   assign  wn_i[10] = 16'h 9592;   // 10  0.556 -0.831
assign  wn_r[11] = 16'h 3C57;   assign  wn_i[11] = 16'h 8F1D;   // 11  0.471 -0.882
assign  wn_r[12] = 16'h 30FC;   assign  wn_i[12] = 16'h 89BE;   // 12  0.383 -0.924
assign  wn_r[13] = 16'h 2528;   assign  wn_i[13] = 16'h 8583;   // 13  0.290 -0.957
assign  wn_r[14] = 16'h 18F9;   assign  wn_i[14] = 16'h 8276;   // 14  0.195 -0.981
assign  wn_r[15] = 16'h 0C8C;   assign  wn_i[15] = 16'h 809E;   // 15  0.098 -0.995
assign  wn_r[16] = 16'h 0000;   assign  wn_i[16] = 16'h 8000;   // 16  0.000 -1.000
assign  wn_r[17] = 16'h xxxx;   assign  wn_i[17] = 16'h xxxx;   // 17 -0.098 -0.995
assign  wn_r[18] = 16'h E707;   assign  wn_i[18] = 16'h 8276;   // 18 -0.195 -0.981
assign  wn_r[19] = 16'h xxxx;   assign  wn_i[19] = 16'h xxxx;   // 19 -0.290 -0.957
assign  wn_r[20] = 16'h CF04;   assign  wn_i[20] = 16'h 89BE;   // 20 -0.383 -0.924
assign  wn_r[21] = 16'h C3A9;   assign  wn_i[21] = 16'h 8F1D;   // 21 -0.471 -0.882
assign  wn_r[22] = 16'h B8E3;   assign  wn_i[22] = 16'h 9592;   // 22 -0.556 -0.831
assign  wn_r[23] = 16'h xxxx;   assign  wn_i[23] = 16'h xxxx;   // 23 -0.634 -0.773
assign  wn_r[24] = 16'h A57E;   assign  wn_i[24] = 16'h A57E;   // 24 -0.707 -0.707
assign  wn_r[25] = 16'h xxxx;   assign  wn_i[25] = 16'h xxxx;   // 25 -0.773 -0.634
assign  wn_r[26] = 16'h 9592;   assign  wn_i[26] = 16'h B8E3;   // 26 -0.831 -0.556
assign  wn_r[27] = 16'h 8F1D;   assign  wn_i[27] = 16'h C3A9;   // 27 -0.882 -0.471
assign  wn_r[28] = 16'h 89BE;   assign  wn_i[28] = 16'h CF04;   // 28 -0.924 -0.383
assign  wn_r[29] = 16'h xxxx;   assign  wn_i[29] = 16'h xxxx;   // 29 -0.957 -0.290
assign  wn_r[30] = 16'h 8276;   assign  wn_i[30] = 16'h E707;   // 30 -0.981 -0.195
assign  wn_r[31] = 16'h xxxx;   assign  wn_i[31] = 16'h xxxx;   // 31 -0.995 -0.098
assign  wn_r[32] = 16'h xxxx;   assign  wn_i[32] = 16'h xxxx;   // 32 -1.000 -0.000
assign  wn_r[33] = 16'h 809E;   assign  wn_i[33] = 16'h 0C8C;   // 33 -0.995  0.098
assign  wn_r[34] = 16'h xxxx;   assign  wn_i[34] = 16'h xxxx;   // 34 -0.981  0.195
assign  wn_r[35] = 16'h xxxx;   assign  wn_i[35] = 16'h xxxx;   // 35 -0.957  0.290
assign  wn_r[36] = 16'h 89BE;   assign  wn_i[36] = 16'h 30FC;   // 36 -0.924  0.383
assign  wn_r[37] = 16'h xxxx;   assign  wn_i[37] = 16'h xxxx;   // 37 -0.882  0.471
assign  wn_r[38] = 16'h xxxx;   assign  wn_i[38] = 16'h xxxx;   // 38 -0.831  0.556
assign  wn_r[39] = 16'h 9D0E;   assign  wn_i[39] = 16'h 5134;   // 39 -0.773  0.634
assign  wn_r[40] = 16'h xxxx;   assign  wn_i[40] = 16'h xxxx;   // 40 -0.707  0.707
assign  wn_r[41] = 16'h xxxx;   assign  wn_i[41] = 16'h xxxx;   // 41 -0.634  0.773
assign  wn_r[42] = 16'h B8E3;   assign  wn_i[42] = 16'h 6A6E;   // 42 -0.556  0.831
assign  wn_r[43] = 16'h xxxx;   assign  wn_i[43] = 16'h xxxx;   // 43 -0.471  0.882
assign  wn_r[44] = 16'h xxxx;   assign  wn_i[44] = 16'h xxxx;   // 44 -0.383  0.924
assign  wn_r[45] = 16'h DAD8;   assign  wn_i[45] = 16'h 7A7D;   // 45 -0.290  0.957
assign  wn_r[46] = 16'h xxxx;   assign  wn_i[46] = 16'h xxxx;   // 46 -0.195  0.981
assign  wn_r[47] = 16'h xxxx;   assign  wn_i[47] = 16'h xxxx;   // 47 -0.098  0.995
assign  wn_r[48] = 16'h xxxx;   assign  wn_i[48] = 16'h xxxx;   // 48 -0.000  1.000
assign  wn_r[49] = 16'h xxxx;   assign  wn_i[49] = 16'h xxxx;   // 49  0.098  0.995
assign  wn_r[50] = 16'h xxxx;   assign  wn_i[50] = 16'h xxxx;   // 50  0.195  0.981
assign  wn_r[51] = 16'h xxxx;   assign  wn_i[51] = 16'h xxxx;   // 51  0.290  0.957
assign  wn_r[52] = 16'h xxxx;   assign  wn_i[52] = 16'h xxxx;   // 52  0.383  0.924
assign  wn_r[53] = 16'h xxxx;   assign  wn_i[53] = 16'h xxxx;   // 53  0.471  0.882
assign  wn_r[54] = 16'h xxxx;   assign  wn_i[54] = 16'h xxxx;   // 54  0.556  0.831
assign  wn_r[55] = 16'h xxxx;   assign  wn_i[55] = 16'h xxxx;   // 55  0.634  0.773
assign  wn_r[56] = 16'h xxxx;   assign  wn_i[56] = 16'h xxxx;   // 56  0.707  0.707
assign  wn_r[57] = 16'h xxxx;   assign  wn_i[57] = 16'h xxxx;   // 57  0.773  0.634
assign  wn_r[58] = 16'h xxxx;   assign  wn_i[58] = 16'h xxxx;   // 58  0.831  0.556
assign  wn_r[59] = 16'h xxxx;   assign  wn_i[59] = 16'h xxxx;   // 59  0.882  0.471
assign  wn_r[60] = 16'h xxxx;   assign  wn_i[60] = 16'h xxxx;   // 60  0.924  0.383
assign  wn_r[61] = 16'h xxxx;   assign  wn_i[61] = 16'h xxxx;   // 61  0.957  0.290
assign  wn_r[62] = 16'h xxxx;   assign  wn_i[62] = 16'h xxxx;   // 62  0.981  0.195
assign  wn_r[63] = 16'h xxxx;   assign  wn_i[63] = 16'h xxxx;   // 63  0.995  0.098

endmodule
