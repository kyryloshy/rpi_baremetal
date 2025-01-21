load_end "memory_manager.s"
load_end "system_timer.s"

align 8

label TASKS_LIST_ENTRY_POINT
bytes 8, 0

label CURRENT_TASK_ADDRESS
bytes 8, 0

label TASK_STACK_SIZE
bytes 8, 800

label TASK_RUN_AMOUNT
bytes 8, 10000

label EC_SUPERVISOR_CALL
bytes 8, 0b010101

// Tasks linked list node structure:
// 0 - task id (8 bytes, zero for now)
// 8 - run status address (address to task running info, like register contents and others) (8 bytes)
// 16 - next node address (8 bytes)

// Task run status structure:
// 0 - x0-x30 register contents (8 bytes each, 248 bytes total)
// 248 - stack pointer (8 bytes)
// 256 - program counter (8 bytes)
// 264 - SPSR register (8 bytes)

label TASK_RUN_STATUS_SIZE
bytes 8, 272

// Add task function
// Adds a task / process to the list for the scheduler
// Arguments:
// x0 - task entry point (address)
// Uses:
// mem_alloc:  x0 - x9
label add_task

str_pre_index lr, sp, -8

str_pre_index x0, sp, -8 // Store the input on the stack

// Allocate memory for the task struct
mov x0, 24
bl mem_alloc

str_pre_index x0, sp, -8 // Store the address on the stack

ldr x0, TASK_RUN_STATUS_SIZE
bl mem_alloc

str_pre_index x0, sp, -8 // Store the run status address on the stack

ldr x0, TASK_STACK_SIZE
bl mem_alloc



mov x6, x0 // Store task stack address in x6

ldr_post_index x2, sp, 8 // Load the run status address
ldr_post_index x0, sp, 8 // Load the allocated task node address
ldr_post_index x1, sp, 8 // Load the input argument (task entry point address)

// Fill the node with info
mov x3, 0
str_unsigned x3, x0, 0 // Task id
str_unsigned x2, x0, 8 // Run status address
// str_unsigned x3, x0, 16 // Next node address (zero, since this will be the last node)

// Fill the run status information
mov x5, 31 // 31 registers to fill with zeros
mov x4, x2 // Run status address
mov x3, 0 // Register content (zero by default and at the start)



str x3, x4 // Write the register as zero
add x4, x4, 8 // Move to the next register
sub x5, x5, 1 // Remove one register from the counter
cmp x5, 0
b.eq 2 // Exit if all registers are filled with zero
b -5 // Repat


// Write the allocated stack to the run status
str_unsigned x6, x2, 248

// Write the input entry point to the run status
str_unsigned x1, x2, 256

// Write the SPSR register contents (0 by default)
mov x1, 0
str_unsigned x1, x2, 264


// Add the node to the list of tasks
ldr x1, TASKS_LIST_ENTRY_POINT

cmp x1, 0
b.ne add_task_add_node_not_first
// Here if this is the first task to be added
mov x2, 0
str_unsigned x2, x0, 16 // Make next node be zero
adr x1, TASKS_LIST_ENTRY_POINT
str x0, x1
b add_task_add_node_end

label add_task_add_node_not_first

mov x25, 0xFFFF

// ldr_unsigned x2, x1, 16 // Load the next nodes address
// cmp x2, 0
// b.eq 3 // Exit the loop if the next nodes address doesnt exist
// mov x1, x2 // Make the next node the current one
// b -4 // Repaet
// 
// str_unsigned x0, x1, 16 // Link the new node with the last one
// ldr x2, TASKS_LIST_ENTRY_POINT // Load the previously first task
str_unsigned x1, x0, 16 // Link the previously first node with the new node
adr x2, TASKS_LIST_ENTRY_POINT
str x0, x2 // Make the new node the first one


label add_task_add_node_end


// mov x0, 0
ldr_post_index lr, sp, 8
br lr // Return




label scheduler_call_str
ascii "Scheduler call\n\n\0"
align 4


// Scheduler call
// Picks a task, sets up the system timer to interrupt in some time, and starts executing the selected task
// Arguments:
// none
// Uses:
// x0-
label scheduler_call

mov x25, 0

// adr x0, console_struct
// adr x1, scheduler_call_str
// bl console_print_string

// Load what the currently worked on task is
ldr x0, CURRENT_TASK_ADDRESS


// Find the address for the next task to run


cmp x0, 0 // If no task is currently running, select the first one. Else, select the next node of the current task
b.ne scheduler_call_if_1

// Here if no task was running
// If no task, set the current task to be the one at the start of the list
ldr x0, TASKS_LIST_ENTRY_POINT
mov x1, 1 // Indicate in x1 that the next task results from repeating the list
b scheduler_call_if_1_end

label scheduler_call_if_1

