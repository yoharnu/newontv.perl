$(CC) = gcc

INCLUDES = -I/home/plank/cs360/include

CFLAGS = -g $(INCLUDES)

LIBS = /home/plank/cs360/objs/libfdr.a -lpthread

OBJS = $(patsubst %.c,%.o,$(wildcard *.c))

EXEC = newontv

.PHONY: all
all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

.PHONY: clean
clean:
	rm -f $(EXEC) $(OBJS)
