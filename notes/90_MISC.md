# Misc Pieces of Informations

## Build Work Arounds

**Manual workaround** (if needed):

```bash
# Create symlinks to system toolchain
mkdir -p ~/.platformio/packages/toolchain-gccarmnoneeabi/bin
for f in /usr/bin/arm-none-eabi-*; do
  ln -sf "$f" ~/.platformio/packages/toolchain-gccarmnoneeabi/bin/
done

# Create package.json
cat > ~/.platformio/packages/toolchain-gccarmnoneeabi/package.json << 'EOF'
{
  "name": "toolchain-gccarmnoneeabi",
  "version": "1.70301.190214",
  "description": "System ARM GCC toolchain (symlinked)",
  "keywords": ["toolchain"],
  "license": "GPL-2.0-or-later",
  "system": ["*"]
}
EOF

# Patch platform.json (after first platformio run)
sudo sed -i 's/"version": ">=1.60301.0,<1.80000.0"/"version": "*"/' \
  /root/.platformio/platforms/ststm32/platform.json
```

## Platform.io Packages

For the build, I've created Debian packages for platform.io [here](https://github.com/kakwa/misc-pkg/).
