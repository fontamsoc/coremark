#File : core_portme.mak

# Flag : OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o
# Flag : CC
#	Use this flag to define compiler to use
CC 		= pu32-elf-gcc
# Flag : LD
#	Use this flag to define compiler to use
LD		= pu32-elf-ld
# Flag : AS
#	Use this flag to define compiler to use
AS		= pu32-elf-as
OBJCOPY = pu32-elf-objcopy
OBJDUMP = pu32-elf-objdump
# Flag : CFLAGS
#	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
PORT_CFLAGS = -O3
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS)"
CFLAGS = $(PORT_CFLAGS) -g -ffreestanding -nostdlib -fstack-usage \
	-fdata-sections -ffunction-sections -Wl,--gc-sections \
	-Wl,-T$(PORT_DIR)/core_portme.lds -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"
#Flag : LFLAGS_END
#	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts). 
#	Note : On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
#SEPARATE_COMPILE=1
# Flag : SEPARATE_COMPILE
# You must also define below how to create an object file, and how to link.
OBJOUT 	= -o
LFLAGS 	= 
ASFLAGS =
OFLAG 	= -o
COUT 	= -c

LFLAGS_END = -lgcc
# Flag : PORT_SRCS
# 	Port specific source files can be added here
#	You may also need cvt.c if the fcvt functions are not provided as intrinsics by your compiler!
PORT_SRCS = $(PORT_DIR)/core_portme.c $(PORT_DIR)/ee_printf.c $(PORT_DIR)/cvt.c \
	$(PORT_DIR)/memcpy.c $(PORT_DIR)/memmove.c $(PORT_DIR)/memset.c
vpath %.c $(PORT_DIR)
vpath %.s $(PORT_DIR)

# Flag : LOAD
#	For a simple port, we assume self hosted compile and run, no load needed.

# Flag : RUN
#	For a simple port, we assume self hosted compile and run, simple invocation of the executable

LOAD = echo "Please set LOAD to the process of loading the executable to the flash"
RUN = echo "Please set LOAD to the process of running the executable (e.g. via jtag, or board reset)"

OEXT = .o
EXE = .elf

$(OPATH)$(PORT_DIR)/%$(OEXT) : %.c
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

$(OPATH)%$(OEXT) : %.c
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

$(OPATH)$(PORT_DIR)/%$(OEXT) : %.s
	$(AS) $(ASFLAGS) $< $(OBJOUT) $@

PORT_CLEAN = *$(OEXT) ${OPATH}*.su ${OPATH}*.bin ${OPATH}*.objdump ${OPATH}*.hex

# Target : port_pre% and port_post%
# For the purpose of this simple port, no pre or post steps needed.

.PHONY : port_prebuild port_postbuild port_prerun port_postrun port_preload port_postload
port_pre% port_post% :
port_postbuild:
	$(OBJCOPY) -O binary --set-section-flags .bss=alloc,load,contents ${OPATH}coremark$(EXE) ${OPATH}coremark.bin
	$(OBJDUMP) -Sdrl ${OPATH}coremark$(EXE) > ${OPATH}coremark$(EXE).objdump
	hexdump -v -e '/4 "%08x "' ${OPATH}coremark.bin > ${OPATH}coremark32.hex # 32bits.
	hexdump -v -e '/4 "%08x "' ${OPATH}coremark.bin | \
		{ while IFS=' ' read -n 18 V0 V1; do echo -n "$$V1$$V0 "; done; } > ${OPATH}coremark64.hex # 64bits.
	hexdump -v -e '/4 "%08x "' ${OPATH}coremark.bin | \
		{ while IFS=' ' read -n 36 V0 V1 V2 V3; do echo -n "$$V3$$V2$$V1$$V0 "; done; } > ${OPATH}coremark128.hex # 128bits.
	hexdump -v -e '/4 "%08x "' ${OPATH}coremark.bin | \
		{ while IFS=' ' read -n 72 V0 V1 V2 V3 V4 V5 V6 V7; do echo -n "$$V7$$V6$$V5$$V4$$V3$$V2$$V1$$V0 "; done; } > ${OPATH}coremark256.hex # 256bits.
	ls -lh ${OPATH}coremark.{bin,elf}*

# FLAG : OPATH
# Path to the output folder. Default - current folder.
OPATH = ./pu32/
MKDIR = mkdir -p

