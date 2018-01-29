context('basic functionality check')


test_that('synonymCheck',{
    expect_equal(humanSyno('TMSB10') %>% class,'list')
    expect_warning(humanSyno('TADSADSDA'),"Returning own name")
    expect_silent(humanSyno('TMSB10'))
    
    expect_equal(mouseSyno("Eno2") %>% class, 'list')
})