struct DBNVar{name} end
struct DBNTuple{names} end

DBNVar(name::Symbol) = DBNVar{name}()
DBNTuple(names...) = DBNTuple{names}()

struct DBNDef{N<:NamedTuple}
    nodes::N
    deps::NamedTuple
end

function DBNStructure(::Type{M}) where M <: MDP
    DBNDef((s = nothing,
            a = nothing,
            sp = DistributionDBNNode(transition),
            r = FunctionDBNNode(reward)
           ),
           (s = (),
            a = (),
            sp = (:s, :a),
            r = (:s, :a, :sp)
           )
          )
end

function DBNStructure(::Type{M}) where M <: POMDP
    DBNDef((s = nothing,
            a = nothing,
            sp = DistributionDBNNode(transition),
            o = DistributionDBNNode(observation),
            r = FunctionDBNNode(reward)
           ),
           (s = (),
            a = (),
            sp = (:s, :a),
            o = (:s, :a, :sp),
            r = (:s, :a, :sp, :o)
           )
          )
end

DBNStructure(m) = DBNStructure(typeof(m))

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

function implemented(g::typeof(gen), n::DistributionDBNNode, M::Type, Deps::TupleType, RNG::Type)
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

function implemented(g::typeof(gen), n::FunctionDBNNode, M::Type, Deps::TupleType, RNG::Type)
    return implemented(n.f, Tuple{M, Deps.parameters...})
end

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
