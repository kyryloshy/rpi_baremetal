load_end "interrupts.s"

align 4
label SYSTEM_TIMER_1_INTERVAL
bytes 4, 1000000

label SYSTEM_TIMER_CS
bytes 4, 0x3f003000

label SYSTEM_TIMER_CLO
bytes 4, 0x3f003004
label SYSTEM_TIMER_CHI
bytes 4, 0x3f003008

label SYSTEM_TIMER_C1
bytes 4, 0x3f003010
label SYSTEM_TIMER_C3
bytes 4, 0x3f003018

// Init system timer function
// Enables the system timer 1 interrupt
label enable_system_timer_1

mov x0, 0
ldr w0, IC_ENABLE_IRQS_1 // Load the register address

ldr w1, IC_IRQ_SYSTEM_TIMER_1_MATCH // Load the timer 1 encoding

str w1, x0

br lr



// Setup timer 1 cmp value function
// Sets up the system timer 1 in a way so that it fires after SYSTEM_TIMER_1_INTERVAL ticks have passed
label start_timer_1

ldr w2, SYSTEM_TIMER_1_INTERVAL // Load the interval amount

mov x0, 0
ldr w0, SYSTEM_TIMER_CLO // Load the clock register address
ldr w1, x0 // Load the value in the clock register

add w1, w1, w2 // Add the interval to the current clock value

ldr w0, SYSTEM_TIMER_C1 // Load the timer 1 compare register address
str w1, x0 // Write the comparison value to the register

br lr // Return






