#!/bin/sh -x

if [ -d work ]; then
    rm -rf work
fi
vlib work

rtl_dir="./rtl"
tb_dir="."

vlog \
    $rtl_dir/FFT64.v \
    $rtl_dir/SdfUnit.v \
    $rtl_dir/Butterfly.v \
    $rtl_dir/DelayBuffer.v \
    $rtl_dir/Multiply.v \
    $rtl_dir/Twiddle64.v \
    $tb_dir/TB64.v
