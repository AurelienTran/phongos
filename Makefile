CFLAGS = -Wall -Wextra -Werror -nostdlib -nostartfiles -nodefaultlibs

TARGET = kernel.bin
OBJECTS = kernel.o loader.o
IMAGE = harddrive.img

.PHONY: clean all

all: $(TARGET)

check: $(TARGET)
	./script.sh

$(TARGET): $(OBJECTS)
	ld -T linker.ld -o $@ $^

clean:
	$(RM) $(TARGET) $(OBJECTS) $(IMAGE)





CXXFLAGS=-g0 -O2 -Wall -Wextra -Werror -pedantic -Wno-variadic-macros -Wswitch-default -std=gnu++98 \
	-ffreestanding -nostdlib -fno-builtin -fno-rtti -fno-exceptions \
	-nostartfiles -nodefaultlibs
LDFLAGS=-ffreestanding -nostdlib -fno-builtin -fno-rtti -fno-exceptions

