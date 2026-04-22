#!/usr/bin/env python3
import argparse
import random
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path

TERMINATOR_HEX = "00100073"
INST_BASE_ADDR = 0x2000

ERR_PC_RE = re.compile(r"Error occurrd at pc = 0x([0-9a-fA-F]+)")
UNSUPPORTED_RE = re.compile(r"Unsupported instruction:\s*0x([0-9a-fA-F]+)\s*at pc =\s*([0-9a-fA-F]+)")
DISASM_RE = re.compile(r"\s*0x([0-9a-fA-F]+):\s*([a-zA-Z0-9_.]+)\s*(.*)")

DEFAULT_TESTS = [
    "add",
    "addi",
    "and",
    "or",
    "xor",
    "sll",
    "srl",
    "sra",
    "sub",
    "ori",
    "lw",
    "sw",
    "beq",
    "bne",
    "jal",
    "jalr",
]


def run_checked(cmd, cwd=None):
    result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        stderr = result.stderr.strip() or "(no stderr)"
        stdout = result.stdout.strip() or "(no stdout)"
        raise RuntimeError(
            "Command failed: " + " ".join(cmd) + "\n"
            + "stdout:\n" + stdout + "\n"
            + "stderr:\n" + stderr
        )
    return result


def choose_toolchain():
    candidates = [
        ("riscv64-unknown-elf-as", "riscv64-unknown-elf-ld", "riscv64-unknown-elf-objcopy"),
        ("riscv64-unknown-elf-as", "riscv64-unknown-elf-ld", "objcopy"),
    ]
    for as_name, ld_name, objcopy_name in candidates:
        if shutil.which(as_name) and shutil.which(ld_name) and shutil.which(objcopy_name):
            return {"as": as_name, "ld": ld_name, "objcopy": objcopy_name}
    raise RuntimeError("Need riscv64-unknown-elf-as + riscv64-unknown-elf-ld + objcopy")


def emit_common(test_body: str) -> str:
    return (
        ".text\n"
        ".globl _start\n"
        "_start:\n"
        f"{test_body}\n"
        "    jal x0, pass\n"
        "fail:\n"
        "    .word 0x00000017\n"
        "pass:\n"
        "    ebreak\n"
    )


