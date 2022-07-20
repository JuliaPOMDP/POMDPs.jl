d = Uniform([1])

@test rand(d) == 1
@test rand(MersenneTwister(4), d) == 1
@test collect(support(d)) == [1]
@test Random.gentype(d) == typeof(1)
@test Random.gentype(typeof(d)) == typeof(1)
@test pdf(d, 0) == 0.0
@test pdf(d, 1) == 1.0
@test mode(d) == 1
@test mean(d) == 1
@test typeof(mean(d)) == typeof(mean([1]))
@test collect(weighted_iterator(d)) == [1=>1.0]

@test sprint((io,d)->show(io,MIME("text/plain"),d), d) == sprint((io,d)->showdistribution(io,d,title="Uniform distribution"), d)

d2 = Uniform((:symbol,))
@test rand(d2) == :symbol
@test rand(MersenneTwister(4), d2) == :symbol
@test collect(support(d2)) == [:symbol]
@test Random.gentype(d2) == typeof(:symbol)
@test Random.gentype(typeof(d2)) == typeof(:symbol)
@test pdf(d2, :another) == 0.0
@test pdf(d2, :symbol) == 1.0
@test mode(d2) == :symbol
@test collect(weighted_iterator(d2)) == [:symbol=>1.0]

# uniqueness test
@test_throws ErrorException Uniform((:symbol, :symbol))



d3 = UnsafeUniform([1])

@test rand(d3) == 1
@test rand(MersenneTwister(4), d3) == 1
@test collect(support(d3)) == [1]
@test Random.gentype(d3) == typeof(1)
@test Random.gentype(typeof(d3)) == typeof(1)
@test pdf(d3, 1) == 1.0
@test mean(d3) == 1
@test mode(d3) == 1
@test typeof(mean(d3)) == typeof(mean([1]))
@test collect(weighted_iterator(d3)) == [1=>1.0]

@test sprint((io,d3)->show(io,MIME("text/plain"),d3), d3) == sprint((io,d3)->showdistribution(io,d3,title="UnsafeUniform distribution"), d3)

d4 = UnsafeUniform((:symbol,))
@test rand(d4) == :symbol
@test rand(MersenneTwister(4), d4) == :symbol
@test collect(support(d4)) == [:symbol]
@test Random.gentype(d4) == typeof(:symbol)
@test Random.gentype(typeof(d4)) == typeof(:symbol)
# @test pdf(d4, :another) == 0.0 # this will not work
@test pdf(d4, :symbol) == 1.0
@test mode(d4) == :symbol
@test collect(weighted_iterator(d4)) == [:symbol=>1.0]
