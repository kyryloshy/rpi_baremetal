align 2048 // Alignment required by the ARM architecture
label EL1_VECTOR_TABLE

// Table columns:
// Synchronous, IRQ, FIQ, SError

// Taken from current level with SP_EL0
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler

// Taken from current level with SP_ELx, x > 0
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
b el1_irq_handler
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler

// Taken from lower exception level using Aarch64
align 0x80
b el1_el0_synchronous_handler
align 0x80
b el1_el0_irq_handler
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler

// Taken from lower exception level using Aarch32
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler
align 0x80
adr x24, 0
b default_exception_handler


align 4
label default_exception_handler

// Just hang on the
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



align 4

label el1_irq_handler

b scheduler_interrupt_handler





label el1_el0_irq_handler
// Mostly used for the timer interrupt that changes the task

b scheduler_interrupt_handler



label el1_el0_synchronous_handler

b scheduler_synchronous_handler


