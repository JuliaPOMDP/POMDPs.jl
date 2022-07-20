let
    pomdp = BabyPOMDP()

    bu = DiscreteUpdater(pomdp)
    b0 = initialize_belief(bu, initialstate_distribution(pomdp))

    # these values were gotten from FIB.jl
    # alphas = [-29.4557 -36.5093; -19.4557 -16.0629]
    alphas = [ -16.0629 -19.4557; -36.5093 -29.4557]
    policy = AlphaVectorPolicy(pomdp, alphas, ordered_actions(pomdp))

    @test Set(alphapairs(policy)) == Set([[-16.0629, -36.5093]=>false, [-19.4557, -29.4557]=>true])
    @test Set(alphavectors(policy)) == Set([[-16.0629, -36.5093], [-19.4557, -29.4557]])

    # initial belief is 100% confidence in baby not being hungry
    @test isapprox(value(policy, b0), -16.0629)
    @test isapprox(value(policy, [1.0,0.0]), -16.0629)
    @test isapprox(actionvalues(policy, b0), [-16.0629, -19.4557])
    @test length(actionvalues(policy, b0)) == length(actions(pomdp))
   
    # because baby isn't hungry, policy should not feed (return false)
    @test action(policy, b0) == false

    # SparseCat belief
    sparse_b0 = SparseCat([s for s in ordered_states(pomdp) if pdf(b0, s) != 0.],
                        b0.b[b0.b .> 0.])
    @test isapprox(value(policy, sparse_b0), -16.0629)
    @test isapprox(actionvalues(policy, sparse_b0), [-16.0629, -19.4557])
    @test action(policy, sparse_b0) == false

    # Bool_distribution (if it works for this, it should work for an arbitrary distribution)
    bd = initialstate_distribution(pomdp)::BoolDistribution
    @test action(policy, bd) == false 
     
    # try pushing new vector
    push!(policy, [0.0,0.0], true)

    @test value(policy, b0) == 0.0
    @test action(policy, b0) == true

    # JuliaPOMDP/SARSOP.jl#39
    policy = AlphaVectorPolicy(pomdp, alphas, convert(BitArray, ordered_actions(pomdp)))
    policy = AlphaVectorPolicy(pomdp, collect(alphas[:, i] for i in 1:size(alphas, 2)), convert(BitArray, ordered_actions(pomdp)))
end
