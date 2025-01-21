load_end "framebuffer.s"
load_end "console.s"
load_end "screen.s"
load_end "return.s"
load_end "memory_manager.s"
load_end "el2_vector_table.s"

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
label setup_env

// 0b101 for EL1h
mov x0, 5
msr SPSR_EL2, x0

// The 'return' address after switching to EL1
adr x0, setup_env_el1_entry_point
msr ELR_EL2, x0

// PSTATE.RW set (Execution state for EL1 is AArch64)
mov x0, 1
lsl x0, x0, 31

msr HCR_EL2, x0

// MMU disabled
mov x0, 0
msr SCTLR_EL1, x0

eret

label setup_env_el1_entry_point

// Now in EL1h

adr x0, SP_POINTER // Load the stack pointer address into x0
mov_sp sp, x0 // Move the stack pointer into sp

str_pre_index lr, sp, -8

// Initialize the framebuffer
adr x0, fb_struct // Load the fb_struct address into x0
bl fb_init // Call fb init

// Fill the screen with white
adr x0, fb_struct
ldr x1, COLOR_WHITE
bl fill_screen

// Initialize the console
adr x0, console_struct
adr x1, fb_struct
mov x2, 10
mov x3, 10
mov x4, 1900
mov x5, 1060

bl console_init


b return
