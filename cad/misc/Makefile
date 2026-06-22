SHELL := /bin/bash

OPENSCAD ?= openscad
SCAD_FILE := chain_link_v2-clip.scad

PARTS := \
	chain_link_no_leg.stl \
	chain_link_outter_leg.stl \
	chain_link_inner_leg.stl

.PHONY: all clean

all: $(PARTS)

chain_link_no_leg.stl: $(SCAD_FILE)
	$(OPENSCAD) -D 'end_leg_outter=0' -D 'end_leg_inner=0' -o $@ $<

chain_link_outter_leg.stl: $(SCAD_FILE)
	$(OPENSCAD) -D 'end_leg_outter=1' -D 'end_leg_inner=0' -o $@ $<

chain_link_inner_leg.stl: $(SCAD_FILE)
	$(OPENSCAD) -D 'end_leg_outter=0' -D 'end_leg_inner=1' -o $@ $<

clean:
	rm -f $(PARTS)
