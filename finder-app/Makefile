all:
ifeq ($(strip $(CROSS_COMPILE)),)
	echo "native build pending..."
	gcc writer.c -o writer
	echo "native build successfully..."
endif
ifeq ($(CROSS_COMPILE), aarch64-none-linux-gnu-)
	echo "cross_compile build pending..."
	aarch64-none-linux-gnu-gcc writer.c -o writer
	echo "cross_compile build successfully..."
endif

.PHONY: clean
clean:
	rm -f writer
	rm -f *.o