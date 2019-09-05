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
Get the name of a DBNVar.
"""
name(::DBNVar{n}) where n = n
name(::Type{DBNVar{n}}) where n = n

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

struct DBNStructure{N<:NamedTuple, D<:NamedTuple}
    nodes::N
    deps::D # values are tuples of DBNVars
end

node(d::DBNStructure, name::Symbol) = d.nodes[name]
depvars(d::DBNStructure, name::Symbol) = d.deps[name]
depnames(d::DBNStructure, n::Symbol) = map(name, depvars(d, n))
nodenames(d::DBNStructure) = keys(d.nodes)
depstype(DBN::Type{D}) where D <: DBNStructure = DBN.parameters[2]

function add_node(d::DBNStructure, n::DBNVar{name}, node, deps) where name
    @assert !haskey(d.nodes, name) "DBNStructure already has a node named :$name"
    return DBNStructure(merge(d.nodes, NamedTuple{tuple(name)}(tuple(node))),
                        merge(d.deps, NamedTuple{tuple(name)}(tuple(deps))))
end

function add_node(d::DBNStructure, n::Symbol, node, deps::NTuple{N,Symbol}) where N
    return add_node(d, DBNVar(n), node, map(DBNVar, deps))
end

"""
Create a list of name=>deps pairs sorted so that dependencies come before dependents.
"""
function sorted_deppairs end # this is implemented below

# standard DBNs
function mdp_dbn()
    DBNStructure((s = InputDBNNode(),
            a = InputDBNNode(),
            sp = DistributionDBNNode(transition),
            r = FunctionDBNNode(reward),
           ),
           (s = (),
            a = (),
            sp = map(DBNVar, (:s, :a)),
            r = map(DBNVar, (:s, :a, :sp)),
           )
          )
end

function pomdp_dbn()
    DBNStructure((s = InputDBNNode(),
            a = InputDBNNode(),
            sp = DistributionDBNNode(transition),
            o = DistributionDBNNode(observation),
            r = FunctionDBNNode(reward),
           ),
           (s = (),
            a = (),
            sp = map(DBNVar, (:s, :a)),
            o = map(DBNVar, (:s, :a, :sp)),
            r = map(DBNVar, (:s, :a, :sp, :o)),
           )
          )
end

"""
    DBNStructure(::Type{M}) where M <: Union{MDP, POMDP}

Trait of an MDP/POMDP type for describing the structure of the dynamic Baysian network.

# Example

    struct MyMDP <: MDP{Int, Int} end
    POMDPs.gen(::MyMDP, s, a, rng) = (sp=s+a+rand(rng, [1,2,3]), r=s^2)

    # make a new node, delta_s, that is deterministically equal to sp - s
    function POMDPs.DBNStructure(::Type{MyMDP})
        dbn = mdp_dbn()
        return add_node(dbn, :delta_s, FunctionDBNNode((m,s,sp)->sp-s), (:s, :sp))
    end

    gen(DBNOut(:delta_s), MyMDP(), 1, 1, Random.GLOBAL_RNG)
"""
function DBNStructure end

DBNStructure(::Type{M}) where M <: MDP = mdp_dbn()
DBNStructure(::Type{M}) where M <: POMDP = pomdp_dbn()

DBNStructure(m) = DBNStructure(typeof(m))

struct InputDBNNode end # this does nothing for now

"""
DBN node defined by a function that maps the model and values from the parent nodes to a distribution

# Example
    DistributionDBNNode((m, s, a)->POMDPModelTools.Deterministic(s+a))    
"""
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


"""
DBN node defined by a function that determinisitically maps the model and values from the parent nodes to a new value.

# Example
    FunctionDBNNode((m, s, a)->s+a)
"""
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

"""
DBN node that always takes a deterministic constant value.
"""
struct ConstantDBNNode{T}
    val::T
end

gen(n::ConstantDBNNode, args...) = n.val
implemented(g::typeof(gen), n::ConstantDBNNode, M, Deps, RNG) = true

"""
DBN node that can only have a generative model; `gen(::DBNVar{:x}, ...)` must be implemented for a node of this type.
"""
struct GenDBNNode end

gen(::GenDBNNode, args...) = error("No `gen(::DBNVar, ...)` method implemented for a GenDBNNode (see stack trace for name)")
implemented(g::typeof(gen), GenDBNNode, M, Deps, RNG) = false

function sorted_deppairs(dbn::Type{D}, symbols) where D <: DBNStructure
    depnames = Dict{Symbol, Vector{Symbol}}()
    NT = depstype(dbn)
    keys = fieldnames(NT)
    for i in 1:length(keys)
        depnames[keys[i]] = collect(map(name, NT.parameters[2].parameters[i].parameters))
    end
    return sorted_deppairs(depnames, symbols)
end

sorted_deppairs(dbn::Type{D}, symbol::Symbol) where D <: DBNStructure = sorted_deppairs(dbn, tuple(symbol))

function sorted_deppairs(depnames::Dict{Symbol, Vector{Symbol}}, symbols)
    dag = SimpleDiGraph(length(depnames))
    labels = Symbol[]
    nodemap = Dict{Symbol, Int}()
    for sym in symbols
        if !haskey(nodemap, sym)
            push!(labels, sym)
            nodemap[sym] = length(labels)
        end
        add_dep_edges!(dag, nodemap, labels, depnames, sym)
    end
    sortednodes = topological_sort_by_dfs(dag)
    sortednames = labels[filter(n -> n<=length(labels), sortednodes)]
    return [n=>depnames[n] for n in sortednames]
end 

function add_dep_edges!(dag, nodemap, labels, depnames, sym)
    for dep in depnames[sym]
        if !haskey(nodemap, dep)
            push!(labels, dep)
            nodemap[dep] = length(labels)
        end
        add_edge!(dag, nodemap[dep], nodemap[sym])
        add_dep_edges!(dag, nodemap, labels, depnames, dep)
    end
end
