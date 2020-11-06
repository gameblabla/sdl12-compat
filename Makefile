SRCDIR		= ./src 

ifeq ($(STATIC_ENABLED), 1)
TARGET = libSDL.a
else
TARGET = libSDL.so
endif

CFLAGS		+= -D_GNU_SOURCE -DHAVE_LIBC -D_REENTRANT -Isrc
CFLAGS		+= -std=gnu99 $(shell $(PKG_CONFIG) --cflags sdl2)

LDFLAGS		+= $(shell $(PKG_CONFIG) --libs sdl2)

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
	mkdir -p $(DESTDIR)$(PREFIX)/include/SDL
	cp -rp include/*.h $(DESTDIR)$(PREFIX)/include/SDL

install-lib:
	cp -rp $(TARGET) $(DESTDIR)$(PREFIX)/lib/
	cp -rp sdl.pc $(DESTDIR)$(PREFIX)/lib/pkgconfig/sdl.pc
	cp -rp sdl-config $(DESTDIR)$(PREFIX)/bin/sdl-config

clean:
	rm -f $(TARGET) *.o *.a *.so
