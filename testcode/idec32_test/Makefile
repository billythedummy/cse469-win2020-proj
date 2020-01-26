TARGET=idec32_test
TOPMODULE=idec32
.PHONY: $(TARGET)
RTLSRC=../../cpu/idec32
all: $(TARGET)

CFLAGS=-g -O3

$(TARGET):
	verilator -Wno-fatal -I$(RTLSRC)/ --cc $(TOPMODULE).v --trace --exe ../$(@).cpp -CFLAGS "$(CFLAGS)"
	make -j8 -C obj_dir -f V$(TOPMODULE).mk
clean:: 
	rm -rf obj_dir
