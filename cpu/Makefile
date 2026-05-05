# ===================== 基本配置 =====================
TOP        := riscv
RTL_MODE   ?= rtl

ROOT       := $(abspath .)
BUILD_DIR  := $(ROOT)/build
OBJ_DIR    := $(ROOT)/obj_dir

RTL_TREE_DIR := $(ROOT)/rtl/rtl
RTL_INC_DIR  := $(ROOT)/rtl/includes
RTL_FLAT_SRC := $(ROOT)/riscv.v

SEMU_DIR   := $(ROOT)/semu
SEMU_SRC_DIR := $(SEMU_DIR)/src
SEMU_INC_DIR := $(SEMU_DIR)/include

VERILATOR  := verilator

# ===================== RTL 源码选择 =====================
ifeq ($(RTL_MODE),rtl)
VSRCS := $(wildcard $(RTL_TREE_DIR)/*.v)
RTL_DESC := rtl/rtl/*.v
else ifeq ($(RTL_MODE),single)
VSRCS := $(RTL_FLAT_SRC)
RTL_DESC := riscv.v
else
$(error Unsupported RTL_MODE '$(RTL_MODE)'. Use RTL_MODE=rtl or RTL_MODE=single)
endif

SEMU_SRCS := $(shell find $(SEMU_SRC_DIR) -name "*.cpp")

# ===================== 编译参数 =====================
CXXFLAGS := -std=c++17 -I$(SEMU_INC_DIR)
LDFLAGS  := -lreadline -lcapstone

VERILATOR_FLAGS := \
	-cc --exe --build \
	--trace \
	-O2 \
	-I$(RTL_INC_DIR) \
	-I$(RTL_TREE_DIR)

# ===================== 目标 =====================
TARGET := $(BUILD_DIR)/sim

# ===================== 默认目标 =====================
all: clean
	$(MAKE) $(TARGET)

# ===================== 构建 =====================
$(TARGET):
	@echo "===> Building with Verilator (RTL_MODE=$(RTL_MODE), source=$(RTL_DESC))..."
	@mkdir -p $(BUILD_DIR)

	$(VERILATOR) \
		$(VERILATOR_FLAGS) \
		--top-module $(TOP) \
		$(VSRCS) \
		$(SEMU_SRCS) \
		-CFLAGS "$(CXXFLAGS)" \
		-LDFLAGS "$(LDFLAGS)" \
		-o sim

	@mv $(OBJ_DIR)/sim $(TARGET)

# ===================== 运行 =====================
run: clean
	$(MAKE) $(TARGET)
	$(TARGET)

single: clean
	$(MAKE) RTL_MODE=single $(TARGET)

run-single: clean
	$(MAKE) RTL_MODE=single $(TARGET)
	$(TARGET)

rtl: clean
	$(MAKE) RTL_MODE=rtl $(TARGET)

run-rtl: clean
	$(MAKE) RTL_MODE=rtl $(TARGET)
	$(TARGET)

# ===================== 清理 =====================
clean:
	rm -rf $(BUILD_DIR) $(OBJ_DIR) *.vcd

# ===================== 调试 =====================
print:
	@echo "RTL_MODE: $(RTL_MODE)"
	@echo "RTL source set: $(RTL_DESC)"
	@echo "RTL SRCS:"
	@echo $(VSRCS)
	@echo "SEMU SRCS:"
	@echo $(SEMU_SRCS)

.PHONY: all run single run-single rtl run-rtl clean print
