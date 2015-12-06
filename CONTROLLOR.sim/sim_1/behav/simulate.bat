@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.3\\bin
call %xv_path%/xsim CONTROLLOR_VHDL_behav -key {Behavioral:sim_1:Functional:CONTROLLOR_VHDL} -tclbatch CONTROLLOR_VHDL.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
