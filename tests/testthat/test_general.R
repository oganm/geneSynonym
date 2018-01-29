context('basic functionality check')


test_that('synonymCheck',{
    expect_is(humanSyno('TMSB10'),'list')
    
    expect_warning(humanSyno('TADSADSDA'),"Returning own name")
    expect_silent(humanSyno('TMSB10'))
    
    expect_equal(mouseSyno("Eno2") %>% class, 'list')
    
    # long inputs
    mouseSymbols = syno10090 %>% strsplit('[|]') %>% sapply(function(x){x[[1]]})
    
    expect_silent(mouseSyno(mouseSymbols[1:50]))
    expect_is(mouseSyno(mouseSymbols[1:50]),'list')
})