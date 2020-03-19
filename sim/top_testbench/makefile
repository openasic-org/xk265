# Makefile to run verilog simulations
#
# Author: Yufeng Bai
#
# Version:
#	2013/09/21  Creation
# 
# Targets:
#	make vsim      run simulations using modelsim
#	make ncsim     run simulations using ncverilog
#	make vlog      compile modules only using modelsim
#	make nclog     compile modules only using ncverilog
#   make viewer    start wave viewer
#
# Notes for ncverilog:
#
# Notes for modelsim:
#
# A few notes on writing a Makefile
#  - Make sure commands are preceded by a "tab"; spaces will not work!
#  - You may also add dependencies so that a command will execute only
#    if the dependency has been updated more recently than the target
#    (name the target with the same name as the output of the command(s)).
#  - Use a "-n" flag to see what make will use without running the
#    command(s).  Ex: "make -n clean"


#----- Useful variables
NAME_TOP	:= tb_enc_top
PLATFORM        := $(shell uname )
#PLATFORM        := Linux
USERNAME	:= $(shell whoami)
SOURCE_FILE     := file_list
ifeq ($(PLATFORM),Linux)
	NOVAS_LIB 	:= /eda/synopsys/verdi201412/share/PLI/MODELSIM/LINUX/novas_fli.so
	NOVAS  		:= verdi
else
	NOVAS_LIB	:= "C:/Novas/Debussy/share/PLI/modelsim_pli/WINNT/novas.dll"
	NOVAS 	        := debussy
endif

NOVAS_HOME := /eda/synopsys/verdi201412/
export NOVAS_HOME

default:
	@echo 
	@echo "Make targets:"
	@echo "  make vsim      run simulations using modelsim"
	@echo "  make ncsim     run simulations using ncverilog"
	@echo "  make vlog      compile modules only using modelsim"
	@echo "  make nclog     compile modules only using ncverilog"
	@echo "  make viewer    start wave viewer"
#@echo "  PLATFORM       $(PLATFORM) "

#----- Targets, modelsim
# Use this to compile without running simulation
vlog:
	vlib ./work
	vmap work work
	vlog -sv +libext+.v   -incr -work ./work -f ./$(SOURCE_FILE).f

# Run simulation using modelsim
vsim:
	vlib ./work
	vmap work work
	vlog -sv +libext+.v  -incr -work ./work -f ./$(SOURCE_FILE).f
	vsim -pli $(NOVAS_LIB)  -l $(NAME_TOP).log  -novopt +nospecify work.$(NAME_TOP) -do "run -all"


#----- Targets, ncverilog
# Use this to compile without running simulation
nclog:
	ncverilog -c        -l $(NAME_TOP).log -f $(SOURCE_FILE).f

# Run simulation using ncverilog
ncsim:
	#setenv LD_LIBRARY_PATH /apps/EDAs/nova/Verdi201007/share/PLI/nc_latest/LINUX64/nc_shared
	ncverilog -sv +access+wrc +nctimescale+1ns/100ps +notimingcheck -l $(NAME_TOP).log -f $(SOURCE_FILE).f 

vcs:
	vcs -l ./dump/$(NAME_TOP).log \
	-sverilog \
	-f ./$(SOURCE_FILE).f \
	-P $(NOVAS_HOME)/share/PLI/VCS/LINUX/novas.tab $(NOVAS_HOME)/share/PLI/VCS/LINUX/pli.a \
	-fsdb -R -debug_all \
	-notimingchecks $*
#----- Wave viewer
viewer:
	$(NOVAS) -ssf $(NAME_TOP).fsdb -sswr $(NAME_TOP).rc
#----- Cleanup
# Delete temporary files
clean:
	rm -rf work/
	rm -rf INCA_libs/
	rm -rf model*
	rm -rf novas*
	rm -rf trans*
	rm -rf vsim.wlf

cleanall: clean
	rm -f  $(NAME_TOP).log
	rm -rf ./dump/*
	rm -f *.fsdb
	rm -rf ./*exeLog