def gen_base_program_variants(test_name: str):
    t = test_name

    if t == "add":
        return [
            (
                "edge-wrap",
                emit_common(
                    """
    addi x5, x0, -1
    addi x6, x0, 1
    add x7, x5, x6
    bne x7, x0, fail

    srl x8, x5, x6          # max
    addi x9, x0, 31
    sll x10, x6, x9         # min
    add x11, x8, x6         # max+1=min
    bne x11, x10, fail

    add x12, x10, x8        # min+max=-1
    bne x12, x5, fail

    add x13, x12, x6        # -1+1=0
    bne x13, x0, fail
""".strip()
                ),
            ),
            (
                "dep-chain",
                emit_common(
                    """
    addi x5, x0, 3
    addi x6, x0, 4
    add x7, x5, x6          # 7
    add x7, x7, x6          # 11
    add x7, x7, x5          # 14
    addi x8, x0, 14
    bne x7, x8, fail

    addi x9, x0, 5
    addi x10, x0, 0
add_loop:
    add x10, x10, x9
    addi x9, x9, -1
    bne x9, x0, add_loop
    addi x11, x0, 15
    bne x10, x11, fail
""".strip()
                ),
            ),
        ]

    if t == "addi":
        return [
            (
                "i12-boundary",
                emit_common(
                    """
    addi x5, x0, 2047
    addi x5, x5, -2048
    addi x6, x0, -1
    bne x5, x6, fail

    addi x7, x6, 1
    bne x7, x0, fail

    addi x8, x0, 1
    addi x9, x0, 31
    sll x10, x8, x9         # min
    addi x11, x10, -1       # max
    srl x12, x6, x8
    bne x11, x12, fail

    addi x13, x12, 1        # max+1=min
    bne x13, x10, fail
""".strip()
                ),
            ),
            (
                "dep-stress",
                emit_common(
                    """
    addi x5, x0, 0
    addi x5, x5, 1
    addi x5, x5, 2
    addi x5, x5, 3
    addi x5, x5, 4
    addi x6, x0, 10
    bne x5, x6, fail

    addi x7, x0, -5
    addi x7, x7, 1
    addi x7, x7, 1
    addi x7, x7, 1
    addi x7, x7, 1
    addi x7, x7, 1
    bne x7, x0, fail
""".strip()
                ),
            ),
        ]

    if t == "and":
        return [
            (
                "mask-identity",
                emit_common(
                    """
    addi x5, x0, 85
    addi x6, x0, -1
    and x7, x5, x6
    bne x7, x5, fail

    and x8, x5, x0
    bne x8, x0, fail

    addi x9, x0, 1
    addi x10, x0, 31
    sll x11, x9, x10        # min
    srl x12, x6, x9         # max
    and x13, x11, x12
    bne x13, x0, fail
""".strip()
                ),
            ),
            (
                "dep-and-branch",
                emit_common(
                    """
    addi x5, x0, -1
    addi x6, x0, 15
    addi x7, x0, 0
    addi x8, x0, 4
and_loop:
    and x7, x5, x6
    addi x6, x6, -1
    addi x8, x8, -1
    bne x8, x0, and_loop
    addi x9, x0, 12
    bne x7, x9, fail
""".strip()
                ),
            ),
        ]

    if t == "or":
        return [
            (
                "identity-annihilator",
                emit_common(
                    """
    addi x5, x0, 85
    addi x6, x0, -1
    or x7, x5, x6
    bne x7, x6, fail

    or x8, x5, x0
    bne x8, x5, fail

    addi x9, x0, 1
    srl x10, x6, x9         # max
    addi x11, x0, 31
    sll x12, x9, x11        # min
    or x13, x10, x12
    bne x13, x6, fail
""".strip()
                ),
            ),
            (
                "dep-or-branch",
                emit_common(
                    """
    addi x5, x0, 0
    addi x6, x0, 1
    addi x7, x0, 5
or_loop:
    or x5, x5, x6
    sll x6, x6, x6          # shift by current value (1->2->8 via mask effects)
    addi x7, x7, -1
    bne x7, x0, or_loop
    bne x5, x0, pass_check
    jal x0, fail
pass_check:
""".strip()
                ),
            ),
        ]

    if t == "xor":
        return [
            (
                "self-inverse",
                emit_common(
                    """
    addi x5, x0, 123
    xor x6, x5, x5
    bne x6, x0, fail

    addi x7, x0, -1
    xor x8, x5, x7
    xor x9, x8, x7
    bne x9, x5, fail

    addi x10, x0, 1
    srl x11, x7, x10
    addi x12, x0, 31
    sll x13, x10, x12
    xor x14, x11, x13
    bne x14, x7, fail
""".strip()
                ),
            ),
            (
                "dep-xor-loop",
                emit_common(
                    """
    addi x5, x0, 0
    addi x6, x0, 1
    addi x7, x0, 6
xor_loop:
    xor x5, x5, x6
    addi x6, x6, 1
    addi x7, x7, -1
    bne x7, x0, xor_loop
    addi x8, x0, 7
    bne x5, x8, fail
""".strip()
                ),
            ),
        ]

    if t == "sll":
        return [
            (
                "shamt-edges",
                emit_common(
                    """
    addi x5, x0, 1
    addi x6, x0, 0
    sll x7, x5, x6
    bne x7, x5, fail

    addi x6, x0, 31
    sll x8, x5, x6
    sll x9, x5, x6
    bne x8, x9, fail

    addi x6, x0, 32
    sll x10, x5, x6
    bne x10, x5, fail

    addi x6, x0, 33
    sll x11, x5, x6
    addi x12, x0, 2
    bne x11, x12, fail
""".strip()
                ),
            ),
            (
                "shift-chain",
                emit_common(
                    """
    addi x5, x0, 3
    addi x6, x0, 2
    sll x5, x5, x6          # 12
    sll x5, x5, x6          # 48
    addi x7, x0, 48
    bne x5, x7, fail

    addi x8, x0, 4
    sll x9, x8, x8          # 64
    addi x10, x0, 64
    bne x9, x10, fail
""".strip()
                ),
            ),
        ]

    if t == "srl":
        return [
            (
                "logical-sign",
                emit_common(
                    """
    addi x5, x0, -1
    addi x6, x0, 31
    srl x7, x5, x6
    addi x8, x0, 1
    bne x7, x8, fail

    sll x9, x8, x6          # min
    srl x10, x9, x6
    bne x10, x8, fail

    addi x11, x0, 32
    srl x12, x5, x11
    bne x12, x5, fail
""".strip()
                ),
            ),
            (
                "dep-shift-loop",
                emit_common(
                    """
    addi x5, x0, 256
    addi x6, x0, 8
    srl x7, x5, x6
    addi x8, x0, 1
    bne x7, x8, fail

    addi x9, x0, 3
srl_loop:
    srl x5, x5, x8
    addi x9, x9, -1
    bne x9, x0, srl_loop
    addi x10, x0, 32
    bne x5, x10, fail
""".strip()
                ),
            ),
        ]

    if t == "sra":
        return [
            (
                "arith-sign",
                emit_common(
                    """
    addi x5, x0, -8
    addi x6, x0, 1
    sra x7, x5, x6
    addi x8, x0, -4
    bne x7, x8, fail

    addi x9, x0, -1
    addi x10, x0, 31
    sra x11, x9, x10
    bne x11, x9, fail

    addi x12, x0, 32
    sra x13, x5, x12
    bne x13, x5, fail
""".strip()
                ),
            ),
            (
                "dep-arith-loop",
                emit_common(
                    """
    addi x5, x0, -128
    addi x6, x0, 1
    addi x7, x0, 3
sra_loop:
    sra x5, x5, x6
    addi x7, x7, -1
    bne x7, x0, sra_loop
    addi x8, x0, -16
    bne x5, x8, fail
""".strip()
                ),
            ),
        ]

    if t == "sub":
        return [
            (
                "borrow-wrap",
                emit_common(
                    """
    sub x5, x0, x0
    bne x5, x0, fail

    addi x6, x0, 1
    sub x7, x0, x6
    addi x8, x0, -1
    bne x7, x8, fail

    addi x9, x0, 31
    sll x10, x6, x9         # min
    sub x11, x10, x6        # max
    srl x12, x8, x6
    bne x11, x12, fail

    sub x13, x12, x8        # min
    bne x13, x10, fail
""".strip()
                ),
            ),
            (
                "dep-sub-loop",
                emit_common(
                    """
    addi x5, x0, 20
    addi x6, x0, 1
    addi x7, x0, 5
sub_loop:
    sub x5, x5, x6
    addi x7, x7, -1
    bne x7, x0, sub_loop
    addi x8, x0, 15
    bne x5, x8, fail
""".strip()
                ),
            ),
        ]

    if t == "ori":
        return [
            (
                "signext-edges",
                emit_common(
                    """
    addi x5, x0, 0
    ori x6, x5, -2048
    addi x7, x0, -2048
    bne x6, x7, fail

    ori x8, x5, -1
    addi x9, x0, -1
    bne x8, x9, fail

    addi x10, x0, 1
    sll x11, x10, x10
    ori x12, x11, 2047
    addi x13, x0, 2047
    bne x12, x13, fail
""".strip()
                ),
            ),
            (
                "dep-ori-chain",
                emit_common(
                    """
    addi x5, x0, 0
    ori x5, x5, 1
    ori x5, x5, 2
    ori x5, x5, 4
    ori x5, x5, 8
    addi x6, x0, 15
    bne x5, x6, fail

    ori x7, x0, 0
    bne x7, x0, fail
""".strip()
                ),
            ),
        ]

    if t == "lw":
        return [
            (
                "addr-boundary",
                emit_common(
                    """
    addi x5, x0, 0
    addi x6, x0, 77
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    addi x6, x0, -33
    sw x6, 4(x5)
    lw x7, 4(x5)
    bne x7, x6, fail

    addi x8, x0, 4
    lw x9, -4(x8)
    addi x10, x0, 77
    bne x9, x10, fail

    addi x11, x0, 1023
    addi x12, x0, 2
    sll x11, x11, x12       # 4092
    addi x13, x0, 99
    sw x13, 0(x11)
    lw x14, 0(x11)
    bne x14, x13, fail
""".strip()
                ),
            ),
            (
                "load-use-hazard",
                emit_common(
                    """
    addi x5, x0, 16
    addi x6, x0, 12
    sw x6, 0(x5)
    lw x7, 0(x5)
    add x8, x7, x6
    addi x9, x0, 24
    bne x8, x9, fail

    lw x10, 0(x5)
    sub x11, x10, x6
    bne x11, x0, fail
""".strip()
                ),
            ),
        ]

    if t == "sw":
        return [
            (
                "addr-boundary",
                emit_common(
                    """
    addi x5, x0, 4
    addi x6, x0, 33
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    addi x6, x0, -77
    sw x6, 0(x5)
    lw x7, 0(x5)
    bne x7, x6, fail

    addi x8, x0, 8
    addi x9, x0, 55
    sw x9, -4(x8)
    lw x10, 0(x5)
    bne x10, x9, fail

    addi x11, x0, 1023
    addi x12, x0, 2
    sll x11, x11, x12
    addi x13, x0, 88
    sw x13, 0(x11)
    lw x14, 0(x11)
    bne x14, x13, fail
""".strip()
                ),
            ),
            (
                "store-forwarding",
                emit_common(
                    """
    addi x5, x0, 32
    addi x6, x0, 1
    addi x7, x0, 4
sw_loop:
    sw x6, 0(x5)
    lw x8, 0(x5)
    bne x8, x6, fail
    addi x6, x6, 1
    addi x7, x7, -1
    bne x7, x0, sw_loop

    addi x9, x0, 5
    bne x6, x9, fail
""".strip()
                ),
            ),
        ]

    if t == "beq":
        return [
            (
                "taken-nottaken",
                emit_common(
                    """
    addi x5, x0, 5
    addi x6, x0, 5
    beq x5, x6, beq_ok
    jal x0, fail
beq_ok:
    addi x6, x0, 6
    beq x5, x6, fail

    addi x7, x0, 3
beq_loop:
    addi x7, x7, -1
    beq x7, x0, beq_done
    jal x0, beq_loop
beq_done:

    beq x0, x0, beq_pass2
    jal x0, fail
beq_pass2:
""".strip()
                ),
            ),
            (
                "dep-branch",
                emit_common(
                    """
    addi x5, x0, 0
    addi x6, x0, 5
beq_dep_loop:
    addi x5, x5, 1
    beq x5, x6, beq_dep_done
    jal x0, beq_dep_loop
beq_dep_done:
    addi x7, x0, 5
    bne x5, x7, fail
""".strip()
                ),
            ),
        ]

    if t == "bne":
        return [
            (
                "taken-nottaken",
                emit_common(
                    """
    addi x5, x0, 5
    addi x6, x0, 6
    bne x5, x6, bne_ok
    jal x0, fail
bne_ok:
    addi x6, x0, 5
    bne x5, x6, fail

    addi x7, x0, 3
bne_loop:
    addi x7, x7, -1
    bne x7, x0, bne_loop

    bne x0, x0, fail
""".strip()
                ),
            ),
            (
                "dep-branch",
                emit_common(
                    """
    addi x5, x0, 0
    addi x6, x0, 4
bne_dep_loop:
    addi x5, x5, 1
    bne x5, x6, bne_dep_loop
    addi x7, x0, 4
    bne x5, x7, fail
""".strip()
                ),
            ),
        ]

    if t == "jal":
        return [
            (
                "nested-call",
                emit_common(
                    """
    addi x5, x0, 0
    jal x1, f1
ret_main:
    addi x5, x5, 1
    addi x6, x0, 5
    bne x5, x6, fail
    jal x0, pass

f1:
    addi x5, x5, 2
    add x10, x1, x0
    jal x1, f2
    addi x5, x5, 1
    add x1, x10, x0
    jalr x0, 0(x1)

f2:
    addi x5, x5, 1
    jalr x0, 0(x1)
""".strip()
                ),
            ),
            (
                "long-jump-flow",
                emit_common(
                    """
    addi x5, x0, 0
    jal x1, block_a
    addi x6, x0, 3
    bne x5, x6, fail
    jal x0, pass

block_a:
    addi x5, x5, 1
    add x10, x1, x0
    jal x1, block_b
    addi x5, x5, 1
    add x1, x10, x0
    jalr x0, 0(x1)

block_b:
    addi x5, x5, 1
    addi x6, x0, 2
    bne x5, x6, fail
    jalr x0, 0(x1)
""".strip()
                ),
            ),
        ]

    if t == "jalr":
        return [
            (
                "odd-align-return",
                emit_common(
                    """
    addi x5, x0, 0
    jal x1, odd_return
ret_after_odd:
    addi x5, x5, 2

    jal x1, via_reg
ret_after_reg:
    addi x5, x5, 2

    addi x6, x0, 6
    bne x5, x6, fail
    jal x0, pass

odd_return:
    addi x5, x5, 1
    addi x1, x1, 1
    jalr x0, 0(x1)

via_reg:
    addi x5, x5, 1
    add x10, x1, x0
    addi x0, x0, 0
    jalr x11, 0(x10)
""".strip()
                ),
            ),
            (
                "dep-forwarding",
                emit_common(
                    """
    addi x5, x0, 0
    jal x1, dep_target
ret_dep:
    addi x5, x5, 1
    addi x6, x0, 3
    bne x5, x6, fail
    jal x0, pass

dep_target:
    addi x5, x5, 1
    add x10, x1, x0
    addi x5, x5, 1
    jalr x0, 0(x10)
""".strip()
                ),
            ),
        ]

    raise RuntimeError(f"Unsupported test name: {test_name}")


