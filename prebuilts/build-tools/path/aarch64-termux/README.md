# aarch64-Termux build-tools path

This is the Termux counterpart of AOSP's
`prebuilts/build-tools/path/linux-x86` entry points.

`python3` and `python` intentionally invoke the official Termux `python`
package instead of copying an ELF and its shared-library dependency closure.

Required package:

```sh
pkg install python
```

Verified package on the build host:

- Package: `python`
- Version: `3.14.6-1`
- Architecture: `aarch64`
- Main runtime: `$PREFIX/bin/python3.14`
- Main runtime RUNPATH: `$PREFIX/lib`
- Shared core: `$PREFIX/lib/libpython3.14.so`

The wrapper accepts `TERMUX_PYTHON` for testing or an alternate Termux prefix;
otherwise it uses `$PREFIX/bin/python3`.

This directory does not claim to be a hermetic Python distribution. A static
Python build is only needed for a future mode that must run without the Termux
package manager and its dependency set.
