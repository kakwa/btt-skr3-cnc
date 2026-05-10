SHELL := /bin/bash

KICAD_CLI ?= kicad-cli
ZIP ?= zip

PROJECTS := \
	breakout_bottom_dsub25 \
	breakout_top_dsub25 \
	breakout_top_vga

# -----------------------------------------------------------------------------
# Default target
# -----------------------------------------------------------------------------

all: $(PROJECTS:%=%.zip)

# -----------------------------------------------------------------------------
# Project-specific PCB names
# -----------------------------------------------------------------------------

breakout_bottom_dsub25_PCB := bottom_dsub25
breakout_top_dsub25_PCB := adapters
breakout_top_vga_PCB := adapters

# -----------------------------------------------------------------------------
# Template
# -----------------------------------------------------------------------------

define KICAD_TEMPLATE

$1_BUILD_DIR := $1/build
$1_GERBER_DIR := $$($1_BUILD_DIR)/gerbers
$1_PCB_FILE := $1/$$($1_PCB).kicad_pcb
$1_ZIP := $1.zip

.PHONY: $1 clean-$1

$1: $$($1_ZIP)

$$($1_GERBER_DIR):
	mkdir -p $$@

$$($1_ZIP): $$($1_PCB_FILE) | $$($1_GERBER_DIR)
	@echo "==> Generating Gerbers for $1"

	$(KICAD_CLI) pcb export gerbers \
		--output $$($1_GERBER_DIR) \
		$$($1_PCB_FILE)

	$(KICAD_CLI) pcb export drill \
		--output $$($1_GERBER_DIR) \
		$$($1_PCB_FILE)

	@echo "==> Creating archive $$@"

	cd $$($1_GERBER_DIR) && \
		$(ZIP) -r ../../../$$@ .

clean-$1:
	rm -rf $$($1_BUILD_DIR) $$($1_ZIP)

endef

# -----------------------------------------------------------------------------
# Instantiate template for all projects
# -----------------------------------------------------------------------------

$(foreach proj,$(PROJECTS),$(eval $(call KICAD_TEMPLATE,$(proj))))

# -----------------------------------------------------------------------------
# Global clean
# -----------------------------------------------------------------------------

.PHONY: clean

clean: $(PROJECTS:%=clean-%)
