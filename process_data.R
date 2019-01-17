# Create cleaned data files from EBSCO RIS exports.  This script is sourced
# from paper.Rmd as needed. It will fail if the data files (in c20_files and
# ris_files below) are not present.
#
# Only the bibliography fields needed for the analysis are retained (in
# particular, authors and titles are dropped). These files are not meant to be
# used for bibliographic reference; for that, please use the actual MLAIB.
#
# Outputs:
#
# generated/b.tsv: bibliographic data, one item per line: accession numbers,
# publication type and date, journal title, publisher, and a flag for whether
# the title matches `regex("\\bmodernis[mt]", ignore_case=T)`
#
# generated/subjects.tsv: subject headings for each item, keyed to accession
# numbers.


library(tidyverse)
library(stringi)
library(mlaibr) # http://github.com/agoldst/mlaibr

c20_files <- file.path("data", "modernism-mining-data", c(
    "ebsco-c20-eng-1970-1974-150228.zip",
    "ebsco-c20-eng-1974-1977-150228.zip",
    "ebsco-c20-eng-1978-1980-150228.zip",
    "ebsco-c20-eng-1981-1983-150228.zip",
    "ebsco-c20-eng-1984-1986-150228.zip",
    "ebsco-c20-eng-19870101-19881231-150302.zip",
    "ebsco-c20-eng-19870101-19891131-150228.zip",
    "ebsco-c20-eng-19891201-19911231-150228.zip",
    "ebsco-c20-eng-19920101-19931231-150228.zip",
    "ebsco-c20-eng-19940101-19951231-150228.zip",
    "ebsco-c20-eng-19960101-19971231-150228.zip",
    "ebsco-c20-eng-19980101-19991231-150228.zip",
    "ebsco-c20-eng-20000101-20011131-150228.zip",
    "ebsco-c20-eng-20011201-20030931-150228.zip",
    "ebsco-c20-eng-20031001-20031231-150301.zip",
    "ebsco-c20-eng-20031001-20050831-150228.zip",
    "ebsco-c20-eng-20050901-20060831-150301.zip",
    "ebsco-c20-eng-20050901-20070531-150228.zip",
    "ebsco-c20-eng-20070601-20090531-150301.zip",
    "ebsco-c20-eng-20090601-20110831-150301.zip",
    "ebsco-c20-eng-20110901-20131231-150228.zip",
    "ebsco-c20-eng-20140101-20141231-150228.zip"
))


ris_files <- c(
     c20_files,
     "data/msa2015seminar-data/mlaib-modmod-jml-all.zip",
     "data/mlaib-modernist-modernism-eng160524.zip",
     "data/alh.zip", # 2016
     "data/amlit.zip", # 2016
     "data/aq.zip" # 2016
)
ris_unz <- lapply(ris_files, function (f) { unz(f, unzip(f, list=T)$Name) })

b <- read_ris(ris_unz, fields=NULL, src_labels=ris_files)

# extract accession numbers
accs <- b %>%
    filter(field == "N1") %>%
    transmute(id, acc=N1_field(value, "Accession Number"))
# record source files before de-duplication
ris_src <- b %>% filter(field == "src") %>%
    inner_join(accs, by="id") %>%
    transmute(id=acc, src=value)

# now de-dupe based on acc nos.
b <- b %>%
    inner_join(accs %>% filter(!stri_duplicated(acc)), by="id") %>% 
    # now we can remove the arbitrary id and use acc. no. instead
    mutate(id=acc) %>%
    select(-acc)

# More manual de-duping, from the modernism set; I haven't done the same checks
# for the c20 set.
dupes <- c(
# Grouping CHAPs by T2 and Y1, we find two entries with distinct
# PBs. These are duplicate entries for "Degeneration, Discourse and
# Differentiation: Modernismo frente a Noventa y ocho Reconsidered,"
# (1991004437, 1994002805), so let's remove the earlier one:

"1991004437",

# Checking for distinct A2's, one finds a duplicate entry for
# "Modernism(s) Inside Out: History, Space, and Modern American Indian
# Subjectivity in Cogewea, the Half-Blood" in Geomodernisms (acc. nos.
# 2005533842, 2006401168; hbk and pbk editions of the book), so let's
# remove the hbk one (Geomods is otherwise pbk in here)

"2005533842",

# and a duplicate for "U. S. Modernism and the Emergence of 'The Right Wing of
# Film Art': The Films of James Sibley Watson, Jr., and Melville Webber", acc.
# nos. 1995070246, 1998054384. The later entry has richer subject headings, so
# discard the earlier

"1995070246",

# and a duplicate for "Madonnas of Modernism", acc. nos. 2003581365 and 
# 2005582842. The earlier subject entry is fuller, so let's keep that one

"2005582842",

# and a duplicate for "Madwomen on the Riviera: The Fitzgeralds,
# Hemingway, and the Matter of Modernism," (1998054633, 1999056705), so
# let's remove the earlier one:

"1998054633",

# A missing `;` in one or more otherwise identical A2 entries is
# responsible for the hits here for *Russian Modernism: Culture and
# the Avant-Garde, 1900-1930*, Bradbury and McFarlane's *Modernism,
# 1890-1930*, and *Faulkner, Modernism, and Film: Faulkner and
# Yoknapatawpha, 1978*. (What happens here is that instead of two A2
# fields in the RIS, there's a single A2 field with both authors. My
# script uses `;;` to delimit multiple A2s but the bibliographers used a
# single semicolon when they were untidy).

# BUT a few errors in the Bradbury and McFarlane entries produce real 
# duplicates: 1979101630 and 1979211253; 1979301329 and 1979202534; 1979102141 
# and 1979301271. Bye, guys:

c("1979101630", "1979211253", "1979102141"),

# The editor role notation differs in 1998076604 and 1999026535, but
# these are distinct items. Similarly for 1997063956 and 2002582200. So
# these are all fine.

# We will leave untouched the distinction between two different editions of 
# the Cambridge Companion to Joyce. (cf. acc. nos. 1990021854 and 2004532092).

# Similarly we should check books with duplicate Y1, T1 but distinct AUs for 
# duplicate entries. There is just one, *A Route to Modernism: Hardy, Lawrence, 
# Woolf*, 2014831082 and 2000058921 (ebook and hbk???). But these are the same 
# work so let's keep only the later one

"2000058921")

