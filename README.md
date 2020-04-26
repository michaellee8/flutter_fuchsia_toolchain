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
