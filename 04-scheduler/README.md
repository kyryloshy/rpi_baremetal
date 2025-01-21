# 04 Scheduler

This project builds on [03 System Timer]() to program more complex events on interrupts. The idea of a scheduler is to create a semi-parallel environment where multiple tasks can be run on a single core. This type of parallelism can be achieved through timer interrupts and a scheduler, which manages all tasks.

In more detail, [main.s] does the following:
1. Drops to EL1 and sets up the correct exception vector
1. Using the programmed-in scheduler logic, it creates three separate tasks using *add_task*
2. Calls *scheduler_call* to start the scheduling logic
3. Now the CPU is in hands of the scheduler

The *scheduler_call* function does the following:
1. Preserves all register contents and run status in memory
2. Detects the current task running
3. Switches to the next task to run (if no task was running, the scheduler chooses the first one)
4. Sets up a timer to interrupt the task in a configurable amount of time
5. Loads the task's run status, drops to EL0, and hands the CPU to the new task

In the exception vector, the IRQ handler simply calls the *scheduler_call* function to repeat the process

In addition, [memory_manager.s]() was added for easier management of memory. This file adds two important things:
1. *mem_alloc* - Used to request memory
2. *mem_free* - Used to free the allocated memory

The memory manager follows a more unconvential structure compared to usual managers, such as on Linux, where [memory is paged](https://en.wikipedia.org/wiki/Memory_paging), and instead stores reserved regions of memory in a single linked list.

# Result

After running the program on a physical Raspberry Pi, or with QEMU:
```
qemu-system-aarch64 -M raspi3b -cpu cortex-a53 -monitor stdio -kernel kernel8.img
```
The final output on the screen should be three different tasks constalty printing strings with the ID of the task.

# Sources

This program contains the same hardware knowledge as [03 System Timer](), and is simply more system design and engineering, so no new info sources are necessary.
