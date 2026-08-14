# Kleaf common-android14-6.1: Linux-x86 to aarch64-Termux migration

Status: migration inventory only. This document is intentionally not a claim that
`tools/bazel run //common:kernel_aarch64_dist` is complete.

## Manifest workspace established

The official kernel manifest was initialized at:

```text
/data/data/com.termux/files/home/common-android14-6.1
```

The command shown in the AOSP documentation must use the manifest branch
`common-android14-6.1`. There is no `android14-6.1` branch in
`android.googlesource.com/kernel/manifest`.

```sh
repo init \
  -u https://android.googlesource.com/kernel/manifest \
  -b common-android14-6.1
```

The manifest HEAD observed during this inventory is:

```text
044de8a1852fcf7cba788c633baf538e440f4f82
```

`repo init` is complete. `repo sync` has not yet been run.

## Linux-x86 host surface from the manifest

The manifest currently requests these Linux-oriented host paths:

```text
prebuilts/clang/host/linux-x86
prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8
prebuilts/build-tools
prebuilts/clang-tools
prebuilts/kernel-build-tools
prebuilts/bazel/linux-x86_64
prebuilts/jdk/jdk11
prebuilts/ndk-r23
```

`build/kernel` creates the top-level launcher links:

```text
tools/bazel -> build/kernel/kleaf/bazel.sh
WORKSPACE    -> build/kernel/kleaf/bazel.WORKSPACE
```

The launcher chain is not PATH-based:

```text
build/kernel/kleaf/bazel.sh
  -> prebuilts/build-tools/path/linux-x86/python3
  -> build/kernel/kleaf/bazel.py
  -> prebuilts/bazel/linux-x86_64/bazel
  -> prebuilts/jdk/jdk11/linux-x86
```

## What is already constructed

### aarch64-Termux Bazel

Repository:

```text
https://github.com/Gong-Mi/bazel-termux
```

Artifact:

```text
prebuilts/bazel/aarch64-termux/bazel_nojdk-6.3.0-aarch64-termux
```

It has passed the standalone aarch64 Termux Bazel client/server smoke test when
its libc++ runtime is made visible. It is not yet wired into Kleaf's hard-coded
`prebuilts/bazel/linux-x86_64/bazel` path.

### aarch64-Termux Python

Repository:

```text
https://github.com/Gong-Mi/prebuilts-python-aarch64-termux
```

The CPython 3.13.7 artifact has passed Android/aarch64 execution after relocation.
It has no Python extension `.so` files and its ELF dependencies are Android system
libraries plus `libz.so`. It is not yet wired into Kleaf's hard-coded
`prebuilts/build-tools/path/linux-x86/python3` path.

## Remaining work items

The following are separate work items, not one interchangeable "build tools"
step:

1. Run `repo sync` for the initialized `common-android14-6.1` workspace.
2. Add a stable aarch64-Termux Python path matching Kleaf's launcher contract.
3. Change or parameterize `kleaf/bazel.sh` so it does not require the Linux-x86
   Python path.
4. Change or parameterize `kleaf/bazel.py` so the Bazel path is not fixed to
   `prebuilts/bazel/linux-x86_64/bazel`.
5. Add an aarch64-Termux Bazel layout and solve its `libc++_shared.so` runtime
   dependency without relying on the interactive shell's `LD_LIBRARY_PATH`.
6. Verify the Termux system Clang/LLVM against the selected Kleaf toolchain
   version and adapt only the toolchain registration/path; do not build or upload
   a Clang prebuilt.
7. Update Kleaf toolchain registration and all `linux-x86` labels needed to use
   the system Clang while keeping the official toolchain semantics.
8. Build or source aarch64-Termux JDK and replace the fixed
   `prebuilts/jdk/jdk11/linux-x86` server path.
9. Build or source aarch64-Termux clang-tools, including bindgen where required.
10. Build or source aarch64-Termux kernel-build-tools (`bc`, `dtc`, `pahole`,
    `stg`, `stgdiff`, and the other tools selected by the manifest).
11. Resolve the manifest's Linux host GCC project or prove that this branch does
    not select it for the requested target.
12. Resolve the manifest's NDK r23 path and distinguish target SDK inputs from
    host-executable inputs.
13. Replace or adapt `mkbootimg`, build-tools, and shell execution paths for
    Termux/Bionic (`/bin/bash` is not a valid assumption).
14. Run short launcher probes in order: `tools/bazel version`, Bazel server
    startup, Kleaf analysis, one host-tool action, and only then
    `//common:kernel_aarch64_dist`.
15. Perform a real kernel dist build and separately verify the output artifacts.

## Verified execution progress

- `tools/bazel version` ✅ Passed
- `tools/bazel query //common:kernel_aarch64_dist` ✅ Passed
- `tools/bazel build --nobuild //common:kernel_aarch64_dist` ✅ Passed (Analyzed 93,258 targets with 0 errors)

