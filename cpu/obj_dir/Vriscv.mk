# Verilated -*- Makefile -*-
# DESCRIPTION: Verilator output: Makefile for building Verilated archive or executable
#
# Execute this makefile from the object directory:
#    make -f Vriscv.mk

default: Vriscv

### Constants...
# Perl executable (from $PERL)
PERL = perl
# Path to Verilator kit (from $VERILATOR_ROOT)
VERILATOR_ROOT = /usr/share/verilator
# SystemC include directory with systemc.h (from $SYSTEMC_INCLUDE)
SYSTEMC_INCLUDE ?= 
# SystemC library directory with libsystemc.a (from $SYSTEMC_LIBDIR)
SYSTEMC_LIBDIR ?= 

### Switches...
# C++ code coverage  0/1 (from --prof-c)
VM_PROFC = 0
# SystemC output mode?  0/1 (from --sc)
VM_SC = 0
# Legacy or SystemC output mode?  0/1 (from --sc)
VM_SP_OR_SC = $(VM_SC)
# Deprecated
VM_PCLI = 1
# Deprecated: SystemC architecture to find link library path (from $SYSTEMC_ARCH)
VM_SC_TARGET_ARCH = linux

### Vars...
# Design prefix (from --prefix)
VM_PREFIX = Vriscv
# Module prefix (from --prefix)
VM_MODPREFIX = Vriscv
# User CFLAGS (from -CFLAGS on Verilator command line)
VM_USER_CFLAGS = \
	-std=c++17 -I/home/pan/rv32-jichaung/cpu/semu/include \

# User LDLIBS (from -LDFLAGS on Verilator command line)
VM_USER_LDLIBS = \
	-lreadline -lcapstone \

# User .cpp files (from .cpp's on Verilator command line)
VM_USER_CLASSES = \
	cpu \
	init \
	reg \
	diff \
	dpi \
	exec \
	decoder \
	mem \
	run \
	sdb \
	semu-main \
	semu \

# User .cpp directories (from .cpp's on Verilator command line)
VM_USER_DIR = \
	/home/pan/rv32-jichaung/cpu/semu/src \
	/home/pan/rv32-jichaung/cpu/semu/src/cpu \
	/home/pan/rv32-jichaung/cpu/semu/src/diff \
	/home/pan/rv32-jichaung/cpu/semu/src/dpi \
	/home/pan/rv32-jichaung/cpu/semu/src/exec \
	/home/pan/rv32-jichaung/cpu/semu/src/isa \
	/home/pan/rv32-jichaung/cpu/semu/src/mem \
	/home/pan/rv32-jichaung/cpu/semu/src/run \
	/home/pan/rv32-jichaung/cpu/semu/src/sdb \
	/home/pan/rv32-jichaung/cpu/semu/src/semu \


### Default rules...
# Include list of all generated classes
include Vriscv_classes.mk
# Include global rules
include $(VERILATOR_ROOT)/include/verilated.mk

### Executable rules... (from --exe)
VPATH += $(VM_USER_DIR)

cpu.o: /home/pan/rv32-jichaung/cpu/semu/src/cpu/cpu.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
init.o: /home/pan/rv32-jichaung/cpu/semu/src/cpu/init.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
reg.o: /home/pan/rv32-jichaung/cpu/semu/src/cpu/reg.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
diff.o: /home/pan/rv32-jichaung/cpu/semu/src/diff/diff.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
dpi.o: /home/pan/rv32-jichaung/cpu/semu/src/dpi/dpi.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
exec.o: /home/pan/rv32-jichaung/cpu/semu/src/exec/exec.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
decoder.o: /home/pan/rv32-jichaung/cpu/semu/src/isa/decoder.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
mem.o: /home/pan/rv32-jichaung/cpu/semu/src/mem/mem.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
run.o: /home/pan/rv32-jichaung/cpu/semu/src/run/run.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
sdb.o: /home/pan/rv32-jichaung/cpu/semu/src/sdb/sdb.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
semu-main.o: /home/pan/rv32-jichaung/cpu/semu/src/semu-main.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<
semu.o: /home/pan/rv32-jichaung/cpu/semu/src/semu/semu.cpp
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST) -c -o $@ $<

### Link rules... (from --exe)
Vriscv: $(VK_USER_OBJS) $(VK_GLOBAL_OBJS) $(VM_PREFIX)__ALL.a $(VM_HIER_LIBS)
	$(LINK) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) $(LIBS) $(SC_LIBS) -o $@


# Verilated -*- Makefile -*-