def wrap_program_with_flow(program_text: str, wrap_mode: str) -> str:
    tail = "    jal x0, pass\nfail:\n    .word 0x00000017\npass:\n    ebreak\n"
    if not program_text.endswith(tail):
        raise RuntimeError("Unexpected program format while applying wrapper")

    head = program_text[: -len(tail)]
    start_marker = "_start:\n"
    if start_marker not in head:
        raise RuntimeError("_start label not found while applying wrapper")

    before_start, base_body = head.split(start_marker, 1)
    base_body = base_body.strip("\n")

    if wrap_mode == "x0flow":
        prelude = """
    addi x31, x0, 0
    addi x30, x0, 7
    add x0, x30, x30
    ori x0, x30, 3
    bne x0, x31, fail

    addi x29, x0, 3
wrapa_pre_loop:
    addi x31, x31, 1
    addi x29, x29, -1
    bne x29, x0, wrapa_pre_loop
    addi x28, x0, 3
    bne x31, x28, fail
""".strip()

        postlude = """
    addi x27, x0, 2
wrapa_post_loop:
    addi x31, x31, -1
    addi x27, x27, -1
    bne x27, x0, wrapa_post_loop
    addi x26, x0, 1
    bne x31, x26, fail
""".strip()
    elif wrap_mode == "mixflow":
        prelude = """
    addi x31, x0, 96
    addi x30, x0, 21
    sw x30, 0(x31)
    lw x29, 0(x31)
    bne x29, x30, fail
""".strip()

        postlude = """
    jal x1, wrapb_func
wrapb_ret:
    addi x25, x0, 28
    bne x29, x25, fail
    jal x0, wrapb_after

wrapb_func:
    addi x29, x29, 7
    add x24, x1, x0
    jalr x0, 0(x24)

wrapb_after:
""".strip()
    else:
        raise RuntimeError(f"Unknown wrap mode: {wrap_mode}")

    new_body = "\n\n".join([prelude, base_body, postlude])
    return before_start + start_marker + new_body + "\n" + tail