// Here if a task was running
ldr_unsigned x0, x0, 16 // Load the next nodes address
mov x1, 2 // Indicate in x1 that the next task results from taking the next node

label scheduler_call_if_1_end



// Now x0 is the next task to run

// Check that the task address is not zero

label scheduler_call_if_2_start
cmp x0, 0
b.ne scheduler_call_if_2

// Here when the next node/task to run is zero (no task)
// Using x1, look through which method the next task was taken.
// If it's the first node, meaning there aren't any tasks, just hang
// If it's the next node, jump to the start of the list

cmp x1, 1
b.eq scheduler_call_if_3_1
cmp x1, 2
b.eq scheduler_call_if_3_2

// Else here
b 0 // Hang

label scheduler_call_if_3_1
// Here if there aren't any tasks
// Action: hang, since this shouldn't happen
b 0

label scheduler_call_if_3_2
// Here if the next node is empty
// Action: move to the first node and repeat if_2

ldr x0, TASKS_LIST_ENTRY_POINT
mov x1, 1 // Indicate that the node results from the entry point
b scheduler_call_if_2_start // Repeat the if

label scheduler_call_if_3_end

b scheduler_call_if_2_end

label scheduler_call_if_2
// Here when there is a task to run


label scheduler_call_if_2_end


// Next action: set up the system timer and run the task

mov x3, x0

ldr x0, TASK_RUN_AMOUNT

bl start_timer_1


// Set the current task to the newly selected one
adr x1, CURRENT_TASK_ADDRESS
str x3, x1


// Set up task run parameters and registers

ldr_unsigned x0, x3, 8 // Load the tasks run status address into x0


ldr_unsigned x1, x0, 256 // Load the PC for the task to run
msr ELR_EL1, x1 // Load it into the exception link register (to do eret later)


ldr_unsigned x1, x0, 248 // Load the stack pointer address
// msr SP_EL1, x1 // Set the EL1 SP to the SP in the tasks run status
// mov_sp sp, x1
msr SP_EL0, x1


ldr_unsigned x1, x0, 264 // Load the SPSR register value
msr SPSR_EL1, x1
// // mov x1, 5 // EL1h
// mov x1, 0 // EL0
// msr SPSR_EL1, x1



// Load all register values from the run status
mov x30, x0

ldp_signed x0, x1, x30, 0
ldp_signed x2, x3, x30, 16
ldp_signed x4, x5, x30, 32
ldp_signed x6, x7, x30, 48
ldp_signed x8, x9, x30, 64
ldp_signed x10, x11, x30, 80
ldp_signed x12, x13, x30, 96
ldp_signed x14, x15, x30, 112
ldp_signed x16, x17, x30, 128
ldp_signed x18, x19, x30, 144
ldp_signed x20, x21, x30, 160
ldp_signed x22, x23, x30, 176
ldp_signed x24, x25, x30, 192
ldp_signed x26, x27, x30, 208
ldp_signed x28, x29, x30, 224

ldr_unsigned x30, x30, 240


// 'Return' to the newly selected task
eret











// Used when an IRQ interrupt occurs while in EL0 (task EL)
label scheduler_interrupt_handler

stp_pre_index x0, x1, sp, -16 // Save the task's x0 and x1 to recover later

ldr x0, CURRENT_TASK_ADDRESS

label scheduler_interrupt_if_1_start
cmp x0, 0
b.ne scheduler_interrupt_if_1_1

// Here if no task was running
add sp, sp, 16 // Undo SP changes
b 0 // Hang

label scheduler_interrupt_if_1_1

// Here if there was a task running

ldr_unsigned x1, x0, 8 // Get the run status address into x1

// Save all register contents into the run status (starting from x2, since x0 and x1 were used for different purposes)

stp_signed x2, x3, x1, 16
stp_signed x4, x5, x1, 32
stp_signed x6, x7, x1, 48
stp_signed x8, x9, x1, 64
stp_signed x10, x11, x1, 80
stp_signed x12, x13, x1, 96
stp_signed x14, x15, x1, 112
stp_signed x16, x17, x1, 128
stp_signed x18, x19, x1, 144
stp_signed x20, x21, x1, 160
stp_signed x22, x23, x1, 176
stp_signed x24, x25, x1, 192
stp_signed x26, x27, x1, 208
stp_signed x28, x29, x1, 224
str_unsigned x30, x1, 240

// Now, recover and store x0 and x1 contents
mov x2, x1 // Move run status address to x2 since x1 is going to be used/recovered

ldp_post_index x0, x1, sp, 16 // Recover from the stack

stp_signed x0, x1, x2, 0 // Store in the run status


// Now, save the task's stack pointer, program counter, and SPSR
mrs x0, SP_EL0
str_unsigned x0, x2, 248

mrs x0, ELR_EL1
str_unsigned x0, x2, 256

mrs x0, SPSR_EL1
str_unsigned x0, x2, 264


