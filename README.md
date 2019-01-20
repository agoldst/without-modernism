This repository contains materials for reproducing the manuscript, including calculated tables and figures, of my essay "[Modernist Studies without Modernism](https://osf.io/wrhj2/)." Quite apart from the (limited) validity reproducibility brings to my work, I hope the code and data I share here could be used as building blocks for others interested in studying similar topics.

Probably of most interest is the data analyzed. The data are derived from exported MLA International Bibliography query results. In the [generated](generated) folder are two files:

- [b.tsv](generated/b.tsv): selected bibliographic information for all items analyzed in the paper: accession numbers, publication dates, item type, journal title, and publisher---together with a flag for whether the title matches `/modernis[mt]/i`. These items were compiled in 2014–2016 from queries for the following:

    + all items in English with subject heading "1900-1999";
    + all items in English matching keywords "modernism" or "modernist";
    + all items from the *Journal of Modern Literature* and *Modernism/modernity*;
    + all items from *American Literary History*, *American Quarterly*, and *American Literature*.

- [subjects.tsv](generated/subjects.tsv): subject headings for every item listed in b.tsv, keyed by accession number.

I wish to make a clear distinction between the reproducibility data and the bibliography itself, so this information cannot be used to reconstruct bibliographic database entries. It is enough, however, to repeat all the analyses in my paper, and may have other scholarly uses as well. I include the [R script](process_data.R) I used to generate these files from the downloaded bibliography results, but it is neither possible nor necessary to execute this script in order to reproduce my paper. (It is impossible because I cannot share my full data files. And unfortunately attempting to repeat my queries currently yields a defective dataset--at some time between 2016 and the moment of writing, the bulk download feature on EBSCOhost's MLAIB portal became leaky.)

A single throwaway remark in the paper makes use of a different dataset, the metadata from [Word Frequencies in English-Language Literature, 1700-1922](http://dx.doi.org/10.13012/J8JW8BSJ), which has been very generously released by the authors under a Creative Commons license. The three files in [data/htrc-genre](data/htrc-genre) are part of

Ted Underwood, Boris Capitanu, Peter Organisciak, Sayan Bhattacharyya, Loretta Auvil, Colleen Fallaw, J. Stephen Downie (2015). Word Frequencies in English-Language Literature, 1700-1922 (0.2) \[Dataset\]. HathiTrust Research Center. doi:10.13012/J8JW8BSJ.

In order to reproduce the manuscript essay with all its figures and tables, run `make`. This invokes the `rmarkdown` R package to generate a PDF file from paper-plain.Rmd; for comparison, I have committed a copy of the [output PDF](paper-plain.pdf) as generated on my system to the repository. You will need the following R packages installed from CRAN for this process:

- rmarkdown
- tidyverse
- ggrepel
- boot
- ineq
- poweRlaw
- igraph

You will also need two small R packages I have written, available on github:

- [mlaibr](http://github.com/agoldst/mlaibr)
- [scuro](http://github.com/agoldst/scuro)

And of course you will need all the dependencies of these, notably an installation of TeX. It would have been nice for me to formalize all these dependencies by making this an R package, but this project has taken long enough.

In order to exactly reproduce my manuscript [PDF](https://osf.io/wrhj2/) of the paper, you would need the font I have used, Garamond Premier Pro. The source code for the PDF as found at the [OSF repository](https://osf.io/frcys) is [paper.Rmd](paper.Rmd). Run `make paper.pdf` to generate this file, if you own the font. paper-plain.Rmd and paper.Rmd differ only in typeface settings; they are generated from a shared file, [paper-body.Rmd](paper-body.Rmd), with different headers ([paper-head.Rmd](paper-head.Rmd) and [paper-head-plain-Rmd](paper-head-plain.Rmd)) pasted on by the Make rules.

I cannot provide any technical assistance to other users of this material.

Andrew Goldstone (<andrew.goldstone@rutgers.edu>)

January 2019

# LICENSE

The text of the paper itself contained in [paper.Rmd](paper.Rmd) is copyright Andrew Goldstone, 2019. I do not object to re-uses of the R code in this repository.

The generated files created by me in the [generated](generated) directory I release under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0).
