# ch32v-cmake

CMake modules for WCH's CH32V series of 32-bit RISC-V microcontrollers.

Supported families:

- ch32v00x
- ch32v20x
- ch32v30x


## Toolchain

Instructions on how to setup the supported toolchains


### MounRiverStudio Toolchain (Linux x86_64)

We recommend using the (kinda outdated) RISC-V toolchain from [MounRiver Studio](http://www.mounriver.com/download), because it includes some important patches (my plan is to provide a custom crosstool-ng toolchain in future).

To install it, go to http://www.mounriver.com/download, select Linux and Download the toolchain file in "Toolchain&Debugger" section. File name should be something like `MRS_Toolchain_Linux_X64_V170.tar.xz`.

Extract is somewhere in your disk, and add export the `MRS_TOOLCHAIN_PATH` variable pointing to the extracted directory. Example below assumes `bash` console:

```console
$ cd /some/folder
$ mkdir ch32v
$ cd ch32v
$ # download toolchain from http://www.mounriver.com/download and save in this folder
$ tar --strip-components=1 -xvf MRS_Toolchain_Linux_*.tar.xz
$ rm MRS_Toolchain_Linux_*.tar.xz
$ echo "export MRS_TOOLCHAIN_PATH=\"$(pwd)\"" >> ~/.bashrc
$ source ~/.bashrc
```

There is a `beforeinstall` folder inside the toolchain folder, that contains some udev rules for the WCH-Link and other tools, you probably want to copy them to `/etc/udev/rules.d` and reload udev with:

```console
# cp beforeinstall/*.rules /etc/udev/rules.d/
# udevadm control --reload-rules
```


## Program

There is a `program` rule that can be used to program the microcontrollers using [WCH-Link](http://www.wch-ic.com/products/WCH-Link.html) and the patched `openocd` binary from [MounRiver Studio](http://www.mounriver.com/download) toolchain.


## Warning

Due to licensing concerns, we are not using the latest version of the WCH peripheral libraries, because they were recently moved to a custom license that imposes some new restrictions. We use a slightly older version that was released under an `Apache-2.0` license.
