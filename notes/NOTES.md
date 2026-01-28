# Yeet'N C - Trying to revive a Yeti Tool CNC

## Introduction

Last year, I joined a local fablab. If you like building stuff, I would highly recommend it.
These are great places to learn new skills, spend time with wonderful people and play with machines out of reach of a typical toolbox.

One of these tools in my local fablab is a CNC router by Yeti Tool. I would love to play with it, but unfortunately, it went out of service months before I joined.
To complicate matters, [Yeti Tool went under in 2024](https://find-and-update.company-information.service.gov.uk/company/11310906/insolvency). Not ideal, even if [Trend UK](https://www.trend-eu.com/products/cnc-machines/trend-yeti-cnc-smartbench/trend-yeti-cnc-smartbench) stepped-up and started providing spare parts and support.

In our case, it's the electronic boards which have various issues, from broken connectors to fried components.
I'm not actually sure what the issues are. I could probably investigate and fix these, but I'm actually not too keen on it:

1. the fix would likely be a fragile bodge work just waiting to break again.
2. even if it worked, it would let the tool in an unmaintainable state, with no effective software support and partial hardware one.
3. I would not learn as much.

For all these reasons, plus my incurable Open Source ethos, I'm much more keen on trying to rebuild the whole controller & stepper drivers stuff.
I might be way over my head, Dunning-Kruger style, but as we say, You Live Only Once, and it's a nice step up from a Voron 0.2 build.

## What Are The Options?

Let's limit ourself to Open Source options.

TODO Linux CNC + required hardware 

More "printer like" setups
TODO FluidNC + ESP32
TODO GrblHAL + STM32

TODO final choice:

 BTT SKR3 Pro + TMC 5160 + Pie

 GRBHAL + gsender

Probably will encounter issues like not enough end stops or no way to control the spindle, but not too concerned, these parts could easily be repurposed for a voron 2.4 or Trident.

## Starting By the End

TODO: gsender setup (package ansible role nginx xwfb/xvfb hacks, importance of video + dialout groups.

Screenshots 

## Documentation

- **[WIRING.md](WIRING.md)** - Complete wiring guide for BTT SKR 3 with grblHAL
- **[BUILD_FLASH.md](BUILD_FLASH.md)** - Build and flash instructions
- **[TESTING_TROUBLESHOOTING.md](TESTING_TROUBLESHOOTING.md)** - Testing procedures, troubleshooting, and safety

## grblHAL Build and Flash

**See [BUILD_FLASH.md](BUILD_FLASH.md) for complete build and flash instructions.**

Quick commands:
```bash
skr3-build    # Build firmware
skr3-flash    # Flash via DFU (interactive)
```

### Initial Setup

```bash
git submodule update --init --recursive
cd ansible
ansible-playbook -i inventory rasp-setup.yml
```

### Building on ARM64 Linux (Raspberry Pi, etc.)

PlatformIO doesn't provide pre-built ARM GCC toolchain packages for `linux_aarch64`. The Ansible playbook includes a workaround that:

1. Installs the system ARM GCC toolchain via `apt install gcc-arm-none-eabi`
2. Creates symlinks in PlatformIO's package directory pointing to the system toolchain
3. Patches the ststm32 platform configuration to accept any toolchain version

This workaround is automatically applied when running the Ansible playbook on ARM64 systems. The build scripts (`skr3-build`) also include runtime checks to ensure the workaround is in place.

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


