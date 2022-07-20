let
    gw = LegacyGridWorld(sx=2, sy=2, rs=[GridWorldState(1,1)], rv=[10.0])

    pvec = fill(GridWorldAction(:left), 5)

    solver = VectorSolver(pvec)

    p = solve(solver, gw)

    io = IOBuffer()
    d = TextDisplay(io)
    display(d, p)
    @test length(split(String(take!(io)), '\n')) == 6

    for s1 in states(gw)
        @test action(p, s1) == GridWorldAction(:left)
    end

    p2 = VectorPolicy(gw, pvec)
    for s2 in states(gw)
        @test action(p2, s2) == GridWorldAction(:left)
    end

    p3 = ValuePolicy(gw)
    for s2 in states(gw)
        @inferred(action(p3, s2)) isa GridWorldAction
    end

    io = IOBuffer()
    d = TextDisplay(io)
    display(d, p3)
    @test length(split(String(take!(io)), '\n')) == 6
end
