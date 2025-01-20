load_end "framebuffer.s"
load_end "console.s"
load_end "screen.s"
load_end "return.s"

label SP_POINTER, 0x80000

align 8
label fb_struct
zeros 12 // Reserve space for the fb struct

align 8
label console_struct
zeros 40

align 8
label string_space
zeros 50

align 8
label newline_char
ascii "\n\0"

align 8
label COLOR_WHITE
bytes 8, 0xFFFFFFFF

align 4
label init_env

adr x0, SP_POINTER // Load the stack pointer address into x0
mov_sp sp, x0 // Move the stack pointer into sp

str_pre_index lr, sp, -8

// Initialize the framebuffer
adr x0, fb_struct // Load the fb_struct address into x0
bl fb_init // Call fb init

// Fill the screen with white
adr x0, fb_struct
adr x1, COLOR_WHITE
ldr x1, x1
bl fill_screen

// Initialize the console
adr x0, console_struct
adr x1, fb_struct
mov x2, 10
mov x3, 10
mov x4, 1900
mov x5, 1060

bl console_init


ldr_post_index lr, sp, 8
br lr
