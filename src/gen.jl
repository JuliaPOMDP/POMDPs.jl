


function gen end


@generated function gen(v::Val{S::Symbol}, m, s, a, rng)
    @debug("Creating an implementation for gen(::Val{$S}, ::M, ::S, ::A, ::RNG)", M=m, S=s, A=a, RNG=rng)
    # look for gen
    # if gen exists
    #   use it. At runtime, if missing S, try to get it, and if you can't, warn that it is not in the return of gen
    if implemented(gen, Tuple{m, s, a, rng})
        @debug("Found gen(::M, ::S, ::A, ::RNG)", M=m, S=s, A=a, RNG=rng)

        default = gen_default_expr(v, m, Dict(:s=>s, :a=>a, :sp=>s, :rng=>rng))
        if default == nothing
            @debug("No default for $S.")
            default = :(error(""))
        end
        expr = quote
            x = gen(m, s, a, rng)
            if haskey(x, $S)
                return x[$S]
            else
                sp = x[:sp]
                $default
            end
        end
        
    # elseif generate is implemented **directly**
    #   warn
    #   use it
    elseif implemented(generate_function(v), Tuple{m, s, a, rng})
        @warn("")
        expr = :(generate_ (m, s, a, rng))

    # elseif explicit is implemented
    #   construct from explicit
    else

        gen_explicit_expr(v, m, Dict(:s=>s, :a=>a, :rng=>rng))
        

    # else
    #   call gen which won't exist
        else
            expr = quote
                x = gen(m, s, a, rng) # this will always throw a method error
                return x[$S]
            end
        end
    end
    @debug("Implementing gen(::Val{$S}, ::M, ::S, ::A, ::RNG) with:\n$expr")
    return expr
end

# assumes that gen has been implemented and returns at least sp
gen_default_expr(::Val{S::Symbol}, mtype, symboltypes) = nothing
gen_default_expr(::Val{:r}, mtype::Type, symboltypes::Dict{Symbol, Type}) = reward(m, s, a, sp)

gen_default_expr(::Val{:o}, mtype::Type, symboltypes::Dict{Symbol, Type})

# assumes that gen has not been implemented and should only use functions from the explicit interface
gen_explicit_expr(::Val{S::Symbol}, mtype::Type, symboltypes::Dict{Symbol, Type})
