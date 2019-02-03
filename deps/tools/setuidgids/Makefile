.PHONY: all clean

all: setuidgids

clean:
	rm -f setuidgids

setuidgids: src/setuidgids.c
	${CC} -O -Wall -D_GNU_SOURCE -o $@ $^
