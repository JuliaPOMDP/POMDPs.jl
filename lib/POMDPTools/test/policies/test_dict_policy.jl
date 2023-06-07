let
    
    gw = SimpleGridWorld()
    p = ValueDictPolicy(gw)
    
    s = GWPos(8,8)
    a = :down
    r = reward(gw,s,a)

    p.value_dict[(s,a)] = r
    @test action(p,s) == :down
    
    actions_dict = actionvalues(p,s)
    @test actions_dict[:up] == 0.0
    @test actions_dict[:down] == 3.0
    @test actions_dict[:left] == 0.0
    @test actions_dict[:right] == 0.0

    #test defalut_value
    p2 = ValueDictPolicy(gw,-Inf)
    p2.value_dict[(s,a)] = r
    @test action(p,s) == :down

    actions_dict2 = actionvalues(p2,s)
    @test actions_dict2[:up] == -Inf
    @test actions_dict2[:down] == 3.0
    @test actions_dict2[:left] == -Inf
    @test actions_dict2[:right] == -Inf
end
