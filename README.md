# bazel-termux

A GitHub Actions experiment to build a compact, executable Bazel client for native Termux on Android/aarch64.

Target ABI: `aarch64-linux-android24` (Android bionic), **not** GNU/Linux aarch64.

## Initial source baseline

The Android `common-android14-6.1` manifest currently points at AOSP's
`platform/prebuilts/bazel/linux-x86_64` branch `main-kernel-build-2023`.
Its `bazel` symlink resolves to an x86_64 no-JDK Bazel built from upstream
commit `43445b99d9bb7b943e56cefa791f5cd9dc8a928a` (2023-07-25), adjacent to
Bazel 6.3.0. The first CI experiment uses the official `6.3.0` distribution
archive, because it contains the generated Java protobuf sources required for
bootstrap.

## Acceptance

CI uploads `bazel` only if it is an Android/aarch64 ELF. On Termux validate:

```sh
file bazel
readelf -h bazel
readelf -d bazel
./bazel --version
./bazel help
```

`file` must identify `ARM aarch64`; it must not identify x86-64 or require
`/lib64/ld-linux-aarch64.so.1`.

## CI configuration

The workflow intentionally uses a normal GitHub Linux x86_64 runner and the
Android NDK cross compiler. GitHub's ARM runners would produce GNU/Linux ARM64
ELFs, which Termux cannot execute.
