@generated function gen(v::DBNOut{symbols}, m, s, a, rng) where symbols

    # deprecation of old generate_ functions
    if haskey(old_generate, symbols) && implemented_by_user(old_generate[symbols], Tuple{m, s, a, rng})
        @warn("""Using user-implemented function
                  $(old_generate[symbols])(::M, ::S, ::A, ::RNG)
              which is deprecated in POMDPs v0.8. Please implement this as
                  POMDPs.gen(::M, ::S, ::A, ::RNG) or
                  POMDPs.gen(::DBNOut{$symbols}, ::M, ::S, ::A, ::RNG)
              instead. See the POMDPs.gen documentation for more details.""", M=m, S=s, A=a, RNG=rng)
        return :($(old_generate[symbols])(m, s, a, rng))
    end

    quote
        dbn = DBNStructure(m)
        genout(v, dbn, m, s, a, rng)
    end
end

@inline @generated function genout(v::DBNOut{symbols}, dbn::DBNDef, m, s, a, rng) where symbols
    
    # use anything available from gen(m, s, a, rng)
    expr = quote
        x = gen(m, s, a, rng)
        @assert x isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(x))"
    end

    # add gen for any other variables
    for (var, depargs) in sorted_deppairs(dbn, symbols)
        if var in (:s, :a) # eventually should look for InputDBNNodes instead of being hardcoded
            continue
        end

        sym = Meta.quot(var)

        varblock = quote
            if haskey(x, $sym) # should be constant at compile time
                $var = x[$sym]
            else
                $var = gen(DBNVar{$sym}(), m, $(depargs...), rng)
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

@generated function gen(::DBNVar{x}, m, args...) where x
    # this function is only @generated to deal with deprecation of gen functions

    # deprecation of old generate_ functions
    if haskey(old_generate, x) && implemented_by_user(old_generate[x], Tuple{m, args...})
        @warn("""Using user-implemented function
                  $(old_generate[x])(::M, ::Argtypes...)
              which is deprecated in POMDPs v0.8. Please implement this as
                  POMDPs.gen(::M, ::Argtypes...) or
                  POMDPs.gen(::DBNVar{$x}, ::M, ::Argtypes...)
              instead. See the POMDPs.gen documentation for more details.""", M=m, Argtypes=args)
        return :($(old_generate[x])(m, args...))
    end

    quote 
        gen(node(DBNStructure(m), x), m, args...)
    end
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
        @assert v <: Union{DBNVar, DBNOut}
        vp = first(v.parameters)
        if haskey(old_generate, vp) && implemented_by_user(old_generate[vp], Tuple{TT.parameters[2:end]...}) # old generate function is implemented
            return true
        end

        return implemented(g, v, TT.parameters[2], Tuple{TT.parameters[3:end-1]...}, TT.parameters[end])
    end
end

function implemented(g::typeof(gen), Var::Type{D}, M::Type, Deps::TupleType, RNG::Type) where D <: DBNVar
    v = first(Var.parameters)
    dbn = DBNStructure(M)
    return implemented(g, node(dbn, v), M, Deps, RNG)
end

function implemented(g::typeof(gen), Vars::Type{D}, M::Type, Deps::TupleType, RNG::Type) where D <: DBNOut
    if length(Deps.parameters) == 2 && implemented(g, Tuple{M, Deps.parameters..., RNG}) # gen(m, s, a, rng) is implemented
        return true # should this be true or missing?
    else
        return missing # this is complicated because we need to know the types of everything in the dbn 
    end
end
