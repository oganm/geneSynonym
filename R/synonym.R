teval = function(string,...){
    eval(parse(text=string),...)
}



#' Mouse wraper for \code{\link{geneSynonym}}
#' @param genes character vector of genes
#' @examples
#' mouseSyno(c('Eno2','Mog'))
#' mouseSyno(c('Eno2',17441))
#' 
#' @export
mouseSyno = function(genes, caseSensitive = TRUE){
    geneSynonym(genes,10090,caseSensitive = caseSensitive)
}

#' Human wraper for \code{\link{geneSynonym}}
#' @param genes character vector of genes
#' @examples 
#' humanSyno(c('MOG','ENO2'))
#' humanSyno(c('MOG',2026))
#' 
#' @export
humanSyno = function(genes, caseSensitive = TRUE){
    geneSynonym(genes,9606,caseSensitive)
}


#' Get synonyms of given genes
#' @description Given a list of genes and taxid, returns a data frame with corresponding synonyms to said genes. For mouse and humans just use humanSyno and mouseSyno
#' @param genes character vector of genes
#' @param tax Species taxonomy ID
#' @examples
#' geneSynonym(c('Eno2','Mog'), tax = 10090)
#' geneSynonym(c('Eno2',17441), tax = 10090)
#' geneSynonym(c('MOG','ENO2'), tax = 9606)
#' @export
geneSynonym = function(genes,tax, caseSensitive = TRUE){
    
    if(caseSensitive){
        maybeLower = function(x){x}
    }else{
        maybeLower = function(x){tolower(x)}
    }
    synoData = tryCatch({teval(paste0('geneSynonym::syno',tax))},
                        error = function(e){
                            stop(tax,' is not a valid taxonomic identifier')
                        })
    
    geneSearcher = function(x){
        
        synonyms = strsplit(synoData[grepl(paste0('(^|[|])','\\Q',
                                                  maybeLower(x),
                                                  '\\E','($|[|])'),
                                           maybeLower(synoData)) | 
                                         (names(synoData) %in% x)],split = '[|]')
        if (length(synonyms)==0){
            synonyms = list(x)
            warning(paste0('Gene ',x,' could not be found in the list. Returning own name'))
        }
        return(synonyms)
    }
    
    # 25 comes from testing. Filtering for possible results saves lots of time 
    # but only if input length > 25
    if(length(genes)>25){
        synoData2 = teval(paste0('geneSynonym::syno',tax)) %>% strsplit('[|]')
        synoData = synoData[synoData2 %>% unlist %>% {maybeLower(.) %in% maybeLower(genes)} %>% 
                                utils::relist(synoData2) %>% sapply(any) %>%
                                {. | names(synoData2) %in% genes}] # this line ads the ncbi ids to the search space
    }
    
    synos = lapply(genes,geneSearcher)
    names(synos) = genes
    return(synos)
}
