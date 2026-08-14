# Fixed Termux Python package

This directory stores the exact aarch64 Termux Python package used by the
AOSP-shaped `aarch64-termux-prebuilt` host-tools layout.

Package:

```text
python_3.14.6-1_aarch64.deb
```

- Source repository: `https://packages-cf.termux.dev/apt/termux-main`
- Repository path: `pool/main/p/python/python_3.14.6-1_aarch64.deb`
- Version: `3.14.6-1`
- Architecture: `aarch64`
- Size: `4816756` bytes
- SHA256: `3166e56c2b6c03fff41191fbb9d736302978e7c484702814d9f6dc99dd6006bd`

`python.deb` is a stable symlink to the versioned package, matching the
versioned-file plus stable-name convention used by AOSP prebuilts.

The dependency names and the versions observed from the same Termux host are
in `DEPS.lock`. The `.deb` is retained only as a fixed official source
artifact. It is not the runtime delivery format and must not be installed as
part of the portable tool bundle.

The final delivery must unpack the Python runtime into this repository's
versioned bundle, collect its shared-library closure, and use relative runtime
paths. It must run without `pkg install python`, `dpkg -i`, or an existing
Termux Python installation.

If the dynamic closure cannot be made relocatable and reproducible, the
implementation must switch to a Termux-official-script static/embedded Python
build. Static linking is not assumed successful until its interpreter,
`_ssl`, `_sqlite3`, `_bz2`, `_lzma`, `zlib`, and dynamic library closure have
each been tested.
