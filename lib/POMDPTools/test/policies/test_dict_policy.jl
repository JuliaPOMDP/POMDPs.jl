let
    gw = SimpleGridWorld()
    p = ValueDictPolicy(gw)
    
    s = GWPos(8,8)
    a = :down
    r = reward(gw,s,a)

    p.value_dict[(s,a)] = r
    @test action(p,s) == :down
    
    actions_dict = POMDPTools.Policies.valuemap(p,s)
    @test actions_dict[:up] == -Inf
    @test actions_dict[:down] == 3.0
    @test actions_dict[:left] == -Inf
    @test actions_dict[:right] == -Inf

    #test defalut_value
    p2 = ValueDictPolicy(gw, default_value=-3.0)
    p2.value_dict[(s,a)] = r
    @test action(p,s) == :down

    actions_dict2 = POMDPTools.Policies.valuemap(p2,s)
    @test actions_dict2[:up] == -3.0
    @test actions_dict2[:down] == 3.0
    @test actions_dict2[:left] == -3.0
    @test actions_dict2[:right] == -3.0

    # test default policy
    p3 = ValueDictPolicy(gw, default_policy=FunctionPolicy(s->:left))
    @test action(p3, s) == :left
end
