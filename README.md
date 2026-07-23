# HamlapOS
w.i.p. operating system

### Build
1. Build the Docker image
```sh
docker build --platform linux/arm64 -t hamlap-os .
```
2. Extract artifacts
```sh
docker create --name extract hamlap-os
docker cp extract:/root/linux/arch/arm64/boot/Image ./Image
docker cp extract:/root/linux/initramfs.cpio.gz ./initramfs.cpio.gz
docker rm extract
```
3. Run os as a vm in qemu
```sh
qemu-system-aarch64 -M virt -cpu host -accel hvf \
  -kernel ./Image \
  -initrd ./initramfs.cpio.gz \
  -append "console=ttyAMA0" \
  -nographic
```
