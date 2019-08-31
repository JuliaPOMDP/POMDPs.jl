list_genvars()

@test all(v in Set((:s, :a, :r, :sp, :o)) for v in genvars())
gvs = Set(genvars())
@test all(v in gvs for v in [:s, :a, :r, :sp, :o])

for v in genvars()
    @test genvar_data(v) == POMDPs.genvar_registry[v]
end

module InfoModule
    using POMDPs

    idata = POMDPs.GenVarData(POMDPs, "info",
                            "additional diagnostic information produced by the model not included in the state or observation",
                            M->[],
                            M->Any,
                            POMDPs.Fallback(nothing)
                           )
    add_genvar(:i, idata)
end

struct ITestMDP <: MDP{Int, Int} end
@test gen(Return(:i), ITestMDP(), 1, 1, Random.GLOBAL_RNG) == nothing
