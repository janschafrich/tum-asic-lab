########################
### General settings ###
########################
PREFIX?=/nas/ei/share/sec/tools/pulp-riscv-toolchain/bin/riscv32-unknown-elf-
CC=$(PREFIX)gcc
AS=$(CC) -x assembler-with-cpp
OBJCOPY=$(PREFIX)objcopy
OBJSIZE=$(PREFIX)size
PULPINO_REPO=$(shell realpath "utils")
SRECTOSLM=python2 "$(PULPINO_REPO)/s19toslm.py"

ARCHFLAGS=-march=rv32imfcxpulpv3 -mabi=ilp32
# machine flags: -msmall-data-limit is RISCV-specific, but can't be passed to LD
CFLAGS+=$(ARCHFLAGS) -msmall-data-limit=8
# diagnostics flags
CFLAGS+=-fmessage-length=0
# C options
CFLAGS+=-std=gnu11 -fsigned-char
CFLAGS+=-I"../lib"
CFLAGS+=-I"../string_lib"
# optimization options
CFLAGS+=-fdata-sections -ffunction-sections -Os
# debug options
CFLAGS+=-g0

LDFLAGS+=-T"link.riscv.ld" -nostartfiles -Wl,--gc-sections
LDFLAGS+=-Wl,-Map,"project.map"

########################
###   Library Files  ###
########################
LIBSRCS:=$(wildcard ../lib/*.c ../string_lib/*.c)
LIBSRCS_ASM=$(wildcard ../lib/*.S)

########################
###     Prefixes     ###
########################
LIBPREFIX = ../lib
BENCHTARGETPREFIX = ../src/bench_targets
KECCAKPREFIX = ../src/keccak

########################
###      KYBER       ###
########################
### KECCAK ###
KECCAKSRCS_C = \
	$(KECCAKPREFIX)/stackbench.c \
	$(KECCAKPREFIX)/fips202.c \
	$(KECCAKPREFIX)/keccakf1600.c \
	$(BENCHTARGETPREFIX)/main.c \

########################
###   Make Targets   ###
########################
.PHONY: all clean

all: clean keccak_bench

#################################
######## Keccak TARGET ########
#################################
keccak_bench: INCDIR += -I$(KECCAKPREFIX) -I${LIBPREFIX}
keccak_bench: CFLAGS += 
keccak_bench: keccak_bench.elf slm/keccak_bench.txt keccak_bench_instr.bin keccak_bench_data.bin

keccak_bench.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KECCAKSRCS_C:.c=.o) $(KECCAKSRCS_ASM:.S=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJSIZE) --format=berkeley $@

slm/keccak_bench.txt: keccak_bench.srec
	cd slm && $(SRECTOSLM) ../$^
	cp slm/spi_stim.txt ../../XCELIUM

keccak_bench_instr.bin: keccak_bench.elf
	$(OBJCOPY) -j .vectors -j '.text*' -O binary $^ $@

keccak_bench_data.bin: keccak_bench.elf
	$(OBJCOPY) -j .rodata -j .data -j .stack -O binary $^ $@


#################################
######## Adder TARGET ########
#################################
# adder: INCDIR += -I$(KECCAKPREFIX) -I${LIBPREFIX}
# adder: CFLAGS += 
# adder: adder.elf slm/adder.txt keccak_bench_instr.bin keccak_bench_data.bin

# adder.elf: $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(KECCAKSRCS_C:.c=.o) $(KECCAKSRCS_ASM:.S=.o)
# 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
# 	$(OBJSIZE) --format=berkeley $@

# slm/adder.txt: adder.srec
# 	cd slm && $(SRECTOSLM) ../$^
# 	cp slm/spi_stim.txt ../../XCELIUM

# keccak_bench_instr.bin: adder.elf
# 	$(OBJCOPY) -j .vectors -j '.text*' -O binary $^ $@

# keccak_bench_data.bin: adder.elf
# 	$(OBJCOPY) -j .rodata -j .data -j .stack -O binary $^ $@


########################
###    Resources     ###
########################
%.srec: %.elf
	$(OBJCOPY) -O srec --srec-len=1 $^ $@

%.siz: %.elf
	$(OBJSIZE) --format=berkeley $^ > $@

%.o: %.c
	$(CC) $(CFLAGS) -Wa,-adhlns="$(@:.o=.o.lst)" -MMD -MP -MF"$(@:.o=.d)" -MT $@ -o $@ -c $< $(INCDIR)

%_asm.o: %.S
	$(AS) $(CFLAGS) -Wa,-adhlns="$(@:.o=.o.lst)" -MMD -MP -MF"$(@:.o=.d)" -MT $@ -o $@ -c $<

%.S: %.c
	$(CC) $(CFLAGS) -o $@ -S $< $(INCDIR)

clean:
	rm -rf $(LIBSRCS:.c=.o) $(LIBSRCS_ASM:.S=.o) $(LIBSRCS:.c=.o.lst) $(LIBSRCS:.c=.d) $(LIBSRCS_ASM:.S=.d) $(LIBSRCS:.c=.su) $(LIBSRCS_ASM:.S=.su)
	rm -f $(KECCAKSRCS_C:.c=.o) $(KECCAKSSRCS_C:.c=.o.lst) $(KECCAKSRCS_C:.c=.d) $(KECCAKSRCS_C:.c=.S) $(KECCAKSRCS_C:.c=.su)
	rm -rf $(BENCHTARGETPREFIX)/*.o.lst
	rm -f *.elf *.srec *.siz *.map *.bin
	rm -f slm/flash_stim.slm
	rm -f slm/l2_ram_cut0_hi.slm
	rm -f slm/l2_ram_cut0_lo.slm
	rm -f slm/l2_stim.slm
	rm -f slm/spi_stim.txt
	rm -f slm/tcdm_bank0.slm
	rm -f ../../XCELIUM/spi_stim.txt 
	rm -rf ../../XCELIUM/work/*
