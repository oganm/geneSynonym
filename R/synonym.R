teval = function(daString){
    eval(parse(text=daString))
}



#' Mouse wraper 
#' @export
mouseSyno = function(genes,cores=1){
    geneSynonym(genes,10090,cores)
}

#' Human wraper for geneSynonym
#' @export
humanSyno = function(genes,cores=1){
    geneSynonym(genes,9606,cores)
}


#' Get synonyms of given genes
#' @description Given a list of genes and taxid, returns a data frame with corresponding synonyms to said genes. For mouse and humans just use humanSyno and mouseSyno
#' @param A list of genes
#' @param tax Species taxonomy ID
#' @param cores of cores to use when multiprocessing. Useful for large gene lists
#' @export
geneSynonym = function(genes,tax,cores = 1){
    # I kept the single core sapply version in case installing parallel is a
    # problem somewhere.
    # if a gene name given and it is not on the list, it spews out a warning 
    # DOES NOT PRINT WARNINGS WHEN USING MULTIPLE CORES
    # teval(paste0('data(syno',tax,')'))
    leData = teval(paste0('syno',tax))
    
    geneSearcher = function(x){
        synonyms = strsplit(grep(paste0('(^|[|])','\\Q',x,'\\E','($|[|])'),leData,value=T),split='[|]')
        if (length(synonyms)==0){
            synonyms = list(x)
            warning(paste0('Gene ',x,' could not be found in the list. Returning own name'))
        }
        return(synonyms)
    }
    
    if (cores == 1){
        synos = lapply(genes,geneSearcher)
        names(synos) = genes
        return(synos)
    } else {
        # so that I wont fry my laptop
        if(!is.null(parallel::detectCores)){
            if (parallel::detectCores()<cores){ 
                cores = parallel::detectCores()
                warning(paste0('max cores exceeded\nset core no no ',cores))
            }
        } else{
            warning('Could not detect number of cores. It\'s probably fine.')
        }
        options(warn=1)
        synos = parallel::mclapply(genes, geneSearcher, mc.cores = cores)
        names(synos) = genes
        return(synos)
    }
}
