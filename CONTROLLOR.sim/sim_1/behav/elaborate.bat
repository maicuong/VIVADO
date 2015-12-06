@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.3\\bin
call %xv_path%/xelab  -wto 7673fcf6d76b4e3ab9a551fc50e85fa8 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot CONTROLLOR_VHDL_behav xil_defaultlib.CONTROLLOR_VHDL -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
