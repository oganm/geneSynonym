context('basic functionality check')


test_that('synonymCheck',{
    expect_equal(humanSyno('TMSB10') %>% class,'list')
    expect_warning(humanSyno('TADSADSDA'),"Returning own name")
    expect_silent(humanSyno('TMSB10'))
    
    expect_equal(mouseSyno("Eno2") %>% class, 'list')
    
    expect_warning(humanSyno('TMSB10',cores = 9999999999),".")
    
    expect_equal(mouseSyno("Eno2"),mouseSyno("Eno2",cores = 2))
})