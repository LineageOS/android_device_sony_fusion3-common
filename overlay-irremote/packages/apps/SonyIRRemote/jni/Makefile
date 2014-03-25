# Define variables to be used within the build 
CC := arm-linux-gnueabi-gcc

# define to build all using the two requierd files
irtest: libsonyir
	$(CC) $@.c libsonyir.a -o $@ -static

libsonyir:
	$(CC) $@.c -c -o $@.a 

# define to clean the directory
clean:
	rm -f irtest *.so *.o *.a