## Current Action Execution Blocker

1. `build-runfiles` / embedded tools `libc++_shared.so` runtime closure:
   Bazel extracts internal helper binaries (`build-runfiles`, `process-wrapper`, `daemonize`) into its install user root and executes them via `exec env -` (clearing `LD_LIBRARY_PATH`). Because Bionic ELF binaries require `libc++_shared.so`, execution fails with `library "libc++_shared.so" not found`. Manually altering installed binaries fails installation checksums.

   **Resolution**: Build `libc++_shared.so` directly into `bazel-termux`'s embedded tools payload or embed `$ORIGIN` RUNPATH at compile time.

2. Shell execution compatibility:
   `workspace_status_common.sh` and `workspace_status.sh` hard-code `/bin/bash` and `/bin/sh`. They have been patched in `Gong-Mi/kernel-build-termux` to use `/system/bin/sh` and resolve `$PREFIX/bin/python3`.

## Acceptance boundary

A successful standalone aarch64 Bazel invocation is not Kleaf acceptance. The
migration is accepted only after all of these pass in the initialized workspace:

```sh
tools/bazel version
tools/bazel query //common:kernel_aarch64_dist
tools/bazel build //common:kernel_aarch64_dist
# then, with the requested output directory:
tools/bazel run //common:kernel_aarch64_dist -- --destdir="$DIST_DIR"
```

The current state therefore has `repo init`, a standalone aarch64 Bazel, and a
standalone aarch64 Python runtime; it does not yet have a runnable aarch64-Termux
Kleaf host-toolchain closure.

## Repository boundary decision

Do not create one repository per ELF. Preserve the AOSP manifest project
boundaries, while changing the platform directory inside each project from a
Linux host directory to an aarch64-Termux directory where appropriate.

| Official manifest project | Aarch64-Termux replacement boundary | Required now? | Reason |
|---|---|---:|---|
| `platform/prebuilts/build-tools` | One `prebuilts-build-tools-aarch64-termux` repository containing the general host tools and the `path/aarch64-termux` launcher layout | Yes | Python is only one member of this official tool group; the current standalone Python repository is a source/build boundary and must be assembled or consumed here |
| `platform/prebuilts/bazel/linux-x86_64` | One `prebuilts-bazel-aarch64-termux` repository | Yes | Bazel launcher and its payload are a separate AOSP project; current artifact still needs libc++ runtime closure |
| `platform/prebuilts/jdk/jdk11` | One `prebuilts-jdk11-aarch64-termux` repository | Yes | Kleaf hard-codes the JDK server path; `bazel_nojdk` does not remove this requirement |
| `platform/prebuilts/clang/host/linux-x86` | Use the Termux system Clang/LLVM for the first migration; do not create or upload an aarch64-Termux Clang prebuilt | No, deferred | The compiler is explicitly kept as a system dependency for now; only Kleaf toolchain registration/path compatibility and the required version/capability checks remain |
| `platform/prebuilts/clang-tools` | One `prebuilts-clang-tools-aarch64-termux` repository | Yes | `bindgen` and related tools are referenced separately from the compiler |
| `kernel/prebuilts/build-tools` | One `prebuilts-kernel-build-tools-aarch64-termux` repository | Yes | `stg`, `stgdiff`, `bc`, `dtc`, `pahole`, and imported libraries have their own Kleaf labels |
| `platform/prebuilts/gcc/...` | One GCC host-tool repository, only if the selected branch/config actually uses it | Conditional | Do not build this before tracing the requested target's actions |
| `toolchain/prebuilts/ndk/r23` | One NDK/sysroot repository or an explicitly documented target-only substitute | Conditional | Separate target SDK input from host-executable tools |
| `platform/system/tools/mkbootimg` | Source project patch/build, not a prebuilt repository | Conditional | It is a source project in the manifest, not an AOSP prebuilt tool project |
| `kernel/build` | Source fork/patch or local manifest overlay | Yes | `bazel.sh`, `bazel.py`, workspace and toolchain labels contain Linux paths |
| `prebuilts/rust` / Rust toolchain | One Rust prebuilt boundary if Rust is enabled by the target | Conditional | Current manifest does not list it, but Kleaf has conditional `prebuilts/rust/linux-x86` references |

The official `linux-arm64` directories in AOSP `build-tools` and `clang-tools`
do not satisfy this target: they are Linux/glibc host binaries, while this
workspace runs on Android/Bionic. They are useful as structural references only.

The first repository to build next should therefore be the combined
`prebuilts-build-tools-aarch64-termux` boundary, not another isolated Python
repository. The existing Python repository remains useful as the reproducible
CPython source/build artifact, but the final Kleaf-facing layout should expose
it under the official build-tools shape, for example:

```text
prebuilts/build-tools/
├── path/aarch64-termux/python3
└── aarch64-termux/
    ├── bin/python3
    └── lib/python3.13/
```
