set_pc 0x80000

load_end "setup.s"
load_end "scheduler.s"
load_end "num_to_str.s"
load_end "count.s"

b main

align 8
label WAIT_AMOUNT
bytes 8, 1000000

align 4
label main

bl setup_env

bl init_el1_vector_table
bl enable_irq
bl enable_system_timer_1

adr x0, task1
bl add_task

adr x0, task2
bl add_task

adr x0, task3
bl add_task


// Call the scheduler to start the scheduling process
bl scheduler_call

b 0

label task1_str
ascii "Task 1\n\0"
align 4


label task1

label task1_loop
adr x0, console_struct
adr x1, task1_str
bl console_print_string // Print the string

ldr x0, WAIT_AMOUNT
bl count // Count for some time

b task1_loop // Repeat



label task2_str
ascii "Task 2\n\0"
align 4

label task2

label task2_loop

adr x0, console_struct
adr x1, task2_str
bl console_print_string // Print the string

ldr x0, WAIT_AMOUNT
bl count // Count for some time

b task2_loop // Repeat



label task3_str
ascii "Task 3\n\0"
align 4

label task3

label task3_loop
adr x0, console_struct
adr x1, task3_str
bl console_print_string // Print the string

ldr x0, WAIT_AMOUNT
bl count // Count for some time

b task3_loop // Repeat
