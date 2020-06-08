function gen(v::DDNOut{symbols}, m, s, a, rng) where symbols
    ddn = DDNStructure(m)
    genout(v, ddn, m, s, a, rng)
end

"""
Sample values for nodes specified in the first argument by sampling values for all intermediate nodes. 
"""
@inline @generated function genout(v::DDNOut{symbols}, ddn::DDNStructure, m, s, a, rng) where symbols
    
    # use anything available from gen(m, s, a, rng)
    expr = quote
        x = gen(m, s, a, rng)
        @assert x isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(x))"
    end

    # add gen for any other variables
    for (var, depargs) in sorted_deppairs(ddn, symbols)
        if var in (:s, :a) # eventually should look for InputDDNNodes instead of being hardcoded
            continue
        end

        sym = Meta.quot(var)

        varblock = quote
            if haskey(x, $sym) # should be constant at compile time
                $var = x[$sym]
            else
                $var = gen(DDNNode{$sym}(), m, $(depargs...), rng)
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

function gen(::DDNNode{x}, m, args...) where x
    gen(node(DDNStructure(m), x), m, args...)
end

gen(m::Union{MDP, POMDP}, s, a, rng) = NamedTuple()

function implemented(g::typeof(gen), TT::TupleType)
    m = which(g, TT)
    if m.module != POMDPs # implemented by a user elsewhere
        return true
    end
    v = first(TT.parameters)
    if v <: Union{MDP, POMDP}
        return false # already checked above for implementation in another module
    else
        @assert v <: Union{DDNNode, DDNOut}
        vp = first(v.parameters)
        return implemented(g, v, TT.parameters[2], Tuple{TT.parameters[3:end-1]...}, TT.parameters[end])
    end
end

function implemented(g::typeof(gen), Var::Type{D}, M::Type, Deps::TupleType, RNG::Type) where D <: DDNNode
    v = first(Var.parameters)
    ddn = DDNStructure(M)
    return implemented(g, node(ddn, v), M, Deps, RNG)
end

function implemented(g::typeof(gen), Vars::Type{D}, M::Type, Deps::TupleType, RNG::Type) where D <: DDNOut
    if length(Deps.parameters) == 2 && implemented(g, Tuple{M, Deps.parameters..., RNG}) # gen(m, s, a, rng) is implemented
        return true # should this be true or missing?
    else
        return missing # this is complicated because we need to know the types of everything in the ddn 
    end
end
