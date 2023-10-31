
[![Build
Status](https://travis-ci.org/oganm/geneSynonym.svg?branch=master)](https://travis-ci.org/oganm/geneSynonym)
[![codecov](https://codecov.io/gh/oganm/geneSynonym/branch/master/graph/badge.svg)](https://codecov.io/gh/oganm/geneSynonym)

# Gene Synonym

An r package that works as a wrapper to synonym information in
<ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz>. Updates
semi-regularly since 8th of Match 2017

Available species are

``` r
geneSynonym::taxData
```

    ##    tax_id                      name_txt
    ## 1   10090                  Mus musculus
    ## 2   10116             Rattus norvegicus
    ## 3   28985          Kluyveromyces lactis
    ## 4  318829            Magnaporthe oryzae
    ## 5   33169         Eremothecium gossypii
    ## 6    3702          Arabidopsis thaliana
    ## 7    4530                  Oryza sativa
    ## 8    4896     Schizosaccharomyces pombe
    ## 9    4932      Saccharomyces cerevisiae
    ## 10   5141             Neurospora crassa
    ## 11   6239        Caenorhabditis elegans
    ## 12   7165             Anopheles gambiae
    ## 13   7227       Drosophila melanogaster
    ## 14   7955                   Danio rerio
    ## 15   8364 Xenopus (Silurana) tropicalis
    ## 16   9031                 Gallus gallus
    ## 17   9544                Macaca mulatta
    ## 18   9598               Pan troglodytes
    ## 19   9606                  Homo sapiens
    ## 20   9615        Canis lupus familiaris
    ## 21   9913                    Bos taurus
    ## 22    562              Escherichia coli

More species can be added on request

# Installation

``` r
library(devtools)
install_github('oganm/geneSynonym')
```

# Usage

The output is a nested list since gene synonyms are not nececarilly
unique. For instance

``` r
mouseSyno('Tex40')
```

    ## $Tex40
    ## $Tex40$`16528`
    ## [1] "Kcnk4"    "Catsperz" "MLZ-622"  "TRAAK"    "TRAAKt"   "Tex40"   
    ## 
    ## $Tex40$`67077`
    ## [1] "Catsperz"      "1700019N12Rik" "A430107B04Rik" "MLZ-622"      
    ## [5] "Tex40"

Names of vectors within the list are NCBI ids.

Input is a vector of gene names/NCBI ids and a tax identifier.
Alternatively shorthand functions exist for human and mouse.

``` r
geneSynonym(c('Eno2','Mog'), tax = 10090)
```

    ## $Eno2
    ## $Eno2$`13807`
    ## [1] "Eno2"       "D6Ertd375e" "Eno-2"      "NSE"       
    ## 
    ## 
    ## $Mog
    ## $Mog$`17441`
    ## [1] "Mog"           "B230317G11Rik"

``` r
geneSynonym(c('Eno2','Mog'), tax = 10090)
```

    ## $Eno2
    ## $Eno2$`13807`
    ## [1] "Eno2"       "D6Ertd375e" "Eno-2"      "NSE"       
    ## 
    ## 
    ## $Mog
    ## $Mog$`17441`
    ## [1] "Mog"           "B230317G11Rik"

``` r
mouseSyno(c('Eno2',17441))
```

    ## $Eno2
    ## $Eno2$`13807`
    ## [1] "Eno2"       "D6Ertd375e" "Eno-2"      "NSE"       
    ## 
    ## 
    ## $`17441`
    ## $`17441`$`17441`
    ## [1] "Mog"           "B230317G11Rik"

``` r
humanSyno('MOG')
```

    ## $MOG
    ## $MOG$`4340`
    ## [1] "MOG"    "BTN6"   "BTNL11" "MOGIG2" "NRCLP7"