def gen_program_variants(test_name: str, topics_per_inst: int):
    if topics_per_inst < 2 or topics_per_inst > 4:
        raise RuntimeError("topics_per_inst must be in [2, 4]")

    base_variants = gen_base_program_variants(test_name)
    expanded = list(base_variants)

    if topics_per_inst >= 3:
        topic_name, asm_text = base_variants[0]
        expanded.append((f"{topic_name}-x0flow", wrap_program_with_flow(asm_text, "x0flow")))

    if topics_per_inst >= 4:
        topic_name, asm_text = base_variants[1]
        expanded.append((f"{topic_name}-mixflow", wrap_program_with_flow(asm_text, "mixflow")))

    return expanded


def gen_mixed_program_variants():
    mixed_1 = emit_common(
        """
    addi x5, x0, 0
    addi x6, x0, 4
    addi x7, x0, 1
mix1_loop:
    add x5, x5, x7
    addi x7, x7, 1
    addi x6, x6, -1
    bne x6, x0, mix1_loop

    addi x8, x0, 10
    bne x5, x8, fail

    addi x9, x0, 100
    sw x5, 0(x9)
    lw x10, 0(x9)
    bne x10, x8, fail

    beq x10, x8, mix1_beq_ok
    jal x0, fail
mix1_beq_ok:

    jal x1, mix1_func
mix1_ret:
    addi x11, x0, 13
    bne x10, x11, fail

    addi x12, x0, -8
    addi x13, x0, 1
    sra x14, x12, x13
    addi x15, x0, -4
    bne x14, x15, fail
    jal x0, mix1_done

mix1_func:
    addi x10, x10, 3
    add x16, x1, x0
    jalr x0, 0(x16)

mix1_done:
""".strip()
    )

    mixed_2 = emit_common(
        """
    addi x5, x0, 1
    addi x6, x0, 31
    sll x7, x5, x6
    srl x8, x7, x6
    bne x8, x5, fail

    addi x9, x0, -1
    xor x10, x9, x7
    or x11, x10, x5
    and x12, x11, x9
    bne x12, x11, fail

    addi x13, x0, 3
mix2_loop:
    addi x5, x5, 2
    sub x13, x13, x5
    addi x13, x13, 2
    addi x6, x6, -1
    bne x6, x0, mix2_loop

    addi x20, x0, 128
    sw x11, 0(x20)
    lw x21, 0(x20)
    bne x21, x11, fail

    jal x1, mix2_func_a
mix2_ret_a:
    jal x1, mix2_func_b
mix2_ret_b:
    addi x22, x0, 2
    bne x23, x22, fail
    bne x0, x0, fail
    jal x0, mix2_done

mix2_func_a:
    addi x23, x0, 1
    add x24, x1, x0
    jalr x0, 0(x24)

mix2_func_b:
    addi x23, x23, 1
    add x24, x1, x0
    jalr x0, 0(x24)

mix2_done:
""".strip()
    )

    metamorphic = emit_common(
        """
    addi x5, x0, 19
    addi x6, x0, 7

    add x7, x5, x6
    sub x8, x7, x6
    bne x8, x5, fail

    xor x9, x5, x6
    xor x10, x9, x6
    bne x10, x5, fail

    addi x11, x0, 1
    sll x12, x5, x11
    srl x13, x12, x11
    bne x13, x5, fail

    addi x14, x0, -1
    and x15, x5, x14
    bne x15, x5, fail

    ori x16, x0, -1
    xor x17, x16, x5
    xor x18, x17, x5
    bne x18, x16, fail
""".strip()
    )

    aliasing = emit_common(
        """
    addi x20, x0, 256
    addi x5, x0, 73
    sw x5, 0(x20)

    addi x21, x20, 4
    lw x6, -4(x21)
    bne x6, x5, fail

    addi x7, x0, -99
    sw x7, 12(x20)
    addi x22, x20, 8
    lw x8, 4(x22)
    bne x8, x7, fail

    addi x23, x0, 2044
    addi x9, x0, 55
    sw x9, 0(x23)
    addi x24, x23, 4
    lw x10, -4(x24)
    bne x10, x9, fail

    addi x11, x0, -33
    sw x11, -4(x24)
    lw x12, 0(x23)
    bne x12, x11, fail
""".strip()
    )

    pad_a = "\n".join(["    addi x0, x0, 0" for _ in range(80)])
    pad_b = "\n".join(["    addi x0, x0, 0" for _ in range(60)])
    branch_offset = emit_common(
        (
            """
    addi x5, x0, 1
    addi x6, x0, 2
    bne x5, x6, far_taken
    jal x0, fail

near_not_taken:
    addi x7, x0, 9
    addi x8, x0, 9
    bne x7, x8, fail
    beq x7, x8, backward_entry
    jal x0, fail

backward_entry:
    addi x9, x0, 7
backward_loop:
    addi x9, x9, -1
    bne x9, x0, backward_loop

    beq x0, x0, end_branch
    jal x0, fail

far_taken:
"""
            + pad_a
            + "\n"
            + """
    beq x5, x6, fail
    bne x5, x6, near_not_taken
    jal x0, fail

end_branch:
"""
            + pad_b
        ).strip()
    )

    return [
        ("mixed-core-path", mixed_1),
        ("mixed-control-mem", mixed_2),
        ("mixed-metamorphic", metamorphic),
        ("mixed-aliasing", aliasing),
        ("mixed-branch-offset", branch_offset),
    ]


