file := src
target := exec

CC := g++
CFLAGS := -Wall -g --std=c++11 -I $(file)
CFLAGS := -Wall -O3 --std=c++11 -I $(file)

SRCS := $(wildcard $(file)/*.cpp)
OBJS := $(patsubst %.cpp,%.o,$(SRCS))

.PHONY: all clean

all: $(target)

$(target): $(OBJS)
	$(CC) -o $@ $(CFLAGS) $^

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(file)/*.o
	rm -rf $(exec)
