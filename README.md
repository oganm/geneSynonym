[![Build Status](https://travis-ci.org/oganm/geneSynonym.svg?branch=master)](https://travis-ci.org/oganm/geneSynonym) [![codecov](https://codecov.io/gh/oganm/geneSynonym/branch/master/graph/badge.svg)](https://codecov.io/gh/oganm/geneSynonym)


# Gene Synonym
An r package that works as a wrapper to synonym information in ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz. Updates weekly since 8th of Match 2017

Available species are
* Homo sapiens
* Mus musculus
* Rattus norvegicus
* Danio rerio
* Escherichia coli
* Caenorhabditis elegans
* Drosophila melanogaster
* Rhesus macaque

More species can be added on request

Installation
============
```r
library(devtools)
install_github('oganm/geneSynonym')
```

Usage
===========
```r
geneSynonym(c('Eno2','Mog'), tax = 10090)

mouseSyno(c('Eno2','Mog'))

humanSyno('MOG')
```
