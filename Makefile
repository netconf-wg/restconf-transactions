I_D = draft-ietf-netmod-routing-cfg
REVNO = 15
DATE ?= $(shell date +%F)
export DATE 
.PHONY: init validate clean

all:
	@$(MAKE) -C yang draft
	@$(MAKE) -C figures draft

entities:
ifneq ($(FIGURES),)
	$(MAKE) -C yang
endif

clean:
	@$(MAKE) -C figures clean
	@$(MAKE) -C yang clean