# With journal articles, don't find any duplicates,
# just authentically distinct items. Rainey did double-publish his
# Price of Modernism essay.

b <- b %>%
    filter(!(id %in% dupes))

# partition away the KW fields
subjects <- b %>%
    filter(field == "KW")
b <- b %>%
    filter(field != "KW")

# and we can spread out our long frame
b <- spread_ris(b)

# Before we can extract further subfields,
# one entry (1974208250) is missing a language, which we correct
# Bassalo and Coehlo, "Mario de Andrade no Para"
b$N1[match(
    "Accession Number: 1974208250. Publication Type: journal article. Update Code: 197401. Sequence No: 1974-2-8250.",
    b$N1)] <- 
"Accession Number: 1974208250. Publication Type: journal article. Language: Portuguese. Update Code: 197401. Sequence No: 1974-2-8250."
b <- b %>%
    mutate(pubtype=stri_trans_tolower(N1_field(N1, "Publication Type")),
           lang=N1_field(N1, "Language"),
           date=Y1_year(Y1))
stopifnot(all(b$pubtype != ""))
stopifnot(all(b$id != ""))

# let's keep anything that has English as one of its langs
b <- b %>%
    filter(str_detect(lang, "English"))

# While checking dupes I caught a book chapter by Melba Cuddy-Keane
# (acc. no. 2006533095) which is dated 2006 but seems to be in the
# same book as others with the same T2 dated 2008. Let's fix that by
# hand:
mck <- match("2006533095", b$id)
if (!is.na(mck)) {
    b$date[mck] <- as.Date("2008-01-01")
}

# Another one here:
# Boehmer, "Dreams, Cycles, and Advancing Forms of Chaos"
eb <- match("1998070296", b$id)
if (!is.na(eb)) {
    b$date[eb] <- as.Date("1998-01-01")
}

# A book without a publication date (D.F. Krell, Lunar Voices, UChiP, 1995)
dfk <- match("1995062414", b$id)
if (!is.na(dfk)) {
    b$date[dfk] <- as.Date("1995-01-01")
}

# A glitched subject heading, acc no. 1995061515
mmorris <- which(subjects$value == "1910-1917 Morris, May (1862-1938)")
if (length(mmorris) > 0) {
    subjects$value[mmorris] <- "Morris, May (1862-1938)"
}


# Happened to catch a publisher typo for Bonnie Costello's book
bc <- match("1981004494", b$id)
if (!is.na(bc)) {
    b$PB[bc] <- "Harvard UP"
}

# Let's also normalize away periods in publishers
b <- b %>% 
    mutate(PB=str_replace_all(PB, coll("."), ""))

# We'll store the result of checking if "Modernis[mt]" is in the title
b <- b %>%
    mutate(modernis_title=str_detect(
            T1, regex("\\bmodernis[mt]", ignore_case=T)))

# A couple typos produce some unparseable subject headings
# 1984082547
subjects$value[match(
    "in theory of theories of Ortega y Gasset, José (1883-1955)",
    subjects$value)] <- 
   "in theories of Ortega y Gasset, José (1883-1955)"

# 1990062787: this one means we need another row
subjects$value[match(
    "decadence Swinburne, Algernon Charles (1837-1909)",
    subjects$value)] <- 
    "decadence"

subjects <- bind_rows(subjects,
    data_frame(
        id="1990062787",
        field="KW",
        value="Swinburne, Algernon Charles (1837-1909)"
    )
)

# this one will take a while
subjects <- subjects %>%
    select(id, value) %>%
    mutate(value=strip_subject_relation(value)) %>%
    distinct(id, value) %>% ungroup()

b <- b %>% 
    select(id, pubtype, date, modernis_title, JO, PB) %>%
    write_tsv("generated/b.tsv", na="")

subjects %>%
    write_tsv("generated/subjects.tsv")
