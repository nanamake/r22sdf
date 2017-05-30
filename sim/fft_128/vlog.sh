#!/bin/sh -x

if [ -d work ]; then
    rm -rf work
fi
vlib work

rtl_dir="./rtl"
tb_dir="."

vlog \
    $rtl_dir/FftTop_128_16B.v \
    $rtl_dir/SdfUnit_Param.v \
    $rtl_dir/SdfUnitLast.v \
    $rtl_dir/Butterfly.v \
    $rtl_dir/DelayBuf.v \
    $rtl_dir/TwiddleTab_128_16B.v \
    $rtl_dir/TabReduce.v \
    $rtl_dir/ComplexMul.v \
    $tb_dir/TB_128_16B.v