def gen_seeded_random_program(seed: int, steps: int):
    rng = random.Random(seed)
    regs = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    code = [
        "    addi x20, x0, 512",
        "    addi x21, x0, 0",
        "    addi x22, x0, 1",
    ]

    for i in range(max(16, steps)):
        op = rng.choice(["addi", "add", "sub", "xor", "and", "or", "sll", "srl", "sra", "ori", "swlw", "br"])
        rd = rng.choice(regs)
        rs1 = rng.choice(regs)
        rs2 = rng.choice(regs)

        if op == "addi":
            imm = rng.randint(-32, 31)
            code.append(f"    addi x{rd}, x{rs1}, {imm}")
        elif op == "ori":
            imm = rng.randint(-32, 31)
            code.append(f"    ori x{rd}, x{rs1}, {imm}")
        elif op in {"add", "sub", "xor", "and", "or", "sll", "srl", "sra"}:
            code.append(f"    {op} x{rd}, x{rs1}, x{rs2}")
        elif op == "swlw":
            ofs = rng.choice([0, 4, 8, 12, 16, 20, 24, 28])
            code.append(f"    sw x{rs1}, {ofs}(x20)")
            code.append(f"    lw x{rd}, {ofs}(x20)")
            code.append(f"    bne x{rd}, x{rs1}, fail")
        else:
            # Keep branches local and deterministic to exercise control flow without exploding paths.
            lab = f"rnd_{seed}_{i}"
            code.append(f"    addi x21, x21, 1")
            code.append(f"    addi x22, x22, 1")
            if rng.randint(0, 1) == 0:
                code.append(f"    beq x21, x22, {lab}")
            else:
                code.append(f"    bne x21, x22, {lab}")
            code.append(f"{lab}:")

        if (i + 1) % 40 == 0:
            code.append(f"    jal x1, rnd_call_{seed}_{i}")
            code.append(f"rnd_ret_{seed}_{i}:")
            code.append(f"    jal x0, rnd_cont_{seed}_{i}")
            code.append(f"rnd_call_{seed}_{i}:")
            code.append("    add x24, x1, x0")
            code.append("    jalr x0, 0(x24)")
            code.append(f"rnd_cont_{seed}_{i}:")

    code.extend(
        [
            "    sw x5, 32(x20)",
            "    lw x23, 32(x20)",
            "    bne x23, x5, fail",
            "    addi x0, x23, 0",
            "    bne x0, x0, fail",
        ]
    )

    return emit_common("\n".join(code))


