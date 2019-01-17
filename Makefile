paper.pdf: paper.Rmd
	R -e "rmarkdown::render('$<')"
