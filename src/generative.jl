# generative model interface functions

function gen end

"""
    initialstate{S}(p::Union{POMDP{S},MDP{S}}, rng::AbstractRNG)

Return the initial state for the problem `p`.

Usually the initial state is sampled from an initial state distribution.
"""
function initialstate end

function implemented(f::typeof(initialstate), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    if m.module == POMDPs && !implemented(initialstate_distribution, Tuple{TT.parameters[1]})
        return false
    else
        return true
    end
end

@generated function initialstate(p::Union{POMDP,MDP}, rng::AbstractRNG)
    impl = quote
        d = initialstate_distribution(p)
        return rand(rng, d)
    end

    if implemented(initialstate_distribution, Tuple{p})
        return impl
    else
        req = @req initialstate_distribution(::p)
        reqs = [(implemented(req...), req...)]
        this = @req(initialstate(::p, ::rng))
        return quote
            try
                $impl # trick to get the compiler to insert the right backedges
            catch
                # TODO failed_synth_warning($this, $reqs)
                throw(MethodError(initialstate, (p, rng)))
            end
        end
    end
end
