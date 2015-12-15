# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z010clg400-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.cache/wt [current_project]
set_property parent.project_path C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_vhdl -library xil_defaultlib {
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/TEXT_INPUT_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/FILE_INPUT_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/NANY_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/STR_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/OBYTE_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/SET_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/STATE_CONTROLLOR_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/BYTE_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/RSET_VHDL.vhd
  C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/sources_1/imports/CONTROLLOR/CONTROLLOR_VHDL.vhd
}
read_xdc C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/constrs_1/new/controllor.xdc
set_property used_in_implementation false [get_files C:/FPGAPrj/VIVADO/VIVADO/CONTROLLOR.srcs/constrs_1/new/controllor.xdc]

synth_design -top CONTROLLOR_VHDL -part xc7z010clg400-1
write_checkpoint -noxdef CONTROLLOR_VHDL.dcp
catch { report_utilization -file CONTROLLOR_VHDL_utilization_synth.rpt -pb CONTROLLOR_VHDL_utilization_synth.pb }
