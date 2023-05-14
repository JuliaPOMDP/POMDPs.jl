let
    gw = SimpleGridWorld()

    p = DictPolicy(gw)
    
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
end
