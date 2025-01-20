
// Fill screen function
// Arguments:
// x0 - fb struct address
// x1 - color (32 bit)
// Uses:
// 
label fill_screen

ldr_unsigned w2, x0, 0 // Load fb base address
ldr_unsigned w3, x0, 4 // Load fb size

cmp x3, 0
b.eq 5 // If fb size left is zero, exit
str w1, x2
add x2, x2, 4 // Move to the next pixel
sub x3, x3, 4 // Decrement bytesize left
b -5 // Repeat

br lr