def gen_seeded_random_variants(seed_list, steps: int):
    variants = []
    for seed in seed_list:
        variants.append((f"mixed-random-seed{seed}", gen_seeded_random_program(seed, steps)))
    return variants


def parse_int_list(raw: str):
    out = []
    for tok in raw.split(","):
        tok = tok.strip()
        if not tok:
            continue
        out.append(int(tok))
    return out


def compile_and_convert(toolchain, asm_path: Path, elf_path: Path, bin_path: Path, hex_path: Path):
    obj_path = elf_path.with_suffix(".o")
    run_checked([toolchain["as"], "-march=rv32i", "-mabi=ilp32", "-o", str(obj_path), str(asm_path)])
    run_checked(
        [
            toolchain["ld"],
            "-m",
            "elf32lriscv",
            "-Ttext=0x2000",
            "--build-id=none",
            "-o",
            str(elf_path),
            str(obj_path),
        ]
    )
    run_checked([toolchain["objcopy"], "-O", "binary", "-j", ".text", str(elf_path), str(bin_path)])

    data = bin_path.read_bytes()
    if len(data) % 4 != 0:
        data += b"\x00" * (4 - len(data) % 4)

    lines = []
    for i in range(0, len(data), 4):
        w = struct.unpack("<I", data[i : i + 4])[0]
        lines.append(f"{w:08x}")
    lines.append(TERMINATOR_HEX)
    hex_path.write_text("\n".join(lines) + "\n", encoding="ascii")


