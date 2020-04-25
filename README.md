# Flutter SDK setup for developing with Fuchsia SDK

This project aims to provide guidance to developing Flutter applications for
Fuchsia using the Fuchsia GN C++ SDK. It does not require downloading and 
building Fuchsia locally, which is enromusly big.

Disclaimer: This project have no relation with Google. This is unofficial. 
Use this at your own risk!

Those scripts are tested to work in Ubuntu 18.04 LTS.

## Some notes
1. You may want to add `./flutter_fuchsia_toolchain/bin` to your PATH.
2. You will need `export FUCHSIA_SSH_CONFIG=$HOME/.fuchsia/sshconfig` to setup flutter's connection to the device.
3. Use `--verbose` for debugging.

## Known issues
1. Somehow the guest will not launch the installed packages currently, will be 
investigated. 

## Emulator flavours
You should look at the values listed in here (or newer directories): 
https://console.cloud.google.com/storage/browser/fuchsia/development/0.20200424.3.1/packages/?authuser=0  

- qemu-arm64
- qemu-x64
- workstation.qemu-x64-release (you probably want to use this default)

## Where are the files?
- This folder
- ~/.fuchsia

## Quick commands
```sh
git clone https://github.com/michaellee8/flutter_fuchsia_toolchain.git --recursive
sudo ip tuntap add dev qemu mode tap user $USER && sudo ip link set qemu up
ifconfig qemu | grep inet6
flutterfx fuchsia femu -N --image workstation.qemu-x64-release
flutterfx fuchsia fserve --image workstation.qemu-x64-release
flutterfx fuchsia fpublish ~/gallery/build/fuchsia/pkg/gallery_0.far # if you are playing with flutter gallery
flutterfx flutter build fuchsia --release --verbose --runner-source fuchsia.com --tree-shake-icons
flutterfx flutter run -d <flutter device name from flutterfx flutter devices>
```
