#!/bin/sh -x

if [ -d work ]; then
    rm -rf work
fi
vlib work

rtl_dir="./rtl"
tb_dir="."

vlog \
    $rtl_dir/FFT128.v \
    $rtl_dir/SdfUnit_TC.v \
    $rtl_dir/SdfUnit2.v \
    $rtl_dir/Butterfly.v \
    $rtl_dir/DelayBuffer.v \
    $rtl_dir/Multiply.v \
    $rtl_dir/TwiddleConvert8.v \
    $rtl_dir/Twiddle128.v \
    $tb_dir/TB128.v
