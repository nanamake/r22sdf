r22sdf
======

R2<sup>2</sup>SDF FFT Implementation in Verilog HDL

* Pipelined Architecture
* 64-Point 16-Bit Word Length

There are also parameterized codes which can be used to create modules
with different FFT size and word length.


Interface
---------

Data must be input consecutively in natural order. The result is output
in bit-reversed order. The output latency is 71 clock cycles.

    module FftTop (
        input           clock,      //  Master Clock
        input           reset,      //  Active High Asynchronous Reset
        input           idata_en,   //  Input Data Enable
        input   [15:0]  idata_r,    //  Input Data (Real)
        input   [15:0]  idata_i,    //  Input Data (Imag)
        output          odata_en,   //  Output Data Enable
        output  [15:0]  odata_r,    //  Output Data (Real)
        output  [15:0]  odata_i     //  Output Data (Imag)
    );


Files
-----

    r22sdf/
        fft_64_16b/     64-point 16-bit FFT codes
        fft_param/      Parameterized FFT codes
        quartus/        Implementation reports
        sim/            Testbench

        README.md       This file
        LICENSE         MIT License
