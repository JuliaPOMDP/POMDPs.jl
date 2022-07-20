let
    m = SimpleGridWorld(rewards=Dict([3,1]=>10.0), tprob=1.0)
    u = evaluate(m, FunctionPolicy(x->:right))
    @test u([2,1]) == 9.5
    @test u([3,1]) == 10.0
    @test u([4,1]) == 0.0
    @test u([3,2]) == 0.0
end
