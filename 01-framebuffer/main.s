set_pc 0x80000

load_end "mailbox.s"
load_end "framebuffer.s"
load_end "fill_color.s"


label SP_POINTER, 0x80000

b main // Skip data definitions

align 8
label FILL_COLOR
bytes 8, 0xbbe7f7 // Blue-ish color (the color's hex is reversed)

align 8
label FB_STRUCT
zeros 12


align 4

label main

adr x0, SP_POINTER
mov_sp sp, x0

adr x0, FB_STRUCT
bl fb_init


adr x0, FB_STRUCT // Load the address of the fb struct into x0 as an argument

ldr_unsigned w1, x0, 0 // Load the framebuffer base into x1
ldr_unsigned w2, x0, 4 // Load the framebuffer size into x2

ldr x3, FILL_COLOR // Load the filling color into x3


label fill_loop // Loop for filling in the screen

str w3, x1 // Write the current pixel
add x1, x1, 4 // Move to the next pixel
sub x2, x2, 4 // Decrement the buffer size left

cmp x2, 0 // Compare the buffer size left to zero
b.eq 2 // If zero, exit the loop

b fill_loop // Repeat


b 0 // Hang at the end
