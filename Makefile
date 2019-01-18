paper-plain.pdf: paper-plain.Rmd
	R -e "rmarkdown::render('$<')"

paper.pdf: paper.Rmd
	R -e "rmarkdown::render('$<')"
