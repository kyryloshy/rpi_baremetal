# Raspberry Pi Bare Metal

A collection of projects through which I learned about bare metal software, low-level programming and a lot more.

Written for the Raspberry Pi Zero 2 W using [Broadcom's BCM2835 Datasheet](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf) and the internet.

# Compiling and Running

## Requirements
All projects in this repository use [kompiler](https://github.com/kyryloshy/kompiler) for compilation, which can be installed with:
```
gem install kompiler
```

## Compiling
To compile and run one of the projects, enter the project and run make:
```shell
cd project_name; make
```
The result will be a generated kernel8.img file.

## Running
You can run the compiled binary by either running it on a physical Raspberry Pi, or with QEMU:
```
qemu-system-aarch64 -M raspi3b -cpu cortex-a53 -monitor stdio -kernel kernel8.img
```

# Learning
If you are also interested in bare metal or Raspberry Pi programming, you can refer to these projects to see how the hardware can be used. There are a lot of comments in each file that should help you orient yourself. Good luck!
