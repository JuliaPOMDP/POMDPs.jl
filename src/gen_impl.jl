@generated function gen(v::Return{X}, m, s, a, rng) where X

    @debug("Creating an implementation for gen(::Return{$X}, ::M, ::S, ::A, ::RNG)",
           M=m, S=s, A=a, RNG=rng)
    vp = first(v.parameters)

    # use old generate_ function if available
    if haskey(old_generate, vp) && implemented_by_user(old_generate[vp], Tuple{m, s, a, rng})
        @warn("""Using user-implemented function
                  $(old_generate[vp])(::M, ::S, ::A, ::RNG)
              which is deprecated in POMDPs v0.8. Please implement this as
                  POMDPs.gen(::M, ::S, ::A, ::RNG) or
                  POMDPs.gen(::Return{:$X}, ::M, ::S, ::A, ::RNG)
              instead. See the POMDPs.gen documentation for more details.""", M=m, S=s, A=a, RNG=rng)
        return :($(old_generate[vp])(m, s, a, rng))
    end

    # use anything available from gen(m, s, a, rng)
    if implemented(gen, Tuple{m,s,a,rng})
        @debug("Found gen(::M, ::S, ::A, ::RNG)", M=m, S=s, A=a, RNG=rng)
        novalgen_implemented = true
        expr = quote
            x = gen(m, s, a, rng)
            @assert x isa NamedTuple "gen(m::Union{MDP,POMDP}, ...) must return a NamedTuple; got a $(typeof(x))"
        end
    else
        novalgen_implemented = false
        expr = quote x = NamedTuple() end
    end
    @assert expr.head == :block

    if X isa Tuple
        symbols = X
    elseif X isa Symbol
        symbols = (X,)
    else
        error("X in gen(::Return{X}, ...) must be a Symbol or Tuple; got $X.")
    end

    # add fallbacks for other variables
    for var in filter(v->!(v in (:s, :a)), sorted_genvars(m, symbols))
        sym = Meta.quot(var)
        genvarargs = genvars[var].deps(m)
        genvarargtypes = [genvars[a].type(m) for a in genvarargs]

        # this error will be printed whenever we don't get the value from gen(m,s,a,rng)
        # it also contains backedge code
        if novalgen_implemented
            novalgen_error = quote
                desired = $sym
                retkeys = try
                        collect(keys(x))
                    catch
                        "<No keys in a $(typeof(x))>"
                    end
                @error("""gen(::M, ::S, ::A, ::RNG) was implemented and returned $x.

                       The keys in the returned object were $retkeys which does not include :$desired, and no fallback was found for :$desired. Expect an error to be thrown below.
                       """, M=typeof(m), S=typeof(s), A=typeof(a), RNG=typeof(rng))
            end
        else
            novalgen_error = quote
                try
                    gen(m, s, a, rng) # for backedges
                catch
                finally
                    desired = $sym
                    @error("gen(::M, ::S, ::A, ::RNG) was not implemented and no fallback was found for :$desired. Expect an error to be thrown below.", M=typeof(m), S=typeof(s), A=typeof(a), RNG=typeof(rng))
                end
            end
        end

        if var == X && genvarargs == [:s, :a]
            # in this case, calling gen would lead to a stack overflow
            if genvars[var].fallback != nothing &&
                    genvars[var].fallback.isimplemented(m, s, a, rng)
                fallback = quote
                    $var = $(genvars[var].fallback.impl)(m, s, a, rng)
                end
            else
                fallback = quote
                    $novalgen_error
                    suggestion = sprint($(genvars[var].fallback.suggest), m, s, a, rng)
                    @error("""No fallback found for gen(::Return{:$X}, m, s, a, rng). Either implement it directly, or consider the following suggestion:

                           $suggestion
                           """)
                    try
                        $(genvars[var].fallback.impl)(m, s, a, rng) # for backedges
                    catch
                    finally
                        # this is in the finally block because we want problems with fallback_implemented to get fixed
                        throw(MethodError(gen, (v, m, s, a, rng)))
                    end
                end
            end
        elseif implemented(gen, Tuple{Return{var}, m, genvarargtypes..., rng})
            fallback = quote
                $var = gen(Return($sym), m, $(genvarargs...), rng)
            end
        else
            fallback = quote
                $novalgen_error
                $var = gen(Return($sym), m, $(genvarargs...), rng)
            end
                
        end

        varblock = quote
            if haskey(x, $sym) # should be constant at compile time
                $var = x[$sym]
            else
                $fallback 
            end
        end
        append!(expr.args, varblock.args)
    end

    # add return expression
    if X isa Tuple
        return_expr = :(return $(Expr(:tuple, symbols...)))
    else # X isa Symbol
        return_expr = :(return $X)
    end
    append!(expr.args, return_expr.args)

    @debug("Implementing gen(::Return{$X}, ::M, ::S, ::A, ::RNG) with:\n$expr")
    return expr
