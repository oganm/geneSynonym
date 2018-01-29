teval = function(string){
    eval(parse(text=string))
}



#' Mouse wraper for \code{\link{geneSynonym}}
#' @param genes character vector of genes
#' @param cores number of cores to use when multiprocessing. Useful for large gene lists
#' @examples
#' mouseSyno(c('Eno2','Mog'), tax = 10090)
#' mouseSyno(c('Eno2',17441), tax = 10090)
#' 
#' @export
mouseSyno = function(genes,cores=1){
    geneSynonym(genes,10090,cores)
}

#' Human wraper for \code{\link{geneSynonym}}
#' @param genes character vector of genes
#' @param cores number of cores to use when multiprocessing. Useful for large gene lists
#' @examples 
#' geneSynonym(c('MOG','ENO2'), tax = 9606)
#' geneSynonym(c('MOG',2026), tax = 9606)
#' 
#' @export
humanSyno = function(genes,cores=1){
    geneSynonym(genes,9606,cores)
}


#' Get synonyms of given genes
#' @description Given a list of genes and taxid, returns a data frame with corresponding synonyms to said genes. For mouse and humans just use humanSyno and mouseSyno
#' @param genes character vector of genes
#' @param tax Species taxonomy ID
#' @param cores number of cores to use when multiprocessing. Useful for large gene lists
#' @examples
#' geneSynonym(c('Eno2','Mog'), tax = 10090)
#' geneSynonym(c('Eno2',17441), tax = 10090)
#' geneSynonym(c('MOG','ENO2'), tax = 9606)
#' @export
geneSynonym = function(genes,tax,cores = 1){
    # I kept the single core sapply version in case installing parallel is a
    # problem somewhere.
    # if a gene name given and it is not on the list, it spews out a warning 
    # DOES NOT PRINT WARNINGS WHEN USING MULTIPLE CORES
    # teval(paste0('data(syno',tax,')'))
    synoData = teval(paste0('syno',tax))
    
    geneSearcher = function(x){
        
        synonyms = strsplit(synoData[grepl(paste0('(^|[|])','\\Q',x,'\\E','($|[|])'),synoData) | (names(synoData ) %in% x)],split = '[|]')
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
