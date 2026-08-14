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
in `DEPS.lock`. The `.deb` is not self-contained: installing it requires the
runtime dependency closure listed there. No unversioned `pkg install python`
step is part of the build contract.

Installation is intentionally package-manager based:

```sh
dpkg -i prebuilts/python/aarch64-termux/python_3.14.6-1_aarch64.deb
```

If dependency closure verification shows that the host package set cannot be
made reproducible, the next implementation is a Termux-official-script
static/embedded Python build. Static linking is not assumed successful until
its interpreter, `_ssl`, `_sqlite3`, `_bz2`, `_lzma`, `zlib`, and dynamic
library closure have each been tested.
