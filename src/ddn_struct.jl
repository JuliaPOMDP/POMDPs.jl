"""
    DDNNode(x::Symbol)
    DDNNode{x::Symbol}()

Reference to a named node in the POMDP or MDP dynamic decision network (DDN).

Note that `gen(::DDNNode, m, depargs..., rng)` always takes an argument for each dependency whereas `gen(::DDNOut, m, s, a, rng)` only takes `s` and `a` arguments (the inputs to the entire DDN).

`DDNNode` is a "value type". See [the documentation of `Val`](https://docs.julialang.org/en/v1/manual/types/index.html#%22Value-types%22-1) for more conceptual details about value types.
"""
struct DDNNode{name} end

@pure DDNNode(name::Symbol) = DDNNode{name}()

"""
Get the name of a DDNNode.
"""
name(::DDNNode{n}) where n = n
name(::Type{DDNNode{n}}) where n = n

"""
    DDNOut(x::Symbol)
    DDNOut{x::Symbol}()
    DDNOut(::Symbol, ::Symbol,...)
    DDNOut{x::NTuple{N, Symbol}}()

Reference to one or more named nodes in the POMDP or MDP dynamic decision network (DDN).

Note that `gen(::DDNOut, m, s, a, rng)` always takes `s` and `a` arguments (the inputs to the entire DDN) while `gen(::DDNNode, m, depargs..., rng)` takes a variable number of arguments (one for each dependency).

`DDNOut` is a "value type". See [the documentation of `Val`](https://docs.julialang.org/en/v1/manual/types/index.html#%22Value-types%22-1) for more conceptual details about value types.
"""
struct DDNOut{names} end

@pure DDNOut(name::Symbol) = DDNOut{name}()
@pure DDNOut(names...) = DDNOut{names}()
@pure DDNOut(names::Tuple) = DDNOut{names}()

struct DDNStructure{N<:NamedTuple, D<:NamedTuple}
    "Node implementations."
    nodes::N
    "Dependency tree. NamedTuple full of Tuples of DDNNodes."
    deps::D
end

node(d::DDNStructure, name::Symbol) = d.nodes[name]
depvars(d::DDNStructure, name::Symbol) = d.deps[name]
depnames(d::DDNStructure, n::Symbol) = map(name, depvars(d, n))

nodenames(d::DDNStructure) = keys(d.nodes)
nodenames(DDN::Type{D}) where {D <: DDNStructure} = fieldnames(DDN.parameters[1])
outputnames(d::DDNStructure) = outputnames(typeof(d)) # XXX Port to 0.8
function outputnames(::Type{D}) where D <: DDNStructure
    tuple(Iterators.filter(sym->!(sym in (:s, :a)), nodenames(D))...)
end

function add_node(d::DDNStructure, n::DDNNode{name}, node, deps) where name
    @assert !haskey(d.nodes, name) "DDNStructure already has a node named :$name"
    return DDNStructure(merge(d.nodes, NamedTuple{tuple(name)}(tuple(node))),
                        merge(d.deps, NamedTuple{tuple(name)}(tuple(deps))))
end

function add_node(d::DDNStructure, n::Symbol, node, deps::NTuple{N,Symbol}) where N
    return add_node(d, DDNNode(n), node, map(DDNNode, deps))
end

depstype(DDN::Type{D}) where {D <: DDNStructure} = DDN.parameters[2]

"""
    sorted_deppairs(DDN::Type{D}, symbols) where D <: DDNStructure

Create a list of name=>deps pairs sorted so that dependencies come before dependents.

`symbols` is any iterable collection of `Symbol`s.
"""
function sorted_deppairs end # this is implemented below

"""
    DDNStructure(::Type{M}) where M <: Union{MDP, POMDP}

Trait of an MDP/POMDP type for describing the structure of the dynamic Baysian network.

# Example

    struct MyMDP <: MDP{Int, Int} end
    POMDPs.gen(::MyMDP, s, a, rng) = (sp=s+a+rand(rng, [1,2,3]), r=s^2)

    # make a new node, delta_s, that is deterministically equal to sp - s
    function POMDPs.DDNStructure(::Type{MyMDP})
        ddn = mdp_ddn()
        return add_node(ddn, :delta_s, FunctionDDNNode((m,s,sp)->sp-s), (:s, :sp))
    end

    gen(DDNOut(:delta_s), MyMDP(), 1, 1, Random.GLOBAL_RNG)
"""
function DDNStructure end

