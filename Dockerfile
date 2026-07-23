FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    build-essential bc bison flex libssl-dev libelf-dev \
    git cpio rsync python3

# --- Kernel ---
RUN git clone --depth 1 https://github.com/torvalds/linux.git /root/linux
COPY configs/kernel.config /root/linux/.config
WORKDIR /root/linux
RUN make ARCH=arm64 olddefconfig && make ARCH=arm64 -j$(nproc)

# --- BusyBox ---
RUN git clone --depth 1 https://git.busybox.net/busybox /root/busybox
COPY configs/busybox.config /root/busybox/.config
WORKDIR /root/busybox
RUN yes "" | make ARCH=arm64 oldconfig \
    && make ARCH=arm64 -j$(nproc) \
    && make ARCH=arm64 CONFIG_PREFIX=/root/linux/_install install

# --- Root filesystem overlay ---
COPY rootfs-overlay/ /root/linux/_install/
RUN mkdir -p /root/linux/_install/proc /root/linux/_install/sys /root/linux/_install/dev \
    && ln -sf bin/busybox /root/linux/_install/init \
    && chmod +x /root/linux/_install/etc/init.d/rcS

WORKDIR /root/linux
RUN cd _install && find . | cpio -o -H newc | gzip > /root/linux/initramfs.cpio.gz
