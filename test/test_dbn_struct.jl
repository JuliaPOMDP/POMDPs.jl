struct DDNA <: MDP{Int, Int} end
dbn = DDNStructure(DDNA)

@test all(v in Set((:s, :a, :r, :sp)) for v in nodenames(dbn))
ns = Set(nodenames(dbn))
@test all(v in ns for v in [:s, :a, :r, :sp])

struct DDNB <: POMDP{Int, Int, Int} end
dbn = DDNStructure(DDNB)

@test all(v in Set((:s, :a, :r, :sp, :o)) for v in nodenames(dbn))
ns = Set(nodenames(dbn))
@test all(v in ns for v in [:s, :a, :r, :sp, :o])

dbn = DDNStructure(DDNB)
@test node(dbn, :sp) == DistributionDDNNode(transition)
@test Set(depvars(dbn, :sp)) == Set((DDNNode(:s), DDNNode(:a)))
@test Set(depnames(dbn, :sp)) == Set((:s, :a))

module InfoModule
    using POMDPs
    export add_infonode

    add_infonode(dbn) = add_node(dbn, :info, ConstantDDNNode(nothing), (:s, :a))
end

using Main.InfoModule
struct DDNC <: POMDP{Int, Int, Int} end
POMDPs.DDNStructure(::Type{DDNC}) = pomdp_dbn() |> add_infonode
@test gen(DDNNode(:info), DDNC(), 1, 1, Random.GLOBAL_RNG) == nothing
@test gen(DDNOut(:info), DDNC(), 1, 1, Random.GLOBAL_RNG) == nothing

# Example from DDNStructure docstring
struct MyMDP <: MDP{Int, Int} end
POMDPs.gen(::MyMDP, s, a, rng) = (sp=s+a+rand(rng, [1,2,3]), r=s^2)

# make a new node delta_s that is deterministically sp-s
function POMDPs.DDNStructure(::Type{MyMDP})
    dbn = mdp_dbn() 
    return add_node(dbn, :delta_s, FunctionDDNNode((m,s,sp)->sp-s), (:s, :sp))
end

@test gen(DDNOut(:delta_s), MyMDP(), 1, 1, Random.GLOBAL_RNG) in [2, 3, 4]

struct DDND <: MDP{Int, Int} end
POMDPs.DDNStructure(::Type{DDND}) = add_node(mdp_dbn(), :x, GenDDNNode(), (:s, :a))
@test_throws ErrorException gen(DDNNode(:x), DDND(), 1, 1, Random.GLOBAL_RNG)
POMDPs.gen(::DDNNode{:x}, ::DDND, s, a, rng) = s*a
@test gen(DDNOut(:x), DDND(), 1, 1, Random.GLOBAL_RNG) == 1
