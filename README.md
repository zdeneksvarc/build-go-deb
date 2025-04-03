# Build and install Golang as a Debian `.deb` package

This script downloads and builds the latest (or specified) version of Go from the official source, packages it as a `.deb`, and installs it cleanly into `/usr/local/go`.

The result is a self-contained `.deb` file, easy to deploy and uninstall using standard Debian tools.


## 🔧 Build usage

Download and build the latest version of Go:

```bash
./build-go.sh
```

Or build a specific version:

```bash
GO_VERSION=1.24.2 ./build-go.sh
```

This creates a file like:

```
golang-custom_1.24.2_amd64.deb
```

## 📦 Install

```bash
sudo dpkg -i golang-custom_1.24.2_amd64.deb
```

## 🛣️ Add to PATH

To use `go` globally, add this to your shell config (e.g. `~/.bashrc` or `~/.zshrc`):

```bash
export PATH=$PATH:/usr/local/go/bin
```

Then reload your shell:

```bash
source ~/.bashrc    # or ~/.zshrc
```

## 🧽 Uninstall

To remove the Go installation:

```bash
sudo dpkg -r golang-custom
```

If you modified your shell config, also remove this line:

```bash
export PATH=$PATH:/usr/local/go/bin
```

## 📁 Notes

- The build runs in `/dev/shm` (tmpfs) and cleans up after itself.
- The downloaded Go tarball is automatically removed.
- Only one file (`.deb`) remains in the current directory.
- Tested on Debian 12 (Bookworm).

