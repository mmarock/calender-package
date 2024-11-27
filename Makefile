
LATEX_COMPILER := $(shell which lualatex)

calendar := test

all: $(foreach x, ${calendar}, ${x}.pdf)

%.pdf: %.tex calendar.cls $(wildcard images/*.png)
	lualatex -interaction=nonstopmode -halt-on-error $< && \
	lualatex -interaction=nonstopmode -halt-on-error $<

clean:
	$(foreach x, ${calendar}, @rm ${x}.pdf;)
	$(foreach x, ${calendar}, @rm ${x}.aux;)
	$(foreach x, ${calendar}, @rm ${x}.log;)

.PHONY: all clean
