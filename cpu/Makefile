# ===================== 基本配置 =====================
TOP        := riscv

ROOT       := $(abspath .)
BUILD_DIR  := $(ROOT)/build
OBJ_DIR    := $(ROOT)/obj_dir

RTL_DIR    := $(ROOT)/rtl/rtl
RTL_INC    := $(ROOT)/rtl/includes

SEMU_DIR   := $(ROOT)/semu
SEMU_SRC_DIR := $(SEMU_DIR)/src
SEMU_INC_DIR := $(SEMU_DIR)/include

VERILATOR  := verilator

# ===================== 自动收集文件 =====================
VSRCS := $(filter-out $(RTL_DIR)/riscv_original.v,$(wildcard $(RTL_DIR)/*.v))

SEMU_SRCS := $(shell find $(SEMU_SRC_DIR) -name "*.cpp")

# ===================== 编译参数 =====================
CXXFLAGS := -std=c++17 -I$(SEMU_INC_DIR)
LDFLAGS  := -lreadline -lcapstone

VERILATOR_FLAGS := \
	-cc --exe --build \
	--trace \
	-O2 \
	-I$(RTL_INC) \
	-I$(RTL_DIR)

# ===================== 目标 =====================
TARGET := $(BUILD_DIR)/sim

# ===================== 默认目标 =====================
all: clean
	$(MAKE) $(TARGET)

# ===================== 构建 =====================
$(TARGET):
	@echo "===> Building with Verilator..."
	@mkdir -p $(BUILD_DIR)

	$(VERILATOR) \
		$(VERILATOR_FLAGS) \
		--top-module $(TOP) \
		$(VSRCS) \
		$(SEMU_SRCS) \
		-CFLAGS "$(CXXFLAGS)" \
		-LDFLAGS "$(LDFLAGS)"

	@mv obj_dir/Vriscv $(TARGET)

# ===================== 运行 =====================
run: clean
	$(MAKE) $(TARGET)
	$(TARGET)

# ===================== 清理 =====================
clean:
	rm -rf $(BUILD_DIR) $(OBJ_DIR) *.vcd

# ===================== 调试 =====================
print:
	@echo "RTL SRCS:"
	@echo $(VSRCS)
	@echo "SEMU SRCS:"
	@echo $(SEMU_SRCS)

.PHONY: all run clean print
