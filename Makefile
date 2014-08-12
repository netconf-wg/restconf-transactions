I_D = draft-ietf-netmod-routing-cfg
REVNO = 15
DATE ?= $(shell date +%F)

idrev = $(I_D)-$(REVNO)
updid = .tools/xslt/upd-i-d.xsl
xslpars = --stringparam date $(DATE) --stringparam i-d-rev $(REVNO)

.PHONY: init validate clean

all:
	@$(MAKE) -C yang draft
	@$(MAKE) -C figures draft
	$(idrev).txt

$(idrev).xml: $(I_D).xml
	xsltproc $(xslpars) $(updid) $< | xmllint --noent -o $@ -

$(idrev).txt: $(idrev).xml
	xml2rfc $<

clean:
	@$(MAKE) -C figures clean
	@$(MAKE) -C yang clean
	rm -rf $(idrev).*
