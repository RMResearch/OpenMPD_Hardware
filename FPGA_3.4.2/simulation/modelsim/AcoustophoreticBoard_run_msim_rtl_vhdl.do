transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/db {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/db/masterclock_altpll.v}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/RSSFilter.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/top.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/MuxPhase.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/Distribute.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/Counter.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/AllChannels.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/Masterclock.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/PhaseRAM.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/AmplitudeRAM.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/CommandReader.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/GammaCorrection.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/GammaCorrectionLUT.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/PulseWidthModulator.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/ParallelReceiver.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/CalibrationAndMapping.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/PhaseCalibration.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/PinMapping.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/FrameBufferController.vhd}
vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/src/FrameBufferFIFO.vhd}

vcom -93 -work work {C:/Users/Sri/Desktop/AcoustophoreticBoard_fpga_3.4.2/holo_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneive -L rtl_work -L work -voptargs="+acc"  holo_tb

add wave *
view structure
view signals
run 1 ms
