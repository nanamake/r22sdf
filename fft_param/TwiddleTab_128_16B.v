//----------------------------------------------------------------------
//  TwiddleTab: 128-Point 16-Bit Twiddle Factor Table
//----------------------------------------------------------------------
module TwiddleTab #(
    parameter   FFOUT = 0,      //  Registered Output
    parameter   N = 128,        //  Can Not Redefine
    parameter   NN = log2(N),   //  Can Not Redefine
    parameter   WIDTH = 16      //  Can Not Redefine
)(
    input               clock,      //  Master Clock
    input   [NN-1:0]    taddr,      //  Twiddle Table Address
    output  [WIDTH-1:0] tdata_r,    //  Twiddle Data (Real)
    output  [WIDTH-1:0] tdata_i     //  Twiddle Data (Imag)
);

//  log2 constant function
function integer log2;
    input integer x;
    integer value;
    begin
        value = x-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

//  Internal Regs and Nets
wire[WIDTH-1:0] wn_r[0:N-1];    //  Data Array (Real)
wire[WIDTH-1:0] wn_i[0:N-1];    //  Data Array (Imag)
wire[WIDTH-1:0] mx_tdata_r;     //  Multiplexer Output
wire[WIDTH-1:0] mx_tdata_i;     //  Multiplexer Output
reg [WIDTH-1:0] ff_tdata_r;     //  Registered Output
reg [WIDTH-1:0] ff_tdata_i;     //  Registered Output

//  Multiplexer
assign  mx_tdata_r = wn_r[taddr];
assign  mx_tdata_i = wn_i[taddr];

always @(posedge clock) begin
    ff_tdata_r <= mx_tdata_r;
    ff_tdata_i <= mx_tdata_i;
end

//  Output
assign  tdata_r = FFOUT ? ff_tdata_r : mx_tdata_r;
assign  tdata_i = FFOUT ? ff_tdata_i : mx_tdata_i;

