let
    dist = Categorical([0.4, 0.5, 0.1])
    c = collect(weighted_iterator(dist))
    @test c == [1=>0.4, 2=>0.5, 3=>0.1]
end
