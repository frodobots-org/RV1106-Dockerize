# RV1106-Dockerize
Script for compiling RV1106 firmware.
## 1. How to build the firmware of RV1106.
  - 1.1 Build Docker Image
    ```
    make build
    ```
  - 1.2 Download Source Code & Prepare
    ```
    make check-repo && make prepare
    make prepare //need to run make prepare two times, cause it would get error on first time to build aws-iot.
    ```
  - 1.3 Build Firmware in Docker Container
    ```
    make compile-mini // make compile-miniplus
    ```
##2. How to Build Firmware Independently
  - 2.1 Enter Docker Container
    ```
      make run
    ```
 - 2.2 Choose Build Configuration
     ```
     ./build.sh lunch //please choose 9 here.
     ```
 - 2.3 Build U-Boot
     ```
     ./build.sh uboot
     ```
 - 2.4 Build Kernel
     ```
     ./build.sh kernel
     ```
- 2.5 Build Sysdrv
     ```
     ./build.sh sysdrv
     ```
 - 2.6 Build Frodobots App
     ```
     ./build.sh frodo mini //build mini app
     ./build.sh frodo miniplus //build miniplus app
     ```
 - 2.7 Build Firmware
     ```
     ./build.sh all mini //build mini firmware
     ./build.sh all miniplus //build miniplus firmware
     ```
 - 2.8 Clean Project
     ```
     ./build.sh all clean
     ```

