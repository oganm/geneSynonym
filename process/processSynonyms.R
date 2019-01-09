library(data.table)
library(magrittr)
library(git2r)
library(dplyr)
library(ogbox)
library(glue)

devtools::use_data_raw()

if(!file.exists('data-raw/taxdump/names.dmp')){
    download.file(url ='ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz', destfile = "data-raw/taxdump.tar.gz")
    dir.create('data-raw/taxdump', showWarnings = FALSE)
    untar('data-raw/taxdump.tar.gz',exdir = 'data-raw/taxdump/')
}


download.file('ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz','data-raw/gene_info.gz')
system('gunzip -f data-raw/gene_info.gz')
geneInfo = fread('data-raw/gene_info',sep='\t',skip=1, header = F,data.table = FALSE)
setnames(geneInfo,old = names(geneInfo),new=
             c('tax_id', 'GeneID', 'Symbol', 'LocusTag', 'Synonyms',
               'dbXrefs', 'chromosome', 'map_location', 'description',
               'type_of_gene', 'Symbol_from_nomenclature_authority',
               'Full_name_from_nomenclature_authority', 'Nomenclature_status',
               'Other_designations', 'Modification_date','Feature_type'))



geneInfo = geneInfo[,c('Symbol','GeneID','Synonyms','Symbol_from_nomenclature_authority','tax_id')]

taxData = fread('data-raw/taxdump/names.dmp',data.table=FALSE, sep = '\t',quote = "")
taxData = taxData[c(1,3,5,7)]
names(taxData) = c('tax_id','name_txt','unique_name','name_class')
taxData %<>% filter(name_txt %in% c('Homo sapiens',
                                    'Escherichia coli',
                                    'Mus musculus',
                                    'Rattus norvegicus',
                                    'Danio rerio',
                                    'Caenorhabditis elegans',
                                    'Drosophila melanogaster',
                                    'Macaca mulatta'))

taxData %>% apply(1,function(x){
    dataDocs = glue('#\' Synonym information for {x["name_txt"]}\n"syno{x["tax_id"] %>% trimws}"')
}) %>% paste(collapse='\n\n') %>% writeLines('R/dataDocumentation.R')

devtools::document()

tax = taxData$tax_id

geneInfo %<>% filter(tax_id %in% tax)

synos = sapply(1:nrow(geneInfo),function(i){
    out = geneInfo$Symbol[i]
    if(!geneInfo$Symbol_from_nomenclature_authority[i] == '-'){
        out = paste0(out,'|',geneInfo$Symbol_from_nomenclature_authority[i])
    }
    if(!geneInfo$Synonyms[i]=='-'){
        out = paste0(out,'|',geneInfo$Synonyms[i])
    }

    return(out)
})
names(synos) = geneInfo$GeneID
repo = repository('.')

git2r::add(repo,path = 'R/dataDocumentation.R')

# file generation
for (i in tax){
    teval(paste0('syno',i," <- synos[geneInfo[,'tax_id']==i]"),envir = parent.frame())
    teval(paste0('devtools::use_data(syno', i,',overwrite=TRUE)'))
    teval(paste0('cat(syno',i,', file="data-raw/syno',i,'",sep="\n")'))
    teval(paste0('rm(syno',i,',envir = .GlobalEnv)'))
    git2r::add(repo,path =paste0('data-raw/syno',i))
    git2r::add(repo,path =paste0('data/syno',i,'.rda'))
    Sys.sleep(2)
}

devtools::document()
git2r::add(repo,path = 'man/')

# version update add date to the version as a revision
version = ogbox::getVersion()
version %<>% strsplit('\\.') %>% {.[[1]]}
ogbox::setVersion(paste(version[1],version[2],
                        format(Sys.Date(),'%y.%m.%d') %>% 
                            gsub(pattern = '\\.0','.',x=.),sep='.'))
ogbox::setDate(format(Sys.Date(),'%Y-%m-%d'))

git2r::add(repo,path ='DESCRIPTION')

tryCatch({
    git2r::commit(repo,message = paste('Weekly auto update'))
    token = readLines('data-raw/auth')
    Sys.setenv(GITHUB_PAT = token)
    cred = git2r::cred_token()
    git2r::push(repo,credentials = cred)
    },
    error = function(e){
        print('nothing to update')
    })