//----------------------------------------------------------------------
//  Twiddle Data
//----------------------------------------------------------------------
//      wn_r = cos(-2pi*n/128)          wn_i = sin(-2pi*n/128)
assign  wn_r[ 0] = 16'h 0000;   assign  wn_i[ 0] = 16'h 0000;   //  0  1.000 -0.000
assign  wn_r[ 1] = 16'h 7FD9;   assign  wn_i[ 1] = 16'h F9B8;   //  1  0.999 -0.049
assign  wn_r[ 2] = 16'h 7F62;   assign  wn_i[ 2] = 16'h F374;   //  2  0.995 -0.098
assign  wn_r[ 3] = 16'h 7E9D;   assign  wn_i[ 3] = 16'h ED38;   //  3  0.989 -0.147
assign  wn_r[ 4] = 16'h 7D8A;   assign  wn_i[ 4] = 16'h E707;   //  4  0.981 -0.195
assign  wn_r[ 5] = 16'h 7C2A;   assign  wn_i[ 5] = 16'h E0E6;   //  5  0.970 -0.243
assign  wn_r[ 6] = 16'h 7A7D;   assign  wn_i[ 6] = 16'h DAD8;   //  6  0.957 -0.290
assign  wn_r[ 7] = 16'h 7885;   assign  wn_i[ 7] = 16'h D4E1;   //  7  0.942 -0.337
assign  wn_r[ 8] = 16'h 7642;   assign  wn_i[ 8] = 16'h CF04;   //  8  0.924 -0.383
assign  wn_r[ 9] = 16'h 73B6;   assign  wn_i[ 9] = 16'h C946;   //  9  0.904 -0.428
assign  wn_r[10] = 16'h 70E3;   assign  wn_i[10] = 16'h C3A9;   // 10  0.882 -0.471
assign  wn_r[11] = 16'h 6DCA;   assign  wn_i[11] = 16'h BE32;   // 11  0.858 -0.514
assign  wn_r[12] = 16'h 6A6E;   assign  wn_i[12] = 16'h B8E3;   // 12  0.831 -0.556
assign  wn_r[13] = 16'h 66D0;   assign  wn_i[13] = 16'h B3C0;   // 13  0.803 -0.596
assign  wn_r[14] = 16'h 62F2;   assign  wn_i[14] = 16'h AECC;   // 14  0.773 -0.634
assign  wn_r[15] = 16'h 5ED7;   assign  wn_i[15] = 16'h AA0A;   // 15  0.741 -0.672
assign  wn_r[16] = 16'h 5A82;   assign  wn_i[16] = 16'h A57E;   // 16  0.707 -0.707
assign  wn_r[17] = 16'h 55F6;   assign  wn_i[17] = 16'h A129;   // 17  0.672 -0.741
assign  wn_r[18] = 16'h 5134;   assign  wn_i[18] = 16'h 9D0E;   // 18  0.634 -0.773
assign  wn_r[19] = 16'h 4C40;   assign  wn_i[19] = 16'h 9930;   // 19  0.596 -0.803
assign  wn_r[20] = 16'h 471D;   assign  wn_i[20] = 16'h 9592;   // 20  0.556 -0.831
assign  wn_r[21] = 16'h 41CE;   assign  wn_i[21] = 16'h 9236;   // 21  0.514 -0.858
assign  wn_r[22] = 16'h 3C57;   assign  wn_i[22] = 16'h 8F1D;   // 22  0.471 -0.882
assign  wn_r[23] = 16'h 36BA;   assign  wn_i[23] = 16'h 8C4A;   // 23  0.428 -0.904
assign  wn_r[24] = 16'h 30FC;   assign  wn_i[24] = 16'h 89BE;   // 24  0.383 -0.924
assign  wn_r[25] = 16'h 2B1F;   assign  wn_i[25] = 16'h 877B;   // 25  0.337 -0.942
assign  wn_r[26] = 16'h 2528;   assign  wn_i[26] = 16'h 8583;   // 26  0.290 -0.957
assign  wn_r[27] = 16'h 1F1A;   assign  wn_i[27] = 16'h 83D6;   // 27  0.243 -0.970
assign  wn_r[28] = 16'h 18F9;   assign  wn_i[28] = 16'h 8276;   // 28  0.195 -0.981
assign  wn_r[29] = 16'h 12C8;   assign  wn_i[29] = 16'h 8163;   // 29  0.147 -0.989
assign  wn_r[30] = 16'h 0C8C;   assign  wn_i[30] = 16'h 809E;   // 30  0.098 -0.995
assign  wn_r[31] = 16'h 0648;   assign  wn_i[31] = 16'h 8027;   // 31  0.049 -0.999
assign  wn_r[32] = 16'h 0000;   assign  wn_i[32] = 16'h 8000;   // 32  0.000 -1.000
assign  wn_r[33] = 16'h F9B8;   assign  wn_i[33] = 16'h 8027;   // 33 -0.049 -0.999
assign  wn_r[34] = 16'h F374;   assign  wn_i[34] = 16'h 809E;   // 34 -0.098 -0.995
assign  wn_r[35] = 16'h xxxx;   assign  wn_i[35] = 16'h xxxx;   // 35 -0.147 -0.989
assign  wn_r[36] = 16'h E707;   assign  wn_i[36] = 16'h 8276;   // 36 -0.195 -0.981
assign  wn_r[37] = 16'h xxxx;   assign  wn_i[37] = 16'h xxxx;   // 37 -0.243 -0.970
assign  wn_r[38] = 16'h DAD8;   assign  wn_i[38] = 16'h 8583;   // 38 -0.290 -0.957
assign  wn_r[39] = 16'h D4E1;   assign  wn_i[39] = 16'h 877B;   // 39 -0.337 -0.942
assign  wn_r[40] = 16'h CF04;   assign  wn_i[40] = 16'h 89BE;   // 40 -0.383 -0.924
assign  wn_r[41] = 16'h xxxx;   assign  wn_i[41] = 16'h xxxx;   // 41 -0.428 -0.904
assign  wn_r[42] = 16'h C3A9;   assign  wn_i[42] = 16'h 8F1D;   // 42 -0.471 -0.882
assign  wn_r[43] = 16'h xxxx;   assign  wn_i[43] = 16'h xxxx;   // 43 -0.514 -0.858
assign  wn_r[44] = 16'h B8E3;   assign  wn_i[44] = 16'h 9592;   // 44 -0.556 -0.831
assign  wn_r[45] = 16'h B3C0;   assign  wn_i[45] = 16'h 9930;   // 45 -0.596 -0.803
assign  wn_r[46] = 16'h AECC;   assign  wn_i[46] = 16'h 9D0E;   // 46 -0.634 -0.773
assign  wn_r[47] = 16'h xxxx;   assign  wn_i[47] = 16'h xxxx;   // 47 -0.672 -0.741
assign  wn_r[48] = 16'h A57E;   assign  wn_i[48] = 16'h A57E;   // 48 -0.707 -0.707
assign  wn_r[49] = 16'h xxxx;   assign  wn_i[49] = 16'h xxxx;   // 49 -0.741 -0.672
assign  wn_r[50] = 16'h 9D0E;   assign  wn_i[50] = 16'h AECC;   // 50 -0.773 -0.634
assign  wn_r[51] = 16'h 9930;   assign  wn_i[51] = 16'h B3C0;   // 51 -0.803 -0.596
assign  wn_r[52] = 16'h 9592;   assign  wn_i[52] = 16'h B8E3;   // 52 -0.831 -0.556
assign  wn_r[53] = 16'h xxxx;   assign  wn_i[53] = 16'h xxxx;   // 53 -0.858 -0.514
assign  wn_r[54] = 16'h 8F1D;   assign  wn_i[54] = 16'h C3A9;   // 54 -0.882 -0.471
assign  wn_r[55] = 16'h xxxx;   assign  wn_i[55] = 16'h xxxx;   // 55 -0.904 -0.428
assign  wn_r[56] = 16'h 89BE;   assign  wn_i[56] = 16'h CF04;   // 56 -0.924 -0.383
assign  wn_r[57] = 16'h 877B;   assign  wn_i[57] = 16'h D4E1;   // 57 -0.942 -0.337
assign  wn_r[58] = 16'h 8583;   assign  wn_i[58] = 16'h DAD8;   // 58 -0.957 -0.290
assign  wn_r[59] = 16'h xxxx;   assign  wn_i[59] = 16'h xxxx;   // 59 -0.970 -0.243
assign  wn_r[60] = 16'h 8276;   assign  wn_i[60] = 16'h E707;   // 60 -0.981 -0.195
assign  wn_r[61] = 16'h xxxx;   assign  wn_i[61] = 16'h xxxx;   // 61 -0.989 -0.147
assign  wn_r[62] = 16'h 809E;   assign  wn_i[62] = 16'h F374;   // 62 -0.995 -0.098
assign  wn_r[63] = 16'h 8027;   assign  wn_i[63] = 16'h F9B8;   // 63 -0.999 -0.049
assign  wn_r[64] = 16'h xxxx;   assign  wn_i[64] = 16'h xxxx;   // 64 -1.000 -0.000
assign  wn_r[65] = 16'h xxxx;   assign  wn_i[65] = 16'h xxxx;   // 65 -0.999  0.049
assign  wn_r[66] = 16'h 809E;   assign  wn_i[66] = 16'h 0C8C;   // 66 -0.995  0.098
assign  wn_r[67] = 16'h xxxx;   assign  wn_i[67] = 16'h xxxx;   // 67 -0.989  0.147
assign  wn_r[68] = 16'h xxxx;   assign  wn_i[68] = 16'h xxxx;   // 68 -0.981  0.195
assign  wn_r[69] = 16'h 83D6;   assign  wn_i[69] = 16'h 1F1A;   // 69 -0.970  0.243
assign  wn_r[70] = 16'h xxxx;   assign  wn_i[70] = 16'h xxxx;   // 70 -0.957  0.290
assign  wn_r[71] = 16'h xxxx;   assign  wn_i[71] = 16'h xxxx;   // 71 -0.942  0.337
assign  wn_r[72] = 16'h 89BE;   assign  wn_i[72] = 16'h 30FC;   // 72 -0.924  0.383
assign  wn_r[73] = 16'h xxxx;   assign  wn_i[73] = 16'h xxxx;   // 73 -0.904  0.428
assign  wn_r[74] = 16'h xxxx;   assign  wn_i[74] = 16'h xxxx;   // 74 -0.882  0.471
assign  wn_r[75] = 16'h 9236;   assign  wn_i[75] = 16'h 41CE;   // 75 -0.858  0.514
assign  wn_r[76] = 16'h xxxx;   assign  wn_i[76] = 16'h xxxx;   // 76 -0.831  0.556
assign  wn_r[77] = 16'h xxxx;   assign  wn_i[77] = 16'h xxxx;   // 77 -0.803  0.596
assign  wn_r[78] = 16'h 9D0E;   assign  wn_i[78] = 16'h 5134;   // 78 -0.773  0.634
assign  wn_r[79] = 16'h xxxx;   assign  wn_i[79] = 16'h xxxx;   // 79 -0.741  0.672
assign  wn_r[80] = 16'h xxxx;   assign  wn_i[80] = 16'h xxxx;   // 80 -0.707  0.707
assign  wn_r[81] = 16'h AA0A;   assign  wn_i[81] = 16'h 5ED7;   // 81 -0.672  0.741
assign  wn_r[82] = 16'h xxxx;   assign  wn_i[82] = 16'h xxxx;   // 82 -0.634  0.773
assign  wn_r[83] = 16'h xxxx;   assign  wn_i[83] = 16'h xxxx;   // 83 -0.596  0.803
assign  wn_r[84] = 16'h B8E3;   assign  wn_i[84] = 16'h 6A6E;   // 84 -0.556  0.831
assign  wn_r[85] = 16'h xxxx;   assign  wn_i[85] = 16'h xxxx;   // 85 -0.514  0.858
assign  wn_r[86] = 16'h xxxx;   assign  wn_i[86] = 16'h xxxx;   // 86 -0.471  0.882
assign  wn_r[87] = 16'h C946;   assign  wn_i[87] = 16'h 73B6;   // 87 -0.428  0.904
assign  wn_r[88] = 16'h xxxx;   assign  wn_i[88] = 16'h xxxx;   // 88 -0.383  0.924
assign  wn_r[89] = 16'h xxxx;   assign  wn_i[89] = 16'h xxxx;   // 89 -0.337  0.942
assign  wn_r[90] = 16'h DAD8;   assign  wn_i[90] = 16'h 7A7D;   // 90 -0.290  0.957
assign  wn_r[91] = 16'h xxxx;   assign  wn_i[91] = 16'h xxxx;   // 91 -0.243  0.970
assign  wn_r[92] = 16'h xxxx;   assign  wn_i[92] = 16'h xxxx;   // 92 -0.195  0.981
assign  wn_r[93] = 16'h ED38;   assign  wn_i[93] = 16'h 7E9D;   // 93 -0.147  0.989
assign  wn_r[94] = 16'h xxxx;   assign  wn_i[94] = 16'h xxxx;   // 94 -0.098  0.995
assign  wn_r[95] = 16'h xxxx;   assign  wn_i[95] = 16'h xxxx;   // 95 -0.049  0.999
assign  wn_r[96] = 16'h xxxx;   assign  wn_i[96] = 16'h xxxx;   // 96 -0.000  1.000
assign  wn_r[97] = 16'h xxxx;   assign  wn_i[97] = 16'h xxxx;   // 97  0.049  0.999
assign  wn_r[98] = 16'h xxxx;   assign  wn_i[98] = 16'h xxxx;   // 98  0.098  0.995
assign  wn_r[99] = 16'h xxxx;   assign  wn_i[99] = 16'h xxxx;   // 99  0.147  0.989
assign  wn_r[100] = 16'h xxxx;   assign  wn_i[100] = 16'h xxxx;   // 100  0.195  0.981
assign  wn_r[101] = 16'h xxxx;   assign  wn_i[101] = 16'h xxxx;   // 101  0.243  0.970
assign  wn_r[102] = 16'h xxxx;   assign  wn_i[102] = 16'h xxxx;   // 102  0.290  0.957
assign  wn_r[103] = 16'h xxxx;   assign  wn_i[103] = 16'h xxxx;   // 103  0.337  0.942
assign  wn_r[104] = 16'h xxxx;   assign  wn_i[104] = 16'h xxxx;   // 104  0.383  0.924
assign  wn_r[105] = 16'h xxxx;   assign  wn_i[105] = 16'h xxxx;   // 105  0.428  0.904
assign  wn_r[106] = 16'h xxxx;   assign  wn_i[106] = 16'h xxxx;   // 106  0.471  0.882
assign  wn_r[107] = 16'h xxxx;   assign  wn_i[107] = 16'h xxxx;   // 107  0.514  0.858
assign  wn_r[108] = 16'h xxxx;   assign  wn_i[108] = 16'h xxxx;   // 108  0.556  0.831
assign  wn_r[109] = 16'h xxxx;   assign  wn_i[109] = 16'h xxxx;   // 109  0.596  0.803
assign  wn_r[110] = 16'h xxxx;   assign  wn_i[110] = 16'h xxxx;   // 110  0.634  0.773
assign  wn_r[111] = 16'h xxxx;   assign  wn_i[111] = 16'h xxxx;   // 111  0.672  0.741
assign  wn_r[112] = 16'h xxxx;   assign  wn_i[112] = 16'h xxxx;   // 112  0.707  0.707
assign  wn_r[113] = 16'h xxxx;   assign  wn_i[113] = 16'h xxxx;   // 113  0.741  0.672
assign  wn_r[114] = 16'h xxxx;   assign  wn_i[114] = 16'h xxxx;   // 114  0.773  0.634
assign  wn_r[115] = 16'h xxxx;   assign  wn_i[115] = 16'h xxxx;   // 115  0.803  0.596
assign  wn_r[116] = 16'h xxxx;   assign  wn_i[116] = 16'h xxxx;   // 116  0.831  0.556
assign  wn_r[117] = 16'h xxxx;   assign  wn_i[117] = 16'h xxxx;   // 117  0.858  0.514
assign  wn_r[118] = 16'h xxxx;   assign  wn_i[118] = 16'h xxxx;   // 118  0.882  0.471
assign  wn_r[119] = 16'h xxxx;   assign  wn_i[119] = 16'h xxxx;   // 119  0.904  0.428
assign  wn_r[120] = 16'h xxxx;   assign  wn_i[120] = 16'h xxxx;   // 120  0.924  0.383
assign  wn_r[121] = 16'h xxxx;   assign  wn_i[121] = 16'h xxxx;   // 121  0.942  0.337
assign  wn_r[122] = 16'h xxxx;   assign  wn_i[122] = 16'h xxxx;   // 122  0.957  0.290
assign  wn_r[123] = 16'h xxxx;   assign  wn_i[123] = 16'h xxxx;   // 123  0.970  0.243
assign  wn_r[124] = 16'h xxxx;   assign  wn_i[124] = 16'h xxxx;   // 124  0.981  0.195
assign  wn_r[125] = 16'h xxxx;   assign  wn_i[125] = 16'h xxxx;   // 125  0.989  0.147
assign  wn_r[126] = 16'h xxxx;   assign  wn_i[126] = 16'h xxxx;   // 126  0.995  0.098
assign  wn_r[127] = 16'h xxxx;   assign  wn_i[127] = 16'h xxxx;   // 127  0.999  0.049

endmodule
