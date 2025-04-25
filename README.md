# Multi-platform Void Linux Docker Image

This Dockerfile builds minimal Void Linux images for multiple architectures, libc variants, and platform types.

## Supported Architectures and Variants

### Standard ROOTFS Variants
- x86_64 (amd64) with glibc
- x86_64 (amd64) with musl
- i686 (386) with glibc
- aarch64 (arm64) with glibc
- aarch64 (arm64) with musl
- armv7l (arm/v7) with glibc
- armv7l (arm/v7) with musl
- armv6l (arm/v6) with glibc
- armv6l (arm/v6) with musl

### Raspberry Pi PLATFORMFS Variants
- aarch64 (arm64) with glibc
- aarch64 (arm64) with musl
- armv7l (arm/v7) with glibc
- armv7l (arm/v7) with musl
- armv6l (arm/v6) with glibc
- armv6l (arm/v6) with musl

## Build Arguments

The Dockerfile accepts the following build arguments:

- `LIBC`: The libc variant to use (`glibc` or `musl`). Default: `glibc`
- `VARIANT`: The platform variant to use (`standard` or `rpi`). Default: `standard`
- `DATESTAMP`: The datestamp for the Void Linux rootfs files. Default: `20250202`

## Prerequisites

To build multi-platform images, you need to install QEMU and register the required binfmt handlers:

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```

## Building the Images

### Setup Builder

Create a builder instance:

```bash
docker buildx create --name multiplatform-builder --use
```

### Command Stack for Building Locally

Build all variants locally (requires containerd image store):

```bash
# Standard glibc variants
docker buildx build --platform linux/amd64 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:x86_64-glibc --load .
docker buildx build --platform linux/386 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:i686-glibc --load .
docker buildx build --platform linux/arm64 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:aarch64-glibc --load .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:armv7l-glibc --load .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:armv6l-glibc --load .

# Standard musl variants
docker buildx build --platform linux/amd64 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:x86_64-musl --load .
docker buildx build --platform linux/arm64 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:aarch64-musl --load .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:armv7l-musl --load .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t void-linux:armv6l-musl --load .

# RPi glibc variants
docker buildx build --platform linux/arm64 --build-arg LIBC=glibc --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t void-linux:rpi-aarch64-glibc --load .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=glibc --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t void-linux:rpi-armv7l-glibc --load .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=glibc --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t void-linux:rpi-armv6l-glibc --load .

# RPi musl variants
docker buildx build --platform linux/arm64 --build-arg LIBC=musl --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t void-linux:rpi-aarch64-musl --load .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=musl --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t void-linux:rpi-armv7l-musl --load .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=musl --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t void-linux:rpi-armv6l-musl --load .
```

### Command Stack for Pushing to Registry

Build all variants and push to a registry (replace `registry/username` with your registry/username):

```bash
# Standard glibc variants
docker buildx build --platform linux/amd64 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:x86_64-glibc --push .
docker buildx build --platform linux/386 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:i686-glibc --push .
docker buildx build --platform linux/arm64 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:aarch64-glibc --push .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:armv7l-glibc --push .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:armv6l-glibc --push .

# Standard musl variants
docker buildx build --platform linux/amd64 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:x86_64-musl --push .
docker buildx build --platform linux/arm64 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:aarch64-musl --push .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:armv7l-musl --push .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:armv6l-musl --push .

# RPi glibc variants
docker buildx build --platform linux/arm64 --build-arg LIBC=glibc --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-aarch64-glibc --push .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=glibc --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-armv7l-glibc --push .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=glibc --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-armv6l-glibc --push .

# RPi musl variants
docker buildx build --platform linux/arm64 --build-arg LIBC=musl --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-aarch64-musl --push .
docker buildx build --platform linux/arm/v7 --build-arg LIBC=musl --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-armv7l-musl --push .
docker buildx build --platform linux/arm/v6 --build-arg LIBC=musl --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-armv6l-musl --push .

# Multi-architecture image groupings (optional)
docker buildx build --platform linux/amd64,linux/386,linux/arm64,linux/arm/v7,linux/arm/v6 --build-arg LIBC=glibc --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:glibc --push .
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 --build-arg LIBC=musl --build-arg VARIANT=standard --build-arg DATESTAMP=20250202 -t registry/username/void-linux:musl --push .
docker buildx build --platform linux/arm64,linux/arm/v7,linux/arm/v6 --build-arg LIBC=glibc --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-glibc --push .
docker buildx build --platform linux/arm64,linux/arm/v7,linux/arm/v6 --build-arg LIBC=musl --build-arg VARIANT=rpi --build-arg DATESTAMP=20250202 -t registry/username/void-linux:rpi-musl --push .
```

### Using a Different Datestamp

To build with a different datestamp, update the `DATESTAMP` build arg:

```bash
docker buildx build --platform linux/amd64 \
  --build-arg LIBC=glibc \
  --build-arg VARIANT=standard \
  --build-arg DATESTAMP=20250101 \
  -t void-linux:x86_64-glibc-20250101 \
  --load .
```

## Running the Images

To run the images, use:

```bash
docker run -it void-linux:x86_64-glibc
```

## Security and Verification

The build process verifies the SHA256 checksums of the downloaded Void Linux rootfs tarballs against the official checksums published by Void Linux.
