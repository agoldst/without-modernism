paper.Rmd: paper-head.Rmd paper-body.Rmd
	cat $^ > $@

paper-plain.Rmd: paper-head-plain.Rmd paper-body.Rmd
	cat $^ > $@

rmds := paper.Rmd paper-plain.Rmd

mds := $(patsubst %.Rmd,%.md,$(rmds))
pdfs := $(patsubst %.Rmd,%.pdf,$(rmds))

$(pdfs): %.pdf: %.Rmd
	R -e 'rmarkdown::render("$<")'

.DEFAULT_GOAL := paper-plain.pdf
