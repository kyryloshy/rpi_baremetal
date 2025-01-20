# 02 Text

This project builds on [01-framebuffer](https://github.com/kyryloshy/rpi_baremetal/01-framebuffer) and implements console-like functionality for printing text.

In a little more detail, the [text.s](https://github.com/kyryloshy/rpi_baremetal/02-text/text.s) file implements purely text-drawing functionality. Using the raw_font file as a 8x8 bitmap, it transforms ASCII characters into 8x8 pixel drawings that get written to the screen.

For more console-like behaviour, [console.s](https://github.com/kyryloshy/rpi_baremetal/02-text/console.s) adds the console_init, console_print_char, and console_print_string functions, which are used to:
1. Initialize a console area on the screen
2. Keep track of the 'cursor' and the position for the next character
3. Use [text.s](https://github.com/kyryloshy/rpi_baremetal/02-text/text.s)'s functions to write strings at the correct location

This console has text-wrapping functionality, but doesn't implement scrolling yet. So, text strings that are too 'high' will potentially cause errors.

# Result

After running the program on a physical Raspberry Pi, or with QEMU:
```
qemu-system-aarch64 -M raspi3b -cpu cortex-a53 -monitor stdio -kernel kernel8.img
```
The final result should display a multi-line test string that can be changed in [main.s](https://github.com/kyryloshy/rpi_baremetal/02-text/main.s) if needed.


# Sources

This project didn't introduce any new external sources, as everything here builds on [01-framebuffer](https://github.com/kyryloshy/rpi_baremetal/01-framebuffer) and simply adds extra functionality.
