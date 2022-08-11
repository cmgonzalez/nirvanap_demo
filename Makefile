
INCL = $(ZCCCFG)/../../include/_DEVELOPMENT/sdcc
ifeq ($(OS),Windows_NT)
	EP = '-e'
	ZCCCFG_CYG = $(shell cygpath -u $(ZCCCFG))
	Z88DK_PATH = $(shell echo $(ZCCCFG_CYG) | sed 's,/lib/config,,')
	Z88DK_PATH_WIN = $(shell echo $(ZCCCFG) | sed 's,/lib/config,,')
else
	EP = ''
	Z88DK_PATH = $(subst $(LIB),$(REP), $(ZCCCFG))
endif

# Parser Build Script
.PHONY: all test clean bas2tap

all:
	@echo Compiling Nirvana Demo
#Create Basic Tap from loader.bas
	@./utils/bas2tap -a10 -sPARSER loader.bas loader.tap
#Pack Loading Screen
	@appmake +zx -b screen.scr -o screen.tap --blockname loading --org 16384 --noloader		
#Compile Main Code
	zcc +zx -vn -SO3 -startup=1 -clib=sdcc_iy --max-allocs-per-node200000 nirvanadem.c btile.asm -o nirvanadem
	appmake +zx -b nirvanadem_NIRVANAP.bin -o nirvanap.tap --noloader --org 56323 --blockname NIRVANAP
	appmake +zx -b nirvanadem_CODE.bin -o nirvanadem.tap --noloader --org 32768 --blockname nirvanadem
#Concat final tap
	@cat loader.tap screen.tap nirvanap.tap nirvanadem.tap   > demo.tap
#Cleaning
	@rm loader.tap
	@rm screen.tap
	@rm nirvanap.tap
	@rm nirvanadem.tap
	@rm *.bin
clean:
	rm loader.tap
	rm main.tap
	rm *.bin


bas2tap:
	@echo Building bas2tap
	make -C ./bas2tap_src/
	cp ./bas2tap_src/bas2tap ./utils/bas2tap