# Flutter SDK setup for developing with Fuchsia SDK

This project aims to provide guidance to developing Flutter applications for
Fuchsia using the Fuchsia GN C++ SDK. It does not require downloading and 
building Fuchsia locally, which is enromusly big.

Disclaimer: This project have no relation with Google. This is unofficial. 
Use this at your own risk!

Those scripts are tested to work in Ubuntu 18.04 LTS.

## Command usage
```
usage: flutterfx

    bootstrap: init submodule and download required artifacts
    update: update this repo and submodules
    fuchsia <fserve|fpave|fserve-remote|fdevtools|fssh|fcp|femu|fpublish|fconfig|femu-exec-wrapper>: run <command> in the fuchsia sdk
    flutter <command>: run <command> in the flutter sdk
    readme: show the readme file
    help: display this message
```

## Setting up
```sh
git clone https://github.com/michaellee8/flutter_fuchsia_toolchain.git --recursive
# Assumes you have added ./bin to your path, if you haven't, use ./bin/flutterfx instead of flutterfx
flutterfx bootstrap
sudo ip tuntap add dev qemu mode tap user $USER && sudo ip link set qemu up
flutterfx fuchsia femu -N --image workstation.qemu-x64-release
flutterfx fuchsia fserve --image workstation.qemu-x64-release
cd flutter_gallery # See Note 4
export FUCHSIA_SSH_CONFIG=$HOME/.fuchsia/sshconfig # See Note 2
flutterfx flutter run -d <flutter device name from flutterfx flutter devices>
```

## So how do I actually run my Flutter app in Fuchsia

Okay, I know why you are here. There are a lot of quirks here. `flutter run` after applying my 
patch still breaks because of some `rust tuf` I/O error (you can see it with log_listener). Also 
for some reason it is not possible to launch a package via tiles_Ctl or sessionctl on the emulator 
and the ermine (the desktop environment you see in the workstation flavour) will not load any 
package name that is not present in the original package repo. So my hack is to force updating 
the `flutter_gallery` package and then launch it from ermine. You can do further work by changing my 
`flutter_gallery` checkout. 

The command below assumes that you start from scratch, on a Linux environment (I use Ubuntu 18.04 LTS). 
You are advised to follow it strictly. You may want to mess around yourself later through but this 
is the only way that is verified to work. Prepare a great internet connection or wait for hours.

Note that (term1) (term2) (term3) ... means different terminal. You will need a few of them.

**Currently this is not working yet. The package loads but some kernel error still exists. Still 
investigating.**

```sh
cd ~
git clone https://github.com/michaellee8/flutter_fuchsia_toolchain.git --recursive
git clone https://github.com/michaellee8/flutter_gallery.git
# install ~/flutter_fuchsia_toolchain/bin and 
# ~/flutter_fuchsia_toolchain/depot_tools to your path
flutterfx bootstrap
sudo ip tuntap add dev qemu mode tap user $USER && sudo ip link set qemu up
(term1) cd flutter_gallery
(term1) flutterfx flutter pub get
(term1) flutterfx flutter build fuchsia --release --runner-source flutter_tool \
  --tree-shake-icons  --verbose --target-platform fuchsia-x64 
# if you face Error while initializing the Dart VM: Wrong full snapshot version, expected
# you will need to do
# flutterfx flutter clean
# cd ~/flutter_fuchsia_toolchain/flutter/bin
# rm -rf ./cache
(term2) flutterfx fuchsia femu -N --image workstation.qemu-x64-release
(term1) flutterfx fuchsia fpublish ~/flutter_gallery/build/fuchsia/pkg/flutter_gallery-0.far
(term3) flutterfx fuchsia fserve --image workstation.qemu-x64-release
(term1) flutterfx fuchsia fpublish ~/flutter_gallery/build/fuchsia/pkg/flutter_gallery-0.far
(term4) flutterfx fuchsia fssh log_listener
(term1) pkgctl resolve fuchsia-pkg://fuchsia.com/flutter_gallery
# in the ermine ui shell, type flutter_gallery and then press enter to launch it
```


## Some notes
1. You may want to add `./flutter_fuchsia_toolchain/bin` to your PATH.
2. You will need `export FUCHSIA_SSH_CONFIG=$HOME/.fuchsia/sshconfig` to setup flutter's connection to the device.
3. Use `--verbose` for debugging.
4. You may want to look at my flutter gallery fork at https://github.com/michaellee8/flutter_gallery to look for 
fuchsia specific config.

## Known issues
1. Somehow the guest will not launch the installed packages currently, will be 
investigated. Currently a patch at https://github.com/flutter/flutter/pull/55664 adresses the ipv6 
issue, but some other bugs are being investigated.

## Emulator flavours
You should look at the values listed in here (or newer directories): 
https://console.cloud.google.com/storage/browser/fuchsia/development/0.20200424.3.1/packages/?authuser=0  

- qemu-arm64
- qemu-x64
- workstation.qemu-x64-release (you probably want to use this default)

## Where are the files?
- This folder
- ~/.fuchsia

## Configuration
`config-common.sh`
- `USE_MODIFIED_FLUTTER`: If this is not set to empty, flutterfx will use dart toolchain to run all flutter commands 
which runs flutter from source. If it is empty, flutterfx will use the flutter command directly, which uses the faster snapshot 
method instead. It should be set to non-empty if you want to run a modified flutter toolchain.

## Quick commands
```sh
git clone https://github.com/michaellee8/flutter_fuchsia_toolchain.git --recursive
sudo ip tuntap add dev qemu mode tap user $USER && sudo ip link set qemu up
ifconfig qemu | grep inet6
flutterfx fuchsia femu -N --image workstation.qemu-x64-release
flutterfx fuchsia fserve --image workstation.qemu-x64-release
flutterfx fuchsia fpublish ~/gallery/build/fuchsia/pkg/gallery-0.far # if you are playing with flutter gallery
flutterfx flutter build fuchsia --release --verbose --runner-source fuchsia.com --tree-shake-icons
flutterfx flutter run -d <flutter device name from flutterfx flutter devices>
flutterfx fuchsia fssh log_listener --clock Local
```