def run_sim(sim_path: Path, hex_path: Path):
    result = subprocess.run(
        [str(sim_path), str(hex_path)],
        input="c\nq\n",
        capture_output=True,
        text=True,
    )
    output = (result.stdout or "") + (result.stderr or "")
    if "SEMU terminated successfully" in output:
        return "PASS", output
    if "SEMU terminated with errors" in output:
        return "FAIL", output
    if result.returncode != 0:
        return "ERROR", output
    return "UNKNOWN", output


def read_hex_word_at_pc(hex_path: Path, pc: int):
    if pc < INST_BASE_ADDR:
        return None
    offset = pc - INST_BASE_ADDR
    if offset % 4 != 0:
        return None
    idx = offset // 4

    try:
        lines = [line.strip() for line in hex_path.read_text(encoding="ascii").splitlines() if line.strip()]
    except OSError:
        return None

    if idx < 0 or idx >= len(lines):
        return None

    word = lines[idx].lower()
    if len(word) == 8 and all(c in "0123456789abcdef" for c in word):
        return word
    return None


def extract_failed_instruction(output: str, hex_path: Path):
    lines = output.splitlines()

    unsupported = UNSUPPORTED_RE.search(output)
    if unsupported:
        inst_hex = unsupported.group(1).lower()
        pc_hex = unsupported.group(2).lower()
        return f"pc=0x{pc_hex}, inst=0x{inst_hex} (unsupported)"

    for i, line in enumerate(lines):
        m = ERR_PC_RE.search(line)
        if not m:
            continue
        pc = int(m.group(1), 16)

        for j in range(i + 1, min(i + 5, len(lines))):
            d = DISASM_RE.match(lines[j])
            if d:
                mnemonic = d.group(2)
                operands = d.group(3).strip()
                asm = f"{mnemonic} {operands}".strip()
                word = read_hex_word_at_pc(hex_path, pc)
                if word:
                    return f"pc=0x{pc:08x}, asm={asm}, word=0x{word}"
                return f"pc=0x{pc:08x}, asm={asm}"

        word = read_hex_word_at_pc(hex_path, pc)
        if word:
            return f"pc=0x{pc:08x}, word=0x{word}"
        return f"pc=0x{pc:08x}"

    disasm_matches = [DISASM_RE.match(line) for line in lines]
    disasm_matches = [m for m in disasm_matches if m]
    if disasm_matches:
        m = disasm_matches[-1]
        pc = int(m.group(1), 16)
        mnemonic = m.group(2)
        operands = m.group(3).strip()
        asm = f"{mnemonic} {operands}".strip()
        word = read_hex_word_at_pc(hex_path, pc)
        if word:
            return f"pc=0x{pc:08x}, asm={asm}, word=0x{word}"
        return f"pc=0x{pc:08x}, asm={asm}"

    for line in lines:
        if "check failed" in line:
            return line.strip()

    return "No instruction detail found"


def format_output_tail(output: str, max_lines: int = 3):
    lines = [line.strip() for line in output.strip().splitlines() if line.strip()]
    if not lines:
        return "(no output)"
    return " | ".join(lines[-max_lines:])


def parse_tests(raw: str):
    return [x.strip() for x in raw.split(",") if x.strip()]


