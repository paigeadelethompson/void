# syntax=docker/dockerfile:1

# First stage - Download and extract rootfs
FROM --platform=$BUILDPLATFORM alpine:latest AS download
RUN apk add --no-cache curl xz gnupg

# Download SHA256 sums
RUN curl -sSL https://repo-default.voidlinux.org/live/current/sha256sum.txt -o /sha256sum.txt

# Set up variables for architecture, libc, variant, and datestamp
ARG TARGETARCH
ARG TARGETVARIANT
ARG LIBC=glibc
ARG VARIANT=standard
ARG DATESTAMP=20250202

# Download and verify rootfs based on architecture, libc, and variant
RUN mkdir -p /rootfs && \
    if [ "$TARGETARCH" = "amd64" ] && [ "$LIBC" = "glibc" ]; then \
        FILE="void-x86_64-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "amd64" ] && [ "$LIBC" = "musl" ]; then \
        FILE="void-x86_64-musl-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "386" ] && [ "$LIBC" = "glibc" ]; then \
        FILE="void-i686-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm64" ] && [ "$LIBC" = "glibc" ] && [ "$VARIANT" = "standard" ]; then \
        FILE="void-aarch64-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm64" ] && [ "$LIBC" = "musl" ] && [ "$VARIANT" = "standard" ]; then \
        FILE="void-aarch64-musl-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm64" ] && [ "$LIBC" = "glibc" ] && [ "$VARIANT" = "rpi" ]; then \
        FILE="void-rpi-aarch64-PLATFORMFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm64" ] && [ "$LIBC" = "musl" ] && [ "$VARIANT" = "rpi" ]; then \
        FILE="void-rpi-aarch64-musl-PLATFORMFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ] && [ "$LIBC" = "glibc" ] && [ "$VARIANT" = "standard" ]; then \
        FILE="void-armv7l-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ] && [ "$LIBC" = "musl" ] && [ "$VARIANT" = "standard" ]; then \
        FILE="void-armv7l-musl-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ] && [ "$LIBC" = "glibc" ] && [ "$VARIANT" = "rpi" ]; then \
        FILE="void-rpi-armv7l-PLATFORMFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ] && [ "$LIBC" = "musl" ] && [ "$VARIANT" = "rpi" ]; then \
        FILE="void-rpi-armv7l-musl-PLATFORMFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v6" ] && [ "$LIBC" = "glibc" ] && [ "$VARIANT" = "standard" ]; then \
        FILE="void-armv6l-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v6" ] && [ "$LIBC" = "musl" ] && [ "$VARIANT" = "standard" ]; then \
        FILE="void-armv6l-musl-ROOTFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v6" ] && [ "$LIBC" = "glibc" ] && [ "$VARIANT" = "rpi" ]; then \
        FILE="void-rpi-armv6l-PLATFORMFS-${DATESTAMP}.tar.xz"; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v6" ] && [ "$LIBC" = "musl" ] && [ "$VARIANT" = "rpi" ]; then \
        FILE="void-rpi-armv6l-musl-PLATFORMFS-${DATESTAMP}.tar.xz"; \
    else \
        echo "Unsupported architecture, libc, or variant combination"; \
        exit 1; \
    fi && \
    echo "Selected file: $FILE" && \
    PATTERN=$(echo "$FILE" | sed 's/(/\\(/g; s/)/\\)/g') && \
    CHECKSUM=$(grep -E "SHA256.*$PATTERN" /sha256sum.txt | awk -F'= ' '{print $2}') && \
    if [ -z "$CHECKSUM" ]; then \
        echo "Checksum not found for $FILE"; \
        cat /sha256sum.txt | grep "$FILE"; \
        exit 1; \
    fi && \
    echo "Downloading $FILE with checksum $CHECKSUM" && \
    curl -sSL "https://repo-default.voidlinux.org/live/current/$FILE" -o /$FILE && \
    echo "$CHECKSUM  /$FILE" | sha256sum -c - && \
    tar -xJp -C /rootfs -f /$FILE && \
    rm -f /*.tar.xz

# Second stage - Build the final image
FROM scratch
ARG LIBC=glibc
ARG VARIANT=standard
ARG TARGETARCH
ARG TARGETVARIANT=""
ARG DATESTAMP=20250202
LABEL org.opencontainers.image.description="Void Linux ${LIBC} ${VARIANT} ${TARGETARCH}${TARGETVARIANT} ${DATESTAMP}"

COPY --from=download /rootfs/ /

# Configure system
RUN mkdir -p /etc/xbps.d && \
    echo "noextract=/etc/passwd" > /etc/xbps.d/passwd.conf && \
    echo "noextract=/etc/hosts" > /etc/xbps.d/hosts.conf

# Enable nonfree repository based on architecture
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        echo "repository=https://repo-default.voidlinux.org/current/nonfree/x86_64" > /etc/xbps.d/nonfree.conf; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        echo "repository=https://repo-default.voidlinux.org/current/nonfree/aarch64" > /etc/xbps.d/nonfree.conf; \
    elif [ "$(uname -m)" = "armv7l" ]; then \
        echo "repository=https://repo-default.voidlinux.org/current/nonfree/armv7l" > /etc/xbps.d/nonfree.conf; \
    elif [ "$(uname -m)" = "armv6l" ]; then \
        echo "repository=https://repo-default.voidlinux.org/current/nonfree/armv6l" > /etc/xbps.d/nonfree.conf; \
    elif [ "$(uname -m)" = "i686" ]; then \
        echo "repository=https://repo-default.voidlinux.org/current/nonfree/i686" > /etc/xbps.d/nonfree.conf; \
    fi

# Create ignore.conf file
RUN mkdir -p /etc/xbps.d && \
    echo "ignorepkg=linux" > /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=grub" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=efibootmgr" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware-amd" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware-broadcom" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware-dvb" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware-intel" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware-network" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware-nvidia" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=linux-firmware-qualcomm" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=wifi-firmware" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=wpa_supplicant" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=zd1211-firmware" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=void-artwork" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=u-boot-tools" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=uboot-mkimage" >> /etc/xbps.d/ignore.conf && \
    echo "ignorepkg=dracut" >> /etc/xbps.d/ignore.conf

# Update and clean
RUN xbps-install -Suy && \
    rm -rf /var/cache/xbps/*

CMD ["/bin/sh"]
