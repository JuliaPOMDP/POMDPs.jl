let
    d = SparseCat([:a, :b, :d], [0.4, 0.5, 0.1])
    c = collect(weighted_iterator(d))
    @test c == [:a=>0.4, :b=>0.5, :d=>0.1]
    @test pdf(d, :c) == 0.0
    @test pdf(d, :a) == 0.4
    @test mode(d) == :b
    @test Random.gentype(d) == Symbol
    @test Random.gentype(typeof(d)) == Symbol
    @inferred rand(Random.default_rng(), d)

    dt = SparseCat((:a, :b, :d), (0.4, 0.5, 0.1))
    c = collect(weighted_iterator(dt))
    @test c == [:a=>0.4, :b=>0.5, :d=>0.1]
    @test pdf(dt, :c) == 0.0
    @test pdf(dt, :a) == 0.4
    @test mode(dt) == :b
    @test Random.gentype(dt) == Symbol
    @test Random.gentype(typeof(dt)) == Symbol
    @inferred rand(Random.default_rng(), dt)
    
    # rand(::SparseCat)
    samples = Symbol[]
    N = 100_000
    for i in 1:N
        push!(samples, rand(d))
    end
    @test isapprox(count(samples.==:a)/N, pdf(d,:a), atol=0.005)
    @test isapprox(count(samples.==:b)/N, pdf(d,:b), atol=0.005)
    @test isapprox(count(samples.==:c)/N, pdf(d,:c), atol=0.005)
    @test isapprox(count(samples.==:d)/N, pdf(d,:d), atol=0.005)

    # rand(rng, ::SparseCat)
    rng = MersenneTwister(14)
    samples = Symbol[]
    N = 100_000
    @time for i in 1:N
        push!(samples, rand(rng, d))
    end
    @test isapprox(count(samples.==:a)/N, pdf(d,:a), atol=0.005)
    @test isapprox(count(samples.==:b)/N, pdf(d,:b), atol=0.005)
    @test isapprox(count(samples.==:c)/N, pdf(d,:c), atol=0.005)
    @test isapprox(count(samples.==:d)/N, pdf(d,:d), atol=0.005)

    # rand(::SparseCat, ::Integer)
    samples = rand(d, N)
    @test isapprox(count(samples.==:a)/N, pdf(d,:a), atol=0.005)
    @test isapprox(count(samples.==:b)/N, pdf(d,:b), atol=0.005)
    @test isapprox(count(samples.==:c)/N, pdf(d,:c), atol=0.005)
    @test isapprox(count(samples.==:d)/N, pdf(d,:d), atol=0.005)

    @test_throws ErrorException rand(Random.default_rng(), SparseCat([1], [0.0]))

    @test sprint((io,d)->show(io,MIME("text/plain"),d), d) == sprint((io,d)->showdistribution(io,d,title="SparseCat distribution"), d)

    @testset "#35" begin
        p = []
        push!(p, 1.0)
        d = SparseCat(["something"], p)
        @test rand(d) == "something"
        @test pdf(d, "something") == 1.0
        @test pdf(d, "something else") == 0.0
    end

    @testset "reverse" begin
        @test_throws MethodError SparseCat([1], ["something"])
    end
end
