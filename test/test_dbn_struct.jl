struct DBNA <: MDP{Int, Int} end
dbn = DBNStructure(DBNA())

@test all(v in Set((:s, :a, :r, :sp)) for v in nodenames(dbn))
ns = Set(nodenames(dbn))
@test all(v in ns for v in [:s, :a, :r, :sp])

struct DBNB <: POMDP{Int, Int, Int} end
dbn = DBNStructure(DBNB())

@test all(v in Set((:s, :a, :r, :sp, :o)) for v in nodenames(dbn))
ns = Set(nodenames(dbn))
@test all(v in ns for v in [:s, :a, :r, :sp, :o])

module InfoModule
    using POMDPs
    export add_infonode

    add_infonode(dbn) = add_node(dbn, DBNVar(:info), ConstantDBNNode(nothing), (:s, :a))
end

using Main.InfoModule
struct DBNC <: POMDP{Int, Int, Int} end
POMDPs.DBNStructure(::Type{DBNC}) = pomdp_dbn() |> add_infonode
@test gen(DBNVar(:info), DBNC(), 1, 1, Random.GLOBAL_RNG) == nothing
@test gen(DBNOut(:info), DBNC(), 1, 1, Random.GLOBAL_RNG) == nothing

# Example from DBNStructure docstring
struct MyMDP <: MDP{Int, Int} end
POMDPs.gen(::MyMDP, s, a, rng) = (sp=s+a+rand(rng, [1,2,3]), r=s^2)

# make a new node delta_s that is deterministically sp-s
function POMDPs.DBNStructure(::Type{MyMDP})
    mdp_dbn() |> dbn -> add_node(dbn,
                                 DBNVar(:delta_s),
                                 FunctionDBNNode((s,sp)->sp-s),
                                 (:s, :sp)
                                )
end

@show DBNStructure(MyMDP)

@test gen(DBNOut(:delta_s), MyMDP(), 1, 1, Random.GLOBAL_RNG) == 2