// The task's running status is now fully saved

// Check what kind of IRQ occurred

mov x0, 0 // Clear the registers
ldr w0, IC_IRQ_PENDING_1 // Load the addresses
ldr w0, x0 // Load the interrupt statuses

ldr w1, IC_IRQ_SYSTEM_TIMER_1_MATCH // Load the checking value
and w2, w0, w1 // Isolate the needed bit
cmp w2, 0
b.ne scheduler_interrupt_timer_1

// If not the timer 1 interrupt, hang
b 0

label scheduler_interrupt_timer_1

// If interrupt 1, clear the interrupt and call the scheduler function

mov x0, 0
ldr w0, SYSTEM_TIMER_CS
ldr w1, IC_IRQ_SYSTEM_TIMER_1_MATCH

str w1, x0

ldr w0, IC_IRQ_PENDING_1
str w1, x0

b scheduler_call

b 0








// The scheduler's synchronous exception handler (taken from EL0)
// Mostly made for supervisor calls from tasks
label scheduler_synchronous_handler

// First thing: check if it's a supervisor call (save x0 and x1 in the process)
stp_pre_index x0, x1, sp, -16

mrs x0, ESR_EL1 // Load the exception status
// Isolate the EC bits
lsr x0, x0, 26
mov x1, 0b111111 // EC Mask
and x0, x0, x1 // Mask the EC

ldr x1, EC_SUPERVISOR_CALL // Load the EC for a supervisor call
cmp x0, x1
b.eq scheduler_supervisor_call

// Here if none of the defined EC values worked
b 0 // Hang






// The scheduler's supervisor call handler (called by scheduler_synchronous_handler, taken from EL0)
label scheduler_supervisor_call

// Check if a caller task actually exists

ldr x0, CURRENT_TASK_ADDRESS
cmp x0, 0
b.ne 2 // If not zero, skip the hang line
b 0 // If current task is zero, hang (this shouldn't happen)

// Task exists, save the rest of the registers, the return point, and SPSR on the stack (no need to save SP_EL0 since it remains the same, or the scheduler will save it)

ldp_post_index x0, x1, sp, 16 // Recover x0 and x1

sub sp, sp, 264 // 'Reserve' room on the stack

stp_signed x0, x1, sp, 0
stp_signed x2, x3, sp, 16
stp_signed x4, x5, sp, 32
stp_signed x6, x7, sp, 48
stp_signed x8, x9, sp, 64
stp_signed x10, x11, sp, 80
stp_signed x12, x13, sp, 96
stp_signed x14, x15, sp, 112
stp_signed x16, x17, sp, 128
stp_signed x18, x19, sp, 144
stp_signed x20, x21, sp, 160
stp_signed x22, x23, sp, 176
stp_signed x24, x25, sp, 192
stp_signed x26, x27, sp, 208
stp_signed x28, x29, sp, 224
str_unsigned x30, sp, 240

mrs x0, ELR_EL1
str_unsigned x0, sp, 248

mrs x0, SPSR_EL1
str_unsigned x0, sp, 256

mrs x0, ESR_EL1 // Store esr in x0

// Once the run context was saved, IRQs can be enabled
msr DAIFClr, 2


// Get the ESR ISS field (to get the call immediate)

mov x1, 1 // Create an ISS mask
lsl x1, x1, 25
sub x1, x1, 1

and x1, x0, x1 // Isolate the ISS bits

mov x2, 1 // Create the ISS imm16 mask
lsl x2, x2, 16
sub x2, x2, 1

and x2, x1, x2 // Isolate the immediate

// Now, x2 contains the SVC immediate

mov x0, x2



// After the SVC logic, start returning to the task
// In the process, keep x0 unchanged, since it contains the supervisor's response

// Disable interrupts
msr DAIFSet, 2

// Load the ELR_EL1 and SPSR_EL1
ldr_unsigned x1, sp, 248
msr ELR_EL1, x1

ldr_unsigned x1, sp, 256
msr SPSR_EL1, x1

// Load all the register contents
ldr_unsigned x1, sp, 8
ldp_signed x2, x3, sp, 16
ldp_signed x4, x5, sp, 32
ldp_signed x6, x7, sp, 48
ldp_signed x8, x9, sp, 64
ldp_signed x10, x11, sp, 80
ldp_signed x12, x13, sp, 96
ldp_signed x14, x15, sp, 112
ldp_signed x16, x17, sp, 128
ldp_signed x18, x19, sp, 144
ldp_signed x20, x21, sp, 160
ldp_signed x22, x23, sp, 176
ldp_signed x24, x25, sp, 192
ldp_signed x26, x27, sp, 208
ldp_signed x28, x29, sp, 224
ldr_unsigned x30, sp, 240

add sp, sp, 264 // 'Release' stack memory

// Return to the task
eret










