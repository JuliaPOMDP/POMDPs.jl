struct DDNA <: MDP{Int, Int} end
ddn = DDNStructure(DDNA)

@test all(v in Set((:s, :a, :r, :sp)) for v in nodenames(ddn))
ns = Set(nodenames(ddn))
@test all(v in ns for v in [:s, :a, :r, :sp])

struct DDNB <: POMDP{Int, Int, Int} end
ddn = DDNStructure(DDNB)

@test all(v in Set((:s, :a, :r, :sp, :o)) for v in nodenames(ddn))
ns = Set(nodenames(ddn))
@test all(v in ns for v in [:s, :a, :r, :sp, :o])

@test Set(nodenames(ddn)) == Set(nodenames(typeof(ddn)))

ddn = DDNStructure(DDNB)
@test node(ddn, :sp) == DistributionDDNNode(transition)
@test Set(depvars(ddn, :sp)) == Set((DDNNode(:s), DDNNode(:a)))
@test Set(depnames(ddn, :sp)) == Set((:s, :a))

module InfoModule
    using POMDPs
    export add_infonode

    add_infonode(ddn) = add_node(ddn, :info, ConstantDDNNode(nothing), (:s, :a))
end

using Main.InfoModule
struct DDNC <: POMDP{Int, Int, Int} end
POMDPs.DDNStructure(::Type{DDNC}) = pomdp_ddn() |> add_infonode
@test gen(DDNNode(:info), DDNC(), 1, 1, Random.GLOBAL_RNG) == nothing
@test gen(DDNOut(:info), DDNC(), 1, 1, Random.GLOBAL_RNG) == nothing

# Example from DDNStructure docstring
struct MyMDP <: MDP{Int, Int} end
POMDPs.gen(::MyMDP, s, a, rng) = (sp=s+a+rand(rng, [1,2,3]), r=s^2)

# make a new node delta_s that is deterministically sp-s
function POMDPs.DDNStructure(::Type{MyMDP})
    ddn = mdp_ddn() 
    return add_node(ddn, :delta_s, FunctionDDNNode((m,s,sp)->sp-s), (:s, :sp))
end

@test gen(DDNOut(:delta_s), MyMDP(), 1, 1, Random.GLOBAL_RNG) in [2, 3, 4]

struct DDND <: MDP{Int, Int} end
POMDPs.DDNStructure(::Type{DDND}) = add_node(mdp_ddn(), :x, GenericDDNNode(), (:s, :a))
@test_throws ErrorException gen(DDNNode(:x), DDND(), 1, 1, Random.GLOBAL_RNG)
POMDPs.gen(::DDNNode{:x}, ::DDND, s, a, rng) = s*a
@test gen(DDNOut(:x), DDND(), 1, 1, Random.GLOBAL_RNG) == 1
