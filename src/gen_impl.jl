gen(m::Union{MDP,POMDP}, s, a, rng) = NamedTuple()

"""
    DDNOut(x::Symbol)
    DDNOut{x::Symbol}()
    DDNOut(::Symbol, ::Symbol,...)
    DDNOut{x::NTuple{N, Symbol}}()

Reference to one or more named nodes in the POMDP or MDP dynamic decision network (DDN).

`DDNOut` is a "value type". See [the documentation of `Val`](https://docs.julialang.org/en/v1/manual/types/index.html#%22Value-types%22-1) for more conceptual details about value types.
"""
struct DDNOut{names} end

DDNOut(name::Symbol) = DDNOut{name}()
DDNOut(names...) = DDNOut{names}()
DDNOut(names::Tuple) = DDNOut{names}()

@generated function genout(v::DDNOut{symbols}, m::Union{MDP,POMDP}, s, a, rng) where symbols

    # use anything available from gen(m, s, a, rng)
    expr = quote
        x = gen(m, s, a, rng)
        @assert x isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(x))"
    end
    
    # add gen for any other variables
    for (var, depargs) in sorted_deppairs(m, symbols)
        if var in (:s, :a) # input nodes
            continue
        end

        sym = Meta.quot(var)

        varblock = quote
            if haskey(x, $sym) # should be constant at compile time
                $var = x[$sym]
            else
                $var = $(node_expr(Val(var), depargs))
            end
        end
        append!(expr.args, varblock.args)
    end

    # add return expression
    if symbols isa Tuple
        return_expr = :(return $(Expr(:tuple, symbols...)))
    else
        return_expr = :(return $symbols)
    end
    append!(expr.args, return_expr.args)

    return expr
end

function sorted_deppairs(m::Type{<:MDP}, symbols)
    deps = Dict(:s => Symbol[],
                :a => Symbol[],
                :sp => [:s, :a],
                :r => [:s, :a, :sp],
                :info => Symbol[]
               )
    return sorted_deppairs(deps, symbols)
end

function sorted_deppairs(m::Type{<:POMDP}, symbols)
    deps = Dict(:s => Symbol[],
                :a => Symbol[],
                :sp => [:s, :a],
                :o => [:s, :a, :sp],
                :r => [:s, :a, :sp, :o],
                :info => Symbol[]
               )
    return sorted_deppairs(deps, symbols)
end

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

sorted_deppairs(dn::Dict{Symbol, Vector{Symbol}}, sym::Symbol) = sorted_deppairs(dn, tuple(sym))

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

node_expr(::Val{:sp}, depargs) = :(rand(rng, transition(m, $(depargs...))))
node_expr(::Val{:o}, depargs) = :(rand(rng, observation(m, $(depargs...))))
node_expr(::Val{:r}, depargs) = :(reward(m, $(depargs...)))
node_expr(::Val{:info}, depargs) = :(nothing)
