file := src
target := SmithWaterman

CC := g++
CFLAGS := -Wall -g --std=c++11 -I $(file) 
CFLAGS := -Wall -O3 --std=c++11 -I $(file) 

SRCS := $(wildcard $(file)/*.cpp)
OBJS := $(patsubst %.cpp,%.o,$(SRCS))

.PHONY: all clean matrix trace both

all : MAKEFLAGS = $(CFLAGS)
matrix : MAKEFLAGS = -D DEBUG_PRINTMATRIX $(CFLAGS)
trace : MAKEFLAGS = -D TRACE $(CFLAGS)
both : MAKEFLAGS = -D DEBUG_PRINTMATRIX -D TRACE $(CFLAGS)

all: $(target)
matrix: $(target)
trace: $(target)
both: $(target)

$(target): $(OBJS)
	$(CC) -o $@ $(MAKEFLAGS) $^

%.o: %.cpp
	$(CC) $(MAKEFLAGS) -c $< -o $@

clean:
	rm -rf $(file)/*.o
	rm -rf $(target)
