load_end "text.s"

align 4
label CONSOLE_BG_COLOR
// bytes 4, 0xFF000000
bytes 4, 0xFFFFFFFF

// Console struct (40 bytes), 8-byte aligned:
// 0 fb struct address
// 8 start_x
// 12 start_y
// 16 width
// 20 height
// 24 data_width
// 28 data_height
// 32 cursor_x
// 36 cursor_y

// Console init function
// Arguments:
// x0 - console struct address
// x1 - fb struct address
// x2 - start x
// x3 - start y
// x4 - width
// x5 - height
// Uses:
// x0-x12
label console_init

// Write data to console struct

str_unsigned x1, x0, 0
str_unsigned w2, x0, 8 // start_x
str_unsigned w3, x0, 12 // start_y
str_unsigned w4, x0, 16 // width
str_unsigned w5, x0, 20 // height

// Calculate data width and data height

mov x6, 8 // Font width (pixels)
mov x7, 0 // Counter for data width

cmp x4, x6 // Compare width left to font width
b.lt 4 // Skip loop if no more characters will fit
sub x4, x4, x6 // Subtract font width from width left
add x7, x7, 1 // Increment data width
b -4 // Repeat

str_unsigned w7, x0, 24 // Store data width in console struct

// Do the same for height

mov x6, 8 // Font height (pixels)
mov x7, 0 // Counter for data height

cmp x5, x6 // Compare height left to font height
b.lt 4 // Skip loop if no more characters will fit
sub x5, x5, x6 // Subtract font height from height left
add x7, x7, 1 // Increment data height
b -4 // Repeat

str_unsigned w7, x0, 28 // Store data height in console struct

mov x1, 0

str_unsigned w1, x0, 32 // Set cursor_x to 0
str_unsigned w1, x0, 36 // Set cursor_y to 0

br lr // Return



// Console print character function
// Arguments:
// x0 - console struct address
// x1 - character (ascii)
// Uses:
// 
label console_print_char

mov x28, 0xFF0

cmp x1, '\n' // Check if the character is a newline
b.eq console_print_newline // If yes, branch to console_print_newline

add x28, x28, 1

// Save return address to stack pointer
str_pre_index lr, sp, -8


add x28, x28, 1

// First step: load data from console struct into registers
ldr x2, x0 // Load the fb struct address into x2

ldr_unsigned w3, x0, 8 // Load start_x into x3
ldr_unsigned w4, x0, 12 // Load start_y into x4
ldr_unsigned w5, x0, 32 // Load cursor_x into x5
ldr_unsigned w6, x0, 36 // Load cursor_y into x6

add x28, x28, 1

//
// Draw the character space in bg color
//

// Calculate the coordinate for the character square
ldr x8, FONT_WIDTH
madd x3, x5, x8, x3 // x3 += x5 * x7 (start_x = start_x + cursor_x * font_width)

ldr x9, FONT_HEIGHT
madd x4, x6, x9, x4 // same as above, but for y in x4

add x28, x28, 1

// Calculate the starting pixel address for the character square

ldr_unsigned w6, x2, 8 // Load fb pitch into x6

ldr_unsigned w5, x2, 0 // Load fb base address into x5

add x28, x28, 1

madd x5, x4, x6, x5 // x5 += x4 * x6 (pixel address = fb_base_address + start_y * fb_pitch)

mov x7, 4 // 4 bytes / 32 bits - bytes per pixel

add x28, x28, 1

madd x5, x3, x7, x5 // x5 += x3 * x7 (pixel_address += start_x * bytes_per_pixel)

// Registers:
// x0 - console struct address
// x1 - character
// x2 - fb struct address
// x3 - start pixel x
// x4 - start pixel y
// x5 - pixel address
// x6 - fb pitch
// x7 - font width
// x8 - font width left (x strides left)
// x9 - font height left (y strides left)
// x10 - bg color
// x11 - bytes per pixel (4)

mov x11, 4

mov x7, x8 // Keep a copy of font width in x7

add x28, x28, 1

adr x10, CONSOLE_BG_COLOR
ldr w10, x10

label console_print_char_y_loop

mov x8, x7 // Restore x-strides left

label console_print_char_x_loop

str w10, x5 // Write the pixel
add x5, x5, 4 // Move to the next pixel
sub x8, x8, 1 // Decrement x-strides left
cmp x8, 0 // Compare x-strides left to zero
b.eq 2 // If equal, exit the char_x_loop
b console_print_char_x_loop // Repeat

// print_char_y_loop here
sub x9, x9, 1 // Decrement y-strides left
add x5, x5, x6 // Move to the next row of pixels (but x is still the same)
msub x5, x7, x11, x5 // Move to the correct x coordinate (address = address - font_width * bytes_per_pixel)
cmp x9, 0 // Compare y-strides left to zero
b.eq 2 // If equal, exit the loop
b console_print_char_y_loop // Repeat

// Here after the loop

// Draw the character using draw_char
// Only thing to keep / remember is the console struct address. draw_char uses x0 to x11, so put it in x12

mov x12, x0 // Keep console struct address away from draw_char

// Set arguments for draw_char:
mov x0, x2
mov x2, x3
mov x3, x4

bl draw_char // Call draw_char


// Next step: Change the cursor position to the next character

// Load cursor_x, cursor_y, data_width and data_height from console_struct

mov x0, x12 // Move console_struct address back to x0

ldr_unsigned w1, x0, 24 // Load data_width into x1
ldr_unsigned w2, x0, 28 // Load data_height into x2
ldr_unsigned w3, x0, 32 // Load cursor_x into x3
ldr_unsigned w4, x0, 36 // Load cursor_y into x4

add x3, x3, 1 // Move to the next character (x-wise)

cmp x3, x1 // Compare cursor_x to data_width
b.lt console_print_char_after_row_change // If less than, skip moving to the next row

// If here, cursor_x is too large (exits the boundaries of the console)
// Actions: Move to the next row, and set cursor_x to zero
add x4, x4, 1 // Move to the next row
mov x3, 0 // Set cursor_x to zero

label console_print_char_after_row_change // Mark the end of moving to the next row (for skipping)

// Save new values to memory
str_unsigned w3, x0, 32 // Write cursor_x
str_unsigned w4, x0, 36 // Write cursor_y

// Get return address
ldr lr, sp
add sp, sp, 8

br lr // Return




label console_print_newline

ldr_unsigned w1, x0, 32 // Load cursor_x into x3
ldr_unsigned w2, x0, 36 // Load cursor_y into x4

mov x1, 0
add x2, x2, 1

str_unsigned w1, x0, 32 // Write cursor_x
str_unsigned w2, x0, 36 // Write cursor_y

br lr // Return







// Console print string function
// Arguments:
// x0 - console struct
// x1 - string address (\0 terminated)
// Uses:
// draw_char + x13-x14
// x0 - x14
label console_print_string

mov x28, 0

// Save return address to stack pointer
str_pre_index lr, sp, -8

add x28, x28, 1

// console_print_char uses x0-x12. To remember the string and console struct, move x0 and x1 to x13 and x14
mov x13, x0
mov x14, x1

add x28, x28, 1

ldrb w1, x14 // Load a character from the string
cmp x1, '\0' // Compare x1 to the null character
b.eq 5 // Skip if \0


mov x0, x13 // Move console_struct to x0
// x1 already the character
bl console_print_char
add x14, x14, 1 // Move to next character in string
b -6 // Repeat

// Get return address
ldr lr, sp
add sp, sp, 8

br lr // Return




