#!/bin/sh -x

if [ -d work ]; then
    rm -rf work
fi
vlib work

rtl_dir="./rtl"
tb_dir="."

vlog \
    $rtl_dir/FftTop.v \
    $rtl_dir/SdfUnit.v \
    $rtl_dir/Butterfly.v \
    $rtl_dir/DelayBuf.v \
    $rtl_dir/TwiddleTab.v \
    $rtl_dir/ComplexMul.v \
    $tb_dir/TB.v
