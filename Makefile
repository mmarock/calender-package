
LATEX_COMPILER := lualatex
LATEX_OPTS := -interaction=nonstopmode -halt-on-error

calendar := main

all: $(foreach x, ${calendar}, ${x}.pdf)

%.pdf: %.tex calendar.cls
	${LATEX_COMPILER} ${LATEX_OPTS} $< && \
	${LATEX_COMPILER} ${LATEX_OPTS} $<

clean:
	$(foreach x, ${calendar}, @rm ${x}.pdf;)
	$(foreach x, ${calendar}, @rm ${x}.aux;)
	$(foreach x, ${calendar}, @rm ${x}.log;)

.PHONY: all clean
