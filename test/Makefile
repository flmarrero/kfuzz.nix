.PHONY: default
default: modules

obj-m = kfuzz.o

.PHONY: modules
modules:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules


.PHONY: clean
clean:
	rm -rf *.o *.mod.c *.mod *.symvers *.order *.ko .*.cmd
