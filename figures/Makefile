FIGURES =
artworks = $(addsuffix .aw, $(FIGURES))

draft: $(artworks) figures.ent

figures.ent: $(FIGURES)
ifeq ($(FIGURES),)
	touch $@
else
	@echo '<!-- External entities for files with figures -->' > $@; \
	for f in $^; do                                            \
	  echo '<!ENTITY '"$$f SYSTEM \"figures/$$f.aw\">" >> $@;  \
	done
endif

%.aw: %
	@echo '<artwork><![CDATA[' > $@; \
	cat $< >> $@;                    \
	echo ']]></artwork>' >> $@

clean:
	@rm -rf $(artworks) figures.ent
