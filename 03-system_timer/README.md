# 03 System Timer

This project showcases ARM's exception levels, interrupts, and the system timer on the Raspberry Pi. 

In detail, this program does the following:
1. Drop from EL2 to EL1, since EL2 can't receive interrupt requests
2. Enable general interrupt requests (using the DAIF register), and the system timer 1 interrupt (using the Broadcom peripherals)
3. Set up the EL1 exception vector to basically tell the processor which instructions to run on which exception
4. Start the system timer with a delay of 1 second
5. Wait in a hanging loop until the timer interrupt the execution

When the system timer causes an interrupt request, the following occurs:
1. Using the exception vector set up previously, the CPU jumps to an IRQ handler
2. The IRQ handler classifies which interrupt has occurred (e.g., a system timer 1 interrupt), and routes the program flow to an interrupt-specific handler
3. The timer 1 interrupt handler sets up the system timer to fire in 1 second, and returns the execution to the code before the exception using the 'eret' instruction.

# Result

After running the program on a physical Raspberry Pi, or with QEMU:
```
qemu-system-aarch64 -M raspi3b -cpu cortex-a53 -monitor stdio -kernel kernel8.img
```
The final output will be a message that gets printed every second in an infinite loop.

# Sources

To learn this info and write the code, the following sources were used:
 - Exception levels and exceptions - [ARM Architecture Reference Manual (section D1)](https://developer.arm.com/documentation/ddi0487/ka)
 - System registers - [ARM Architecture Reference Manual (section D23.2)](https://developer.arm.com/documentation/ddi0487/ka)
 - Raspberry Pi interrupts - [BCM2835 Datasheet (section 7)](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf)
 - Raspberry Pi system timer - [BCM2835 Datasheet (section 12)](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf)