end

@generated function gen(v::Return{X}, args...) where X
    if X isa Symbol
        if haskey(old_generate, X) && implemented_by_user(old_generate[X], Tuple{args...})
            argtypestring = join(("::$a" for a in args), ", ")
            @warn("""Using user-implemented function
                      $(old_generate[X])($argtypestring)
                  which is deprecated in POMDPs v0.8. Please implement this as
                      POMDPs.gen(::Return{:$X}, $argtypestring)
                  """)
            return :($(old_generate[X])(args...))
        else
            if genvars[X].fallback != nothing &&
                genvars[X].fallback.isimplemented(args...)
                return :($(genvars[X].fallback.impl)(args...))
            else
                argtypestring = join(("::$a" for a in args), ", ") # outside quote for purity
                return quote
                    suggestion = sprint($(genvars[X].fallback.suggest), args...)
                    argtypestring = $argtypestring
                    @error("""No fallback found for gen(::Return{:$X}, $argtypestring). Either implement it directly, or consider the following suggestion:

                           $suggestion
                           """)
                    try
                        $(genvars[X].fallback.impl)(args...) # for backedges
                    catch
                    finally
                        throw(MethodError(gen, (v, args...))) # in finally so errors in isimplemented get fixed
                    end
                end
            end
        end
    else
        @error("""Automatic implementation of `gen(::Return{X}, ...)` where `X <: Tuple` is only supported in the case of gen(::Return{X}, m, s, a, rng). Expect an error below.
               
               You may wish to implement the missing function yourself, or if you would like this functionality, please file an issue at https://github.com/JuliaPOMDP/POMDPs.jl/issues/new.
               """)
        return :(throw(MethodError(gen, (v, args...))))
    end
end

function implemented(g::typeof(gen), TT::TupleType)
    v = first(TT.parameters)
    if v <: Return
        m = which(g, TT)
        argtypes_without_val = TT.parameters[2:end]
        vp = first(v.parameters)
        vptpl = vp isa Tuple ? vp : tuple(vp)
        if m.module != POMDPs # implemented by a user elsewhere
            return true
        elseif implemented(g, Tuple{argtypes_without_val...}) # gen(m,s,a,rng) is implemented
            return true
        elseif haskey(old_generate, vp) && implemented_by_user(old_generate[vp], Tuple{argtypes_without_val...})
            return true
        elseif vp isa Symbol &&
                genvars[vp].fallback != nothing &&
                genvars[vp].fallback.isimplemented(argtypes_without_val...)
            return true
        elseif vp isa Tuple
            # Note: already checked for gen(m,s,a,rng) above
            modeltype = first(argtypes_without_val)
            rngtype = last(argtypes_without_val)
            for var in filter(v->!(v in (:s, :a)), sorted_genvars(modeltype, vp))
                deptypes = collect(genvars[d].type(modeltype) for d in genvars[var].deps(modeltype))
                if !implemented(gen, Tuple{Return{var}, modeltype, deptypes..., rngtype})
                    return false
                end
            end
            return true
        else
            return false
        end
    else # gen(m,s,a,rng)
        return hasmethod(g, TT)
    end
end