DDNStructure(::Type{M}) where M <: MDP = mdp_ddn()
DDNStructure(::Type{M}) where M <: POMDP = pomdp_ddn()

DDNStructure(m) = DDNStructure(typeof(m))

struct InputDDNNode end # this does nothing for now

"""
DDN node defined by a function that maps the model and values from the parent nodes to a distribution

# Example
    DistributionDDNNode((m, s, a)->POMDPModelTools.Deterministic(s+a))    
"""
struct DistributionDDNNode{F}
    dist_func::F
end

@generated function gen(n::DistributionDDNNode, m, args...)
    # apparently needs to be @generated for type stability
    argexpr = (:(args[$i]) for i in 1:length(args)-1)
    quote
        rand(last(args), n.dist_func(m, $(argexpr...)))
    end
end

function implemented(g::typeof(gen), n::DistributionDDNNode, M, Deps, RNG)
    return implemented(n.dist_func, Tuple{M, Deps.parameters...})
end


"""
DDN node defined by a function that determinisitically maps the model and values from the parent nodes to a new value.

# Example
    FunctionDDNNode((m, s, a)->s+a)
"""
struct FunctionDDNNode{F}
    f::F
end

@generated function gen(n::FunctionDDNNode, m, args...)
    # apparently this needs to be @generated for type stability
    argexpr = (:(args[$i]) for i in 1:length(args)-1)
    quote
        n.f(m, $(argexpr...))
    end
end

function implemented(g::typeof(gen), n::FunctionDDNNode, M, Deps, RNG)
    return implemented(n.f, Tuple{M, Deps.parameters...})
end

"""
DDN node that always takes a deterministic constant value.
"""
struct ConstantDDNNode{T}
    val::T
end

gen(n::ConstantDDNNode, args...) = n.val
implemented(g::typeof(gen), n::ConstantDDNNode, M, Deps, RNG) = true

"""
DDN node that can only have a generative model; `gen(::DDNNode{:x}, ...)` must be implemented for a node of this type.
"""
struct GenericDDNNode end

gen(::GenericDDNNode, args...) = error("No `gen(::DDNNode, ...)` method implemented for a GenericDDNNode (see stack trace for name)")
implemented(g::typeof(gen), GenericDDNNode, M, Deps, RNG) = false

# standard DDNs
function mdp_ddn()
    DDNStructure((s = InputDDNNode(),
            a = InputDDNNode(),
            sp = DistributionDDNNode(transition),
            r = FunctionDDNNode(reward),
           ),
           (s = (),
            a = (),
            sp = map(DDNNode, (:s, :a)),
            r = map(DDNNode, (:s, :a, :sp)),
           )
          )
end

function pomdp_ddn()
    DDNStructure((s = InputDDNNode(),
            a = InputDDNNode(),
            sp = DistributionDDNNode(transition),
            o = DistributionDDNNode(observation),
            r = FunctionDDNNode(reward),
           ),
           (s = (),
            a = (),
            sp = map(DDNNode, (:s, :a)),
            o = map(DDNNode, (:s, :a, :sp)),
            r = map(DDNNode, (:s, :a, :sp, :o)),
           )
          )
end

function sorted_deppairs(ddn::Type{D}, symbols) where D <: DDNStructure
    depnames = Dict{Symbol, Vector{Symbol}}()
    NT = depstype(ddn)
    for key in fieldnames(NT)
        depnames[key] = collect(map(name, fieldtype(NT, key).parameters))
    end
    return sorted_deppairs(depnames, symbols)
end

sorted_deppairs(ddn::Type{D}, symbol::Symbol) where D <: DDNStructure = sorted_deppairs(ddn, tuple(symbol))

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
