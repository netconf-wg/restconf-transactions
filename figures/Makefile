FIGURES =
artworks = $(addsuffix .aw, $(FIGURES))

draft: $(artworks) figures.ent

figures.ent: $(FIGURES)
ifneq ($(FIGURES),)
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
ifneq ($(FIGURES),)
	@rm -rf $(artworks)
	@rm -rf figures.ent
endif
