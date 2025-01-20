# Target file name
TARGET = kernel8.img

COMPILER = kompile

# Source files
SRC = $(wildcard *.s)
MAIN_SRC = main.s

# Default rule
all: $(TARGET)

$(TARGET): $(MAIN_SRC) $(SRC)
	$(COMPILER) $(MAIN_SRC) $(TARGET)

# Clean up generated files
clean:
	rm -f $(TARGET)

.PHONY: all clean
