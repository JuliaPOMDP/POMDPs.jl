struct DBNVar{name} end
struct DBNTuple{names} end

DBNVar(name::Symbol) = DBNVar{name}()
DBNTuple(names...) = DBNTuple{names}()

struct DBNDef{N<:NamedTuple, D<:NamedTuple}
    nodes::N
    deps::D
end

function DBNStructure(::Type{M}) where M <: MDP
    DBNDef((s = nothing,
            a = nothing,
            sp = DistributionDBNNode(:sp, transition),
            r = FunctionDBNNode(:r, reward)
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

function gen(n::DistributionDBNNode, m, args...)
    rand(args[end], n.dist_func(m, args[1:end-1]...))
end

struct FunctionDBNNode{F}
    f::F
end

function gen(n::FunctionDBNNode, m, args...)
    return n.f(m, args[1:end-1]...)
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