def main():
    parser = argparse.ArgumentParser(description="Batch generate multi-topic edge-case tests for 16 instructions")
    parser.add_argument("--tests", default=",".join(DEFAULT_TESTS), help="Comma-separated instruction names")
    parser.add_argument("--out-dir", default="cpu/riscv-tests-batch", help="Output directory")
    parser.add_argument("--sim-path", default="cpu/build/sim", help="Simulator path")
    parser.add_argument(
        "--topics-per-inst",
        type=int,
        default=4,
        choices=[2, 3, 4],
        help="How many topics to generate per instruction",
    )
    parser.add_argument(
        "--mixed-mode",
        default="append",
        choices=["none", "append", "only"],
        help="Generate mixed long-program suites: none/append/only",
    )
    parser.add_argument(
        "--random-seeds",
        default="11,29",
        help="Comma-separated seeds for deterministic random mixed programs",
    )
    parser.add_argument(
        "--random-steps",
        type=int,
        default=180,
        help="Instruction budget for each deterministic random mixed program",
    )
    parser.add_argument("--no-run", action="store_true", help="Only build and convert hex")
    parser.add_argument("--strict", action="store_true", help="Fail on non-PASS")
    args = parser.parse_args()

    root = Path.cwd()
    out_dir = (root / args.out_dir).resolve()
    sim_path = (root / args.sim_path).resolve()

    build_dir = out_dir / "build"
    hex_dir = out_dir / "hex"
    asm_dir = out_dir / "asm"
    log_dir = out_dir / "logs"
    for d in (build_dir, hex_dir, asm_dir, log_dir):
        d.mkdir(parents=True, exist_ok=True)

    toolchain = choose_toolchain()
    tests = parse_tests(args.tests)
    random_seeds = parse_int_list(args.random_seeds)
    if not random_seeds:
        raise RuntimeError("--random-seeds must include at least one seed")
    if args.random_steps < 16:
        raise RuntimeError("--random-steps must be >= 16")

    print("Toolchain mode: asld")
    print("Mode: multi-topic-edge-suite")
    print(f"Topics per instruction: {args.topics_per_inst}")
    print(f"Mixed mode: {args.mixed_mode}")
    print(f"Random seeds: {','.join(str(x) for x in random_seeds)}")
    print(f"Random steps: {args.random_steps}")
    if args.mixed_mode != "only":
        print(f"Instructions: {', '.join(tests)}")
    else:
        print("Instructions: skipped (mixed-mode only)")

    summary = []

    case_specs = []

    if args.mixed_mode != "only":
        for test_name in tests:
            variants = gen_program_variants(test_name, topics_per_inst=args.topics_per_inst)
            for topic, asm_text in variants:
                case_specs.append(
                    (
                        f"{test_name}.{topic}",
                        asm_dir / f"rv32ui-{test_name}-{topic}.S",
                        build_dir / f"rv32ui-{test_name}-{topic}.elf",
                        build_dir / f"rv32ui-{test_name}-{topic}.bin",
                        hex_dir / f"rv32ui-{test_name}-{topic}.hex",
                        asm_text,
                    )
                )

    if args.mixed_mode in {"append", "only"}:
        mixed_variants = gen_mixed_program_variants()
        mixed_variants.extend(gen_seeded_random_variants(random_seeds, args.random_steps))
        for topic, asm_text in mixed_variants:
            case_specs.append(
                (
                    f"mixed.{topic}",
                    asm_dir / f"rv32ui-mixed-{topic}.S",
                    build_dir / f"rv32ui-mixed-{topic}.elf",
                    build_dir / f"rv32ui-mixed-{topic}.bin",
                    hex_dir / f"rv32ui-mixed-{topic}.hex",
                    asm_text,
                )
            )

    print(f"Planned cases: {len(case_specs)}")

    for case_id, asm_path, elf_path, bin_path, hex_path, asm_text in case_specs:
        try:
            asm_path.write_text(asm_text, encoding="ascii")
            compile_and_convert(toolchain, asm_path, elf_path, bin_path, hex_path)

            if args.no_run:
                summary.append((case_id, "BUILT", str(hex_path)))
                print(f"[BUILT] {case_id}: {hex_path}")
            else:
                status, output = run_sim(sim_path, hex_path)
                safe_case = case_id.replace(".", "-")
                log_path = log_dir / f"{safe_case}.log"
                log_path.write_text(output, encoding="utf-8")

                if status == "PASS":
                    detail = format_output_tail(output)
                else:
                    inst_detail = extract_failed_instruction(output, hex_path)
                    tail = format_output_tail(output)
                    detail = f"{inst_detail} | tail: {tail}"

                summary.append((case_id, status, detail))
                print(f"[{status}] {case_id}: {detail}")
        except Exception as e:
            summary.append((case_id, "ERROR", str(e)))
            print(f"[ERROR] {case_id}: {e}")

    summary_path = out_dir / "summary.txt"
    with summary_path.open("w", encoding="utf-8") as f:
        for name, status, detail in summary:
            f.write(f"{name}\t{status}\t{detail}\n")

    failed_cases = [(n, s, d) for (n, s, d) in summary if s in {"FAIL", "ERROR", "UNKNOWN"}]
    if failed_cases:
        print("\nFailed case details:")
        for name, status, detail in failed_cases:
            print(f"- {name} [{status}] {detail}")

    print(f"Summary written: {summary_path}")

    if args.strict:
        bad = [s for _, s, _ in summary if s not in {"PASS", "BUILT"}]
        if bad:
            sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
