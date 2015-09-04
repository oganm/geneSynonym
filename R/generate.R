library(ogbox)
updateSynonyms = function(){
    library(data.table)
    download.file('ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz',paste0('data','/gene_info.gz'))
    system(paste0('gunzip ',synoTarget,'/gene_info.gz'))
    geneInfo = fread(paste0('data','/gene_info'),sep='\t',skip=1, header = F)
    setnames(geneInfo,old = names(geneInfo),new=
                 c('tax_id', 'GeneID', 'Symbol', 'LocusTag', 'Synonyms',
                   'dbXrefs', 'chromosome', 'map_location', 'description',
                   'type_of_gene', 'Symbol_from_nomenclature_authority',
                   'Full_name_from_nomenclature_authority', 'Nomenclature_status',
                   'Other_designations', 'Modification_date'))
    
    geneInfo = geneInfo[,c('Symbol','Synonyms','tax_id'),with=F]
    
    #tax = unique(geneInfo$tax_id)
    species=fread('data/species.txt', sep = '|')
    tax = unlist(species[,4,with=F])
    # file generation
    for (i in tax){
        teval(paste0('syno',i," <<- deNames[geneInfo[,'tax_id']==i]"))
        teval(paste0('save(syno', i, ', file = "data/syno',i,'.rda")'))
        teval(paste0('rm(syno',i,',envir = .GlobalEnv)'))
    }
    
    system(paste0('rm data','/gene_info'))
    

    
}

teval = function(daString){
    eval(parse(text=daString))
}

