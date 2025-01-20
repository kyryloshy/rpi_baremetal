set_pc 0x80000

load_end "framebuffer.s"
load_end "console.s"

label SP_POINTER, 0x80000

b main // Skip the data definitions

label white_color
bytes 4, 0xFFFFFF

label fb_struct
zeros 12 // Reserve space for the fb struct

align 8
label console_struct
zeros 40

align 4
label test_string
ascii "This is a test string.\n\nTwo newlines were printed!"
bytes 1, 0 // Null terminate

align 4

label main


adr x0, SP_POINTER // Load the stack pointer address into x0
mov_sp sp, x0 // Move the stack pointer into sp

adr x0, fb_struct // Load the fb_struct address into x0
bl fb_init // Call fb init


// Initialize the console

adr x0, console_struct
adr x1, fb_struct
mov x2, 10
mov x3, 10
mov x4, 1900
mov x5, 1060

bl console_init


// Fill the screen in with white

adr x0, fb_struct
ldr_unsigned w1, x0, 0 // Load the fb base address
ldr_unsigned w2, x0, 4 // Load the fb size

ldr w3, white_color

// Fill loop
str w3, x1
add x1, x1, 4
sub x2, x2, 4
cmp x2, 0
b.eq 2
b -5


// Print the test string
adr x0, console_struct
adr x1, test_string
bl console_print_string


b 0 // Hang
