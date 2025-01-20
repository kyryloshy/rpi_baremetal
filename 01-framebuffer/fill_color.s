// Arguments:
// x0 - fb struct address
// x1 - color (32 bits)
label fill_color_32_bits

// Load current framebuffer pixel address into x2
ldr w2, x0
// Load framebuffer size into x3
add x3, x0, 4 // Increment fb struct address by 4 bytes
ldr w3, x3 // Load the offset-ed address

// x2 - current framebuffer pixel address
// x3 - framebuffer bytes left

label fill_color_32_bits_loop
str w1, x2 // Write the color to the current framebuffer pixel

add x2, x2, 4 // Go to the next pixel
sub x3, x3, 4 // Remove 4 from the left bytes

cmp x3, 0
b.eq 2 // Break if bytes left zero

b fill_color_32_bits_loop // Repeat

br x30 // Return




// Arguments:
// x0 - fb struct address
// x1 - color (64 bits)
label fill_color_64_bits

// Load current framebuffer pixel address into x2
ldr w2, x0
// Load framebuffer size into x3
add x3, x0, 4 // Increment fb struct address by 4 bytes
ldr w3, x3 // Load the offset-ed address

// x2 - current framebuffer pixel address
// x3 - framebuffer bytes left

label fill_color_64_bits_loop
str x1, x2 // Write the color to the current framebuffer pixel

add x2, x2, 8 // Go to the next pixel
sub x3, x3, 8 // Remove 4 from the left bytes

cmp x3, 0
b.eq 2 // Break if bytes left zero

b fill_color_64_bits_loop // Repeat

br x30 // Return