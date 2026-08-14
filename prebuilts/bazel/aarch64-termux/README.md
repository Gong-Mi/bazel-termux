# Bazel 6.3.0 — aarch64 Termux prebuilt

This directory follows the AOSP kernel Kleaf prebuilt layout used by
`prebuilts/bazel/linux-x86_64`: a versioned `bazel_nojdk-*` launcher and a
stable `bazel` symlink.

## Artifact

- File: `bazel_nojdk-6.3.0-aarch64-termux`
- Target: Android aarch64 / Termux
- Android API: 28
- ELF interpreter: `/system/bin/linker64`
- Built with: Android NDK r29 (Clang 21)
- Bazel target: `//src:bazel_nojdk`
- CI run: `31760606673`
- Source commit: `8b896895c1644db6b991b437d2f0d65e64f6551c`
- SHA-256: `989f4ed2e0affd139aa9314342bfd195378a397cf6f5b48ad79afc5a5b59ad4`

The launcher is a self-extracting ELF plus ZIP payload. It must be copied
byte-for-byte; do not run `strip` on it.

## Termux use

```sh
cd prebuilts/bazel/aarch64-termux
chmod 755 bazel
./bazel --version
./bazel help
```

Bazel actions that execute shell commands on Termux need the Termux shell path:

```sh
./bazel build //:target \
  --shell_executable="$PREFIX/bin/bash"
```

The artifact was verified with a real client/server build in a minimal
workspace using this setting.
