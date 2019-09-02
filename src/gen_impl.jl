@generated function gen(v::DBNTuple{symbols}, m, s, a, rng) where symbols

    # deprecation of old generate_ functions
    if haskey(old_generate, symbols) && implemented_by_user(old_generate[symbols], Tuple{m, s, a, rng})
        @warn("""Using user-implemented function
                  $(old_generate[symbols])(::M, ::S, ::A, ::RNG)
              which is deprecated in POMDPs v0.8. Please implement this as
                  POMDPs.gen(::M, ::S, ::A, ::RNG) or
                  POMDPs.gen(::DBNTuple{$symbols}, ::M, ::S, ::A, ::RNG)
              instead. See the POMDPs.gen documentation for more details.""", M=m, S=s, A=a, RNG=rng)
        return :($(old_generate[symbols])(m, s, a, rng))
    end

    # use anything available from gen(m, s, a, rng)
    expr = quote
        x = gen(m, s, a, rng)
        @assert x isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(x))"
    end

    # add gen for any other variables
    dbn = DBNStructure(m)
    for var in filter(v->!(v in (:s, :a)), sorted_nodenames(dbn, symbols))
        sym = Meta.quot(var)

        depargs = dbn.deps[var]

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
    return_expr = :(return $(Expr(:tuple, symbols...)))
    append!(expr.args, return_expr.args)

    return expr
end

@generated function gen(::DBNVar{x}, m, s, a, rng) where x
    # this function is only @generated to deal with the deprecation of generate_ functions
    
    # deprecation of old generate_ functions
    if haskey(old_generate, x) && implemented_by_user(old_generate[x], Tuple{m, s, a, rng})
        @warn("""Using user-implemented function
                  $(old_generate[x])(::M, ::S, ::A, ::RNG)
              which is deprecated in POMDPs v0.8. Please implement this as
                  POMDPs.gen(::M, ::S, ::A, ::RNG) or
                  POMDPs.gen(::DBNVar{$x}, ::M, ::S, ::A, ::RNG)
              instead. See the POMDPs.gen documentation for more details.""", M=m, S=s, A=a, RNG=rng)
        return :($(old_generate[x])(m, s, a, rng))
    end

    quote
        nt = gen(m, s, a, rng)
        @assert nt isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(nt))"
        if haskey(nt, x)
            return nt[x]
        else
            return gen(DBNStructure(m).nodes[x], m, s, a, rng)
        end
    end
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
        gen(DBNStructure(m).nodes[x], m, args...)
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
        @assert v <: Union{DBNVar, DBNTuple}
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
    return implemented(g, dbn.nodes[v], M, Deps, RNG)
end

function implemented(g::typeof(gen), Vars::Type{D}, M::Type, Deps::TupleType, RNG::Type) where D <: DBNTuple
    if length(Deps.parameters) == 2 && implemented(g, Tuple{M, Deps.parameters..., RNG}) # gen(m, s, a, rng) is implemented
        return true # should this be true or missing?
    else
        tpl = first(Vars.parameters)
        if length(tpl) == 1
            return implemented(g, DBNVar{first(tpl)}, M, Deps, RNG)
        else
            return missing # this is complicated because we need to know the types of everything in the dbn 
        end
    end
end
