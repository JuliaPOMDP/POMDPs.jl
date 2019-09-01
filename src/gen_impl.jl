@generated function gen(v::DBNTuple{symbols}, m, s, a, rng) where symbols

    # deprecation of old generate_ functions
    if haskey(old_generate, symbols) && implemented_by_user(old_generate[symbols], Tuple{m, s, a, rng})
        @warn("""Using user-implemented function
                  $(old_generate[symbols])(::M, ::S, ::A, ::RNG)
              which is deprecated in POMDPs v0.8. Please implement this as
                  POMDPs.gen(::M, ::S, ::A, ::RNG) or
                  POMDPs.gen(::Return{:$symbols}, ::M, ::S, ::A, ::RNG)
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

    @debug("Implementing gen(::Return{$X}, ::M, ::S, ::A, ::RNG) with:\n$expr")
    return expr
end

function gen(::DBNVar{x}, m, s, a, rng) where x
    # XXX deprecation of old generate_ functions
    nt = gen(m, s, a, rng)
    @assert nt isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(nt))"
    if haskey(nt, x)
        return nt[x]
    else
        return gen(DBNStructure(m).nodes[x], m, s, a, rng)
    end
end

function gen(::DBNVar{x}, m, args...) where x
    return gen(DBNStructure(m).nodes[x], m, args...)
end

gen(m::Union{MDP, POMDP}, s, a, rng) = NamedTuple()

# function implemented(g::typeof(gen), TT::TupleType)
#     v = first(TT.parameters)
#     if v <: Union{DBNTuple, DBNNode}
#         m = which(g, TT)
#         argtypes_without_val = TT.parameters[2:end]
#         vp = first(v.parameters)
#         vptpl = vp isa Tuple ? vp : tuple(vp)
# 
#         if m.module != POMDPs # implemented by a user elsewhere
#             return true
#         elseif implemented(g, Tuple{argtypes_without_val...}) # gen(m,s,a,rng) is implemented
#             return true
#         elseif haskey(old_generate, vp) && implemented_by_user(old_generate[vp], Tuple{argtypes_without_val...}) # old generate function is implemented
#             return true
#         else
#             if 
#                 return true
#             if v isa Tuple
#                 # Note: already checked for gen(m,s,a,rng) above
#                 modeltype = first(argtypes_without_val)
#                 rngtype = last(argtypes_without_val)
#                 for var in filter(v->!(v in (:s, :a)), sorted_genvars(modeltype, vp))
#                     deptypes = collect(genvar_data(d).type(modeltype) for d in genvar_data(var).deps(modeltype))
#                     if !implemented(gen, Tuple{Return{var}, modeltype, deptypes..., rngtype})
#                         return false
#                     end
#                 end
#                 return true
#             else
#                 return false
#         end
#     else # gen(m,s,a,rng)
#         return hasmethod(g, TT)
#     end
# end
