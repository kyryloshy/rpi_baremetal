# 01 Framebuffer

This project demonstrates how to request and use the framebuffer on the Raspberry Pi.

In detail, the program uses the mailbox interface to communicate with the VideoCore IV GPU, sets up needed parameters, initializes the framebuffer, and fills it in with a blue-ish color. 

# Result

After running the program on a physical Raspberry Pi, or with QEMU:
```
qemu-system-aarch64 -M raspi3b -cpu cortex-a53 -monitor stdio -kernel kernel8.img
```
The final result should be a screen filled in with a light blue color.


# Sources

To write this, the following information sources were used:
 - Peripheral addres mapping explanation - [BCM2835 Datasheet (page 6, section 1.2.3)](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf)
 - Mailbox Interface Documentation - [Raspberry Pi Wiki](https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface)
 - VideoCore IV Mailbox Address - [Linux device tree for bcm283x (line 100)](https://github.com/raspberrypi/linux/blob/rpi-6.6.y/arch/arm/boot/dts/broadcom/bcm283x.dtsi)
