library(data.table)
library(magrittr)
library(git2r)
library(dplyr)
library(ogbox)
library(glue)
library(R.utils)
library(readr)
options(timeout=60*10)

autogit = TRUE
repo = repository('.')


usethis::use_data_raw()

taxData = read.table('ftp://ftp.ncbi.nih.gov/pub/HomoloGene/build68/build_inputs/taxid_taxname',
                     sep = '\t',
                     stringsAsFactors = FALSE)
colnames(taxData) = c('tax_id','name_txt')


download.file(url = "ftp://ftp.ncbi.nih.gov/pub/HomoloGene/last-archive/homologene.data", destfile = 'data-raw/homologene.data')
homologene = fread('data-raw/homologene.data',sep ='\t',quote='',stringsAsFactors = FALSE,data.table = FALSE)
names(homologene) = c('HID','Taxonomy','Gene.ID','Gene.Symbol','Protein.GI','Protein.Accession')

homologeneSpecies = homologene$Taxonomy %>% unique

taxData %<>% filter(tax_id %in% c(homologeneSpecies))

taxData %<>% rbind(data.frame(tax_id = 562,name_txt = 'Escherichia coli'))
# not sure why it's not in this file but it in the ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
# also not represented in homologene. go to stackoverflow at some point.

usethis::use_data(taxData, overwrite = TRUE)
git2r::add(repo,path = 'data/taxData.rda')    

# get gene_info --------

download.file('ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz','data-raw/gene_info.gz')
R.utils::gunzip('data-raw/gene_info.gz', overwrite = TRUE)


regexTaxID = paste0(ogbox::regexMerge(taxData$tax_id))

callBack = function(x,pos){
    out = x %>% 
        select(Symbol,
               GeneID,
               Synonyms,
               Symbol_from_nomenclature_authority,
               tax_id) %>%
        filter(tax_id %in% taxData$tax_id) %>% 
        mutate(GeneID = as.integer(GeneID),
               tax_id = as.integer(tax_id))
    return(out)
}

geneInfo = read_tsv_chunked('data-raw/gene_info',
                            DataFrameCallback$new(callBack),
                            col_names = c('tax_id', 'GeneID', 'Symbol', 'LocusTag', 'Synonyms',
                                          'dbXrefs', 'chromosome', 'map_location', 'description',
                                          'type_of_gene', 'Symbol_from_nomenclature_authority',
                                          'Full_name_from_nomenclature_authority', 'Nomenclature_status',
                                          'Other_designations', 'Modification_date','Feature_type'),
                            chunk_size = 1000000,skip = 1)



synos = sapply(1:nrow(geneInfo),function(i){
    out = geneInfo$Symbol[i]
    if(!geneInfo$Symbol_from_nomenclature_authority[i] == '-'){
        out = c(out,geneInfo$Symbol_from_nomenclature_authority[i])
    }
    if(!geneInfo$Synonyms[i]=='-'){
        out = c(out,geneInfo$Synonyms[i])
    }
    out = unique(out)
    out %<>% paste(collapse='|')
    
    return(out)
})
names(synos) = geneInfo$GeneID


# file generation
for (i in taxData$tax_id){
    teval(paste0('syno',i," <- synos[geneInfo[,'tax_id']==i]"),envir = .GlobalEnv)
    teval(paste0('usethis::use_data(syno', i,',overwrite=TRUE)'))
    
    rawSyno = paste(names(synos[geneInfo[,'tax_id']==i]),synos[geneInfo[,'tax_id']==i],sep = '|')
    cat(rawSyno, file = paste0('data-raw/syno',i), sep = '\n')
    # teval(paste0('cat(syno',i,', file="data-raw/syno',i,'",sep="\n")'))
    
    teval(paste0('rm(syno',i,',envir = .GlobalEnv)'))
    if(autogit){
        git2r::add(repo,path =paste0('data-raw/syno',i))
        git2r::add(repo,path =paste0('data/syno',i,'.rda'))
    }
    Sys.sleep(2)
}

devtools::document()
if(autogit){
    git2r::add(repo,path = 'man/')    
}


# version update add date to the version as a revision
version = ogbox::getVersion()
version %<>% strsplit('\\.') %>% {.[[1]]}
ogbox::setVersion(paste(version[1],version[2],
                        format(Sys.Date(),'%y.%m.%d') %>% 
                            gsub(pattern = '\\.0','.',x=.),sep='.'))
ogbox::setDate(format(Sys.Date(),'%Y-%m-%d'))

if(autogit){
    git2r::add(repo,path ='DESCRIPTION')
    
    tryCatch({
        git2r::commit(repo,message = paste('Weekly auto update'))
        # server's git2r doesn't seem to like ssh git remotes
        system('git push -f')
        # token = readLines('data-raw/auth')
        # Sys.setenv(GITHUB_PAT = token)
        # cred = git2r::cred_token()
        # git2r::push(repo,credentials = cred)
    },
    error = function(e){
        print('nothing to update')
    })
}
