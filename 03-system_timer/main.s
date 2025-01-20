set_pc 0x80000

load_end "interrupts.s"
load_end "system_timer.s"
load_end "env.s"
load_end "num_to_str.s"

b main // Skip data definitions


label start_timer_msg
ascii "Starting timer 1\n\n\0"

align 4
label main

// First thing to do: Drop to EL1h from EL2

mov x0, 5
msr SPSR_EL2, x0 // Indicate the drop to EL1h

adr x0, el1_kernel_entry_point
msr ELR_EL2, x0 // Indicate the return address (where EL1h will start execution)

mrs x0, HCR_EL2
mov x1, 1
lsl x1, x1, 31
orr x0, x0, x1
msr HCR_EL2, x0 // Set Hypervisor Configuration Register (HCR) RW bit to 1 (means that EL1's execution state will be Aarch64)

mov x0, 0
msr SCTLR_EL1, x0 // Indicate that the MMU is disabled in the EL1 System Control Register (SCTLR)

eret

label el1_kernel_entry_point

// Initialize the environment
bl init_env

// Setup the vector table for EL1, which will bind a special event for an IRQ.
bl init_el1_vector_table

// Enable system timer 1 interrupts
bl enable_system_timer_1

// Enable IRQs
bl enable_irq

// Start the timer
bl start_timer_1

b 0
