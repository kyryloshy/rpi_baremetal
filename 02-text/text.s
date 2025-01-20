align 4 // Align the function by 4 bytes

align 4
label CHAR_COLOR
bytes 4, 0x000000 // Black

// Draw character function
// Arguments:
// x0 - fb struct
// x1 - character to draw (ascii encoding, 255 maximum value)
// x2 - x pos
// x3 - y pos
// Uses:
// x0 - x11
label draw_char

//
// First step: load fb base address into x4, fb pitch into x5
//

ldr w4, x0 // Load the fb address

add x0, x0, 8 // Move to third element of fb struct

ldr w5, x0 // Load the fb pitch


//
// Second step: set x1 to the character's glyph address
//

adr x6, FONT_BITMAP // Get the address of the bitmap into x6
// Make x1 equal to x1 * 8 through x8 = 8, x1 = x1 * x8

mov x7, 8
mul x1, x1, x7

add x6, x6, x1 // Offset the font bitmap address by the character (ascii encoding) * 8 (bytes per character)

mov x1, x6

// x1 now contains the address for the right glyph

//
// Third step: offset the fb base address to the starting pixel address
//

// Offset by y * pitch (vertical offset)
// Calculate the offset in x7: x5 (fb pitch) * x3 (y pos)
mul x7, x5, x3
// Add to fb base address
add x4, x4, x7

// Offset by x * 4 (bytes per pixel)
// Calculate offset in x7: x2 * 4
mov x7, 4 // x7 = 4
mul x7, x2, x7 // x7 = x2 * x7  (x2 * 4)
add x4, x4, x7 // Add to fb base address

// Registers:
// x1 - character glyph address
// x2 - start x pos
// x3 - start y pos
// x4 - current pixel
// x5 - fb pitch
// x6 - x left
// x7 - y left
// x8 - glyph content
// x9 - glyph bit mask
// x10 - current glyph bit
// x11 - pixel color

mov x6, 8 // 8 x-axis movements left
mov x7, 8 // 8 y-axis movements left

ldr x8, x1 // Load the 64-bit glyph
mov x9, 1 // Bit mask of just 0b1 for now

adr x11, CHAR_COLOR // Load the color
ldr w11, x11

//
// Fourth step: draw the character in a loop
//

label draw_char_y_loop

label draw_char_x_loop

mov x10, x8 // Copy glyph content from x8
and x10, x10, x9 // Mask only the needed pixel bit
cmp x10, 0 // Compare to zero (zero means don't draw)
b.eq draw_char_after_pixel_draw // Skip the drawing part if pixel bit = 0

// Here if drawing the pixel
str w11, x4 // Write the pixel color to the pixel location

label draw_char_after_pixel_draw

// Actions: move to next pixel, decrement x-movements left, move mask to next bit

add x4, x4, 4 // Add 4 bytes to move to the next pixel
sub x6, x6, 1 // Subtract x-movements left
lsl x9, x9, 1 // Move the mask one bit to the left

// Check if x-movements left is zero. If yes, exit the draw_char_x loop
cmp x6, 0
b.eq 2 // If equal to zero, skip the repeat-branch
b draw_char_x_loop // Repeat-branch


// Here is the draw_char_y loop
// Actions: move to the next row, reset x-movements left

add x4, x4, x5 // Offset current pixel by fb pitch (moving to the next row)
sub x4, x4, 32 // Move to the start of the 'character square': glyph size (8) * bytes per pixel (4) = 32

mov x6, 8 // Reset x-movements left for a repeat loop

sub x7, x7, 1 // Subtract 1 from y-movements left

// Check if y-movements left is zero. If yes, exit the draw_char_y loop
cmp x7, 0
b.eq 2 // Skip repeat branch if y-movements left is zero

b draw_char_y_loop // Repeat branch


// Here after the loop

// Return
br lr




// Draw string function
// Arguments:
// x0 - fb struct
// x1 - string pointer
// x2 - string size
// x3 - start x
// x4 - start y
// Uses:
// draw_char (x0 - x11)
label draw_string

// Save return address to stack pointer
str_pre_index lr, sp, -8


mov x12, x0 // Keep a copy of fb_struct address in x12
mov x13, x1 // Keep the string location in x13
mov x14, x2 // Keep the string size in x14
mov x15, x3
mov x16, x4


label draw_string_loop

mov x0, x12 // Set x0 to fb_struct address

ldrb w1, x13 // Load the character from current char pointer

mov x2, x15 // x start
mov x3, x16 // y start

bl draw_char // Call draw_char

// After, move x coor by 8, increment string address by one (move to next character), decrement string size left

add x15, x15, 8 // Increment x coor

add x13, x13, 1 // Move to next character
sub x14, x14, 1 // Decrement string size left by one

cmp x14, 0 // Check if string size left is zero
b.eq 2 // If yes, exit the loop
b draw_string_loop // If not, repeat the loop


// Here after the loop


// Load the return address
ldr lr, sp
add sp, sp, 8

// Return
br lr


align 8
label FONT_WIDTH
bytes 8, 8
label FONT_HEIGHT
bytes 8, 8


// Embed the raw font in here
align 8
label FONT_BITMAP // mark the font start
insert_file "raw_font"

align 4
