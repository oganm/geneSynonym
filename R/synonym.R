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
#' @param taxid
#' @param no of cores to use when multiprocessing. Useful for large gene lists
#' @export
geneSynonym = function(genes,tax,cores = 1){
    # I kept the single core sapply version in case installing parallel is a
    # problem somewhere.
    # if a gene name given and it is not on the list, it spews out a warning 
    # DOES NOT PRINT WARNINGS WHEN USING MULTIPLE CORES
    # teval(paste0('data(syno',tax,')'))
    leData = teval(paste0('syno',tax))
    
    geneSearcher = function(x){
        synonyms = strsplit(grep(paste0('(^|[|])',x,'($|[|])'),leData,value=T),split='[|]')
        if (length(synonyms)==0){
            synonyms = x
            warning(paste0('Gene ',x,' could not be found in the list. Returning own name'))
        }
        return(synonyms)
    }
    
    if (cores == 1){
        synos = sapply(genes,geneSearcher)
        return(synos)
    } else {
        # so that I wont fry my laptop
        if (detectCores()<cores){ 
            cores = detectCores()
            print('max cores exceeded')
            print(paste('set core no to',cores))
        }
        options(warn=1)
        synos = simplify2array(
            mclapply(genes, geneSearcher, mc.cores = cores)
        )
        names(synos) = genes
        return(synos)
    }
}
