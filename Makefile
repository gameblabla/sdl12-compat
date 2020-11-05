SRCDIR		= ./src 

ifeq ($(STATIC_ENABLED), 1)
TARGET = libSDL.a
else
TARGET = libSDL.so
endif

CFLAGS		+= -D_GNU_SOURCE -DHAVE_LIBC -D_REENTRANT -Isrc
CFLAGS		+= -std=gnu99 $(shell sdl2-config --cflags)

LDFLAGS		+= $(shell sdl2-config --libs)

VPATH		= $(SRCDIR)
SRC_C		= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.c))
OBJ_C		= $(notdir $(patsubst %.c, %.o, $(SRC_C)))
OBJS		= $(OBJ_C)

all: $(TARGET)

# Rules to make executable
$(TARGET): $(OBJS)  
ifeq ($(STATIC_ENABLED), 1)
	$(AR) rcs $(TARGET) $^
else
	$(CC) -shared $(CFLAGS) $^ -o $@ -ldl -ludev -ldrm $(LDFLAGS)
endif

$(OBJ_C) : %.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

install: install-headers install-lib
	
install-headers:
	cp -rp include/*.h $(DESTDIR)$(PREFIX)/include/SDL

install-lib:
	cp -rp $(TARGET) $(DESTDIR)$(PREFIX)/lib/
	cp -rp sdl.pc $(DESTDIR)$(PREFIX)/lib/pkgconfig
	cp -rp sdl-config $(DESTDIR)$(PREFIX)/bin

clean:
	rm -f $(TARGET) *.o *.a *.so
