align 2048
label EL1_VECTOR_TABLE

// Table columns:
// Synchronous, IRQ, FIQ, SError

// Taken from current level with SP_EL0
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler

// Taken from current level with SP_ELx, x > 0
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
b el1_irq_handler
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler

// Taken from lower exception level using Aarch64
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler

// Taken from lower exception level using Aarch32
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler
align 0x80
adr x24, 0
b default_interrupt_handler

label def_int_handler_msg
ascii "Default interrupt handler\n\n\0"

align 4
label default_interrupt_handler
// mov x0, 0
// mvn x0, x0 // Set some value
// mrs x1, ESR_EL1
// mrs x2, ELR_EL1

mrs x0, SPSel
adr x1, string_space
mov x2, 50
mov x3, 10
bl num_to_str
adr x0, console_struct
adr x1, string_space
bl console_print_string

adr x0, console_struct
adr x1, newline_char
bl console_print_string

mov x0, x24
adr x1, string_space
mov x2, 50
mov x3, 10
bl num_to_str
adr x0, console_struct
adr x1, string_space
bl console_print_string

adr x0, console_struct
adr x1, newline_char
bl console_print_string

mrs x0, vbar_el1
adr x1, string_space
mov x2, 50
mov x3, 10
bl num_to_str
adr x0, console_struct
adr x1, string_space
bl console_print_string

adr x0, console_struct
adr x1, newline_char
bl console_print_string

mrs x0, ESR_EL1
adr x1, string_space
mov x2, 50
mov x3, 10
bl num_to_str
adr x0, console_struct
adr x1, string_space
bl console_print_string

adr x0, console_struct
adr x1, newline_char
bl console_print_string

mrs x0, SPSR_EL1
adr x1, string_space
mov x2, 50
mov x3, 10
bl num_to_str
adr x0, console_struct
adr x1, string_space
bl console_print_string

adr x0, console_struct
adr x1, newline_char
bl console_print_string

mrs x0, ELR_EL1
adr x1, string_space
mov x2, 50
mov x3, 10
bl num_to_str
adr x0, console_struct
adr x1, string_space
bl console_print_string

adr x0, console_struct
adr x1, newline_char
bl console_print_string

adr x0, console_struct
adr x1, def_int_handler_msg
bl console_print_string


// eret

b 0 // Hang



align 4
// Init EL1 Vector Table function
// Writes an exception vector table to the VBAR_EL1 system register
label init_el1_vector_table

adr x0, EL1_VECTOR_TABLE
msr vbar_el1, x0

// // Create a mask for the first ten bits
// mov x1, 1
// lsl x1, x1, 10
// sub x1, x1, 1
// 
// mrs x0, VBAR_EL1
// and x0, x0, x1 // Mask the reserved part
// 
// adr x1, EL1_VECTOR_TABLE
// lsl x1, x1, 11
// orr x0, x0, x1 // Add to the vbar value
// 
// msr vbar_el1, x0

br lr // Return




// Enable IRQ function
// Enables interrupt request exceptions in the PSTATE
label enable_irq
msr DAIFClr, 0b10
br lr // Return



// Interrupt controller register addresses
label IC_IRQ_PENDING_1
bytes 4, 0x3f00B204

label IC_IRQ_PENDING_2
bytes 4, 0x3f00B208

label IC_ENABLE_IRQS_1
bytes 4, 0x3f00B210

label IC_ENABLE_IRQS_2
bytes 4, 0x3f00B214

label IC_IRQ_SYSTEM_TIMER_1_MATCH
bytes 4, 0b10

label IC_IRQ_SYSTEM_TIMER_3_MATCH
bytes 4, 0b1000


label irq_handler_str
ascii "IRQ Handler\n\n\0"

align 4

label el1_irq_handler

adr x0, console_struct
adr x1, irq_handler_str
bl console_print_string

// Load the status of each interrupt and find the one that's firing
mov x0, 0 // Clear the register
ldr w0, IC_IRQ_PENDING_1 // Load the address
ldr w0, x0 // Load the interrupt statuses

// Check if it's a timer 1 interrupt
ldr w1, IC_IRQ_SYSTEM_TIMER_1_MATCH // Load the timer 1 value
and w2, w0, w1 // Isolate the needed bit
cmp w2, 0 // Check if it's non-zero
b.eq 2 // If zero, then this interrupt hasn't fired
bl timer_1_irq_handler

// Return at the end
eret





label timer_1_interrupt_str
ascii "Timer 1 Interrupt\n\n\0"

align 4

label timer_1_irq_handler

str_pre_index lr, sp, -8

// First: Clear the interrupt
mov x0, 0
ldr w0, SYSTEM_TIMER_CS
ldr w1, IC_IRQ_SYSTEM_TIMER_1_MATCH

str w1, x0

ldr w0, IC_IRQ_PENDING_1
str w1, x0

// Print something
adr x0, console_struct
adr x1, timer_1_interrupt_str
bl console_print_string

// Re-start the timer
bl start_timer_1

mov x25, 0xF
ldr_post_index lr, sp, 8
add x25, x25, 1

br lr




