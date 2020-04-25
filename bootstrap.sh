sudo apt-get install curl unzip python2 \ 
libglu1-mesa bash curl git unzip xz-utils zip \
libvulkan1 mesa-vulkan-drivers

cd fuchsia-cpp-gn-sdk && ./scripts/setup-and-test.sh && cd ../

./flutter/bin/flutter precache --all-platforms --fuchsia
