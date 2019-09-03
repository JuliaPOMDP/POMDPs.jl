"""
    DBNVar(x::Symbol)
    DBNVar{x::Symbol}()

Reference to a named node in the POMDP or MDP dynamic Bayesian network (DBN).

Note that `gen(::DBNVar, m, depargs..., rng)` always takes an argument for each dependency, `gen(::DBNOut, m, s, a, rng)` only takes `s` and `a` arguments (the inputs to the entire DBN).

`DBNVar` is a "value type". See the documentation of `Val` for more conceptual details about value types.
"""
struct DBNVar{name} end

DBNVar(name::Symbol) = DBNVar{name}()

"""
    DBNOut(x::Symbol)
    DBNOut{x::Symbol}()
    DBNOut(::Symbol, ::Symbol,...)
    DBNOut{x::NTuple{N, Symbol}}()

Reference to one or more named nodes in the POMDP or MDP dynamic Bayesian network (DBN).

Note that `gen(::DBNOut, m, s, a, rng)` always takes `s` and `a` arguments (the inputs to the entire DBN) while `gen(::DBNVar, m, depargs..., rng)` takes a variable number of arguments (one for each dependency).

`DBNOut` is a "value type". See the documentation of `Val` for more conceptual details about value types.
"""
struct DBNOut{names} end

DBNOut(name::Symbol) = DBNOut{name}()
DBNOut(names...) = DBNOut{names}()

struct DBNDef{N<:NamedTuple}
    nodes::N
    deps::NamedTuple # this could be a parameter in the future
end

# todo DBNDef structure

node(d::DBNDef, name::Symbol) = d.nodes[name]
deps(d::DBNDef, name::Symbol) = d.deps[name]
nodenames(d::DBNDef) = keys(d.nodes)
@generated function add_node(d::DBNDef, n::DBNVar{name}, node, deps) where name
    quote 
        @assert !haskey(d.nodes, name) "DBNDef already has a node named :$name"
        DBNDef(merge(d.nodes, ($name=node,)), merge(d.deps, ($name=deps,)))
    end
end

function mdp_dbn()
    DBNDef((s = InputDBNNode(),
            a = InputDBNNode(),
            sp = DistributionDBNNode(transition),
            r = FunctionDBNNode(reward),
           ),
           (s = (),
            a = (),
            sp = (:s, :a),
            r = (:s, :a, :sp),
           )
          )
end

function pomdp_dbn()
    DBNDef((s = InputDBNNode(),
            a = InputDBNNode(),
            sp = DistributionDBNNode(transition),
            o = DistributionDBNNode(observation),
            r = FunctionDBNNode(reward),
           ),
           (s = (),
            a = (),
            sp = (:s, :a),
            o = (:s, :a, :sp),
            r = (:s, :a, :sp, :o),
           )
          )
end

"""
    DBNStructure(::Type{M}) where M <: Union{MDP, POMDP}

Trait of an MDP/POMDP type for describing the structure of the dynamic Baysian network.

# Example

    struct MyPOMDP <: MDP{Int, Int} end
    POMDPs.gen(::MyPOMDP, s, a, rng) = (sp=s+a+rand(rng, [1,2,3]), r=s^2)

    # make a new node delta_s that is deterministically sp-s
    POMDPs.DBNStructure(::Type{MyPOMDP}) = add_node(mdp_dbn(),
                                                    DVNVar(:delta_s),
                                                    FunctionDBNNode((s,sp)->sp-s),
                                                    (:s, :sp))
    gen(DBNOut(:delta_s), MyPOMDP(), 1, 1, Random.GLOBAL_RNG)
"""
function DBNStructure end

DBNStructure(::Type{M}) where M <: MDP = mdp_dbn()
DBNStructure(::Type{M}) where M <: POMDP = pomdp_dbn()

DBNStructure(m) = DBNStructure(typeof(m))

struct InputDBNNode end # this does nothing for now

struct DistributionDBNNode{F}
    dist_func::F
end

@generated function gen(n::DistributionDBNNode, m, args...)
    # apparently needs to be @generated for type stability
    argexpr = (:(args[$i]) for i in 1:length(args)-1)
    quote
        rand(last(args), n.dist_func(m, $(argexpr...)))
    end
end

function implemented(g::typeof(gen), n::DistributionDBNNode, M, Deps, RNG)
    return implemented(n.dist_func, Tuple{M, Deps.parameters...})
end

struct FunctionDBNNode{F}
    f::F
end

@generated function gen(n::FunctionDBNNode, m, args...)
    # apparently this needs to be @generated for type stability
    argexpr = (:(args[$i]) for i in 1:length(args)-1)
    quote
        n.f(m, $(argexpr...))
    end
end

function implemented(g::typeof(gen), n::FunctionDBNNode, M, Deps, RNG)
    return implemented(n.f, Tuple{M, Deps.parameters...})
end

struct ConstantDBNNode{T}
    val::T
end

gen(n::ConstantDBNNode, args...) = n.val
implemented(g::typeof(gen), n::ConstantDBNNode, M, Deps, RNG) = true

"""
Create a list of node names sorted so that dependencies come before dependents.
"""
function sorted_nodenames(dbn::DBNDef, symbols)
    dag = SimpleDiGraph(length(dbn.nodes))
    labels = Symbol[]
    nodemap = Dict{Symbol, Int}()
    for sym in symbols
        if !haskey(nodemap, sym)
            push!(labels, sym)
            nodemap[sym] = length(labels)
        end
        add_dep_edges!(dag, nodemap, labels, dbn, sym)
    end
    sortednodes = topological_sort_by_dfs(dag)
    return labels[filter(n -> n<=length(labels), sortednodes)]
end 

sorted_nodenames(dbn::DBNDef, symbol::Symbol) = sorted_nodenames(dbn, tuple(symbol))

function add_dep_edges!(dag, nodemap, labels, dbn, sym)
    deps = dbn.deps[sym]
    for dep in deps
        if !haskey(nodemap, dep)
            push!(labels, dep)
            nodemap[dep] = length(labels)
        end
        add_edge!(dag, nodemap[dep], nodemap[sym])
        add_dep_edges!(dag, nodemap, labels, dbn, dep)
    end
end
