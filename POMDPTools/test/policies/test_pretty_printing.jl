let
    gw = SimpleGridWorld(size=(2,2))

    pvec = fill(:left, length(states(gw)))

    solver = VectorSolver(pvec)

    p = solve(solver, gw)

    # test default
    @test sprint(showpolicy, gw, p) == " [1, 1] -> :left\n [2, 1] -> :left\n [1, 2] -> :left\n [2, 2] -> :left\n [-1, -1] -> :left"

    # test with small display
    iob = IOBuffer()
    io = IOContext(iob, :limit=>true, :displaysize=>(7, 7))
    showpolicy(io, gw, p, pre="@ ")
    @test String(take!(iob)) == "@ [1, 1] -> :left\n@ [2, 1] -> :left\n@ [1, 2] -> :left\n@ …"

    # test very long policy with small display
    struct M <: MDP{Int, Int}
        n::Int
    end
    iob = IOBuffer()
    io = IOContext(iob, :limit=>true, :displaysize=>(7, 7))
    POMDPs.states(m::MDP) = 1:m.n
    POMDPs.actions(m::MDP) = 1:3
    m = M(1_000_000_000)
    showpolicy(io, m, RandomPolicy(m))
    # Below, the actual values could be different because of the RandomPolicy, but length should be the same
    @test length(String(take!(iob))) == length(" 1 -> 2\n 2 -> 1\n 3 -> 3\n …") 
end
