TARGET=ram_test
TOPMODULE=ram
.PHONY: $(TARGET)
RTLSRC=../../cpu
all: $(TARGET)

CFLAGS=-g -O3

$(TARGET):
	verilator -Wno-fatal -I$(RTLSRC)/ --cc $(TOPMODULE).v --trace --exe ../$(@).cpp -CFLAGS "$(CFLAGS)"
	make -C obj_dir -f V$(TOPMODULE).mk
clean:: 
	rm -rf obj_dir
