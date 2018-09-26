# Default implementations of generative model functions

# This file is long, messy and fragile. One day a more robust paradigm should be used.

function implemented(f::typeof(generate_s), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    if m.module == POMDPs && !implemented(transition, Tuple{TT.parameters[1:end-1]...})
        return false
    else # a more specific implementation exists
        return true
    end
end

@generated function generate_s(p::Union{MDP,POMDP}, s, a, rng::AbstractRNG)
    impl = quote
        td = transition(p, s, a)
        return rand(rng, td)
    end
    if implemented(transition, Tuple{p, s, a})
        return impl
    else
        treq = @req transition(::p,::s,::a)
        reqs = [(implemented(treq...), treq...)]
        this = @req(generate_s(::p, ::s, ::a, ::rng))
        return quote
            try
                $impl # trick the compiler to put the right backedges in
            catch
                failed_synth_warning($this, $reqs)
                throw(MethodError(generate_s, (p,s,a,rng)))
            end
        end
    end
end


function implemented(f::typeof(generate_sr), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    reqs_met = implemented(generate_s, TT) && implemented(reward, Tuple{TT.parameters[1:end-1]..., TT.parameters[2]})
    if m.module == POMDPs && !reqs_met
        return false
    else # a more specific implementation exists
        return true
    end
end

@generated function generate_sr(p::Union{POMDP,MDP}, s, a, rng::AbstractRNG)
    impl = quote
        sp = generate_s(p, s, a, rng)
        return sp, reward(p, s, a, sp)
    end

    if implemented(generate_s, Tuple{p, s, a, rng}) && implemented(reward, Tuple{p, s, a, s})
        return impl
    else
        reqs = [@req(transition(::p,::s,::a)), @req(reward(::p, ::s, ::a, ::s))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_s(::p, ::s, ::a, ::AbstractRNG)), @req(reward(::p, ::s, ::a, ::s))]
        gcl = [(implemented(r...), r...) for r in greqs]
        this = @req(generate_sr(::p, ::s, ::a, ::rng))
        return quote
            try
                $impl # trick to get the compiler to put the right backedges in
            catch
                failed_synth_warning($this, $cl, $gcl)
                throw(MethodError(generate_sr, (p,s,a,rng)))
            end
        end
    end
end

function implemented(f::typeof(generate_o), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    if m.module == POMDPs && !implemented(observation, Tuple{TT.parameters[1:end-1]...})
        return false
    else # a more specific implementation exists
        return true
    end
end

@generated function generate_o(p::POMDP, s, a, sp, rng::AbstractRNG)
    impl = quote
        od = observation(p, s, a, sp)
        return rand(rng, od)
    end

    if implemented(observation, Tuple{p, s, a, sp})
        return impl
    else
        oreq = @req observation(::p, ::s, ::a, ::sp)
        reqs = [(implemented(oreq...), oreq...)]
        this = @req(generate_o(::p, ::s, ::a, ::sp, ::rng))
        return quote
            try
                $impl # trick to get the compiler to put the right backedges in
            catch
                failed_synth_warning($this, $reqs)
                throw(MethodError(generate_o, (p, s, a, sp, rng)))
            end
        end
    end
end

function implemented(f::typeof(generate_so), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    reqs_met = implemented(generate_s, TT) && implemented(generate_o, Tuple{TT.parameters[1:end-1]..., TT.parameters[2], TT.parameters[end]})
    if m.module == POMDPs && !reqs_met
        return false
    else # a more specific implementation exists
        return true
    end
end

@generated function generate_so(p::POMDP, s, a, rng::AbstractRNG)
    impl = quote
        sp = generate_s(p, s, a, rng)
        return sp, generate_o(p, s, a, sp, rng)
    end

    if implemented(generate_s, Tuple{p, s, a, rng}) && implemented(generate_o, Tuple{p, s, a, s, rng})
        return impl
    else
        reqs = [@req(transition(::p,::s,::a)), @req(observation(::p, ::s, ::a, ::s))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_s(::p,::s,::a,::AbstractRNG)), @req(generate_o(::p, ::s, ::a, ::s, ::AbstractRNG))]
        gcl = [(implemented(r...), r...) for r in greqs]
        this = @req(generate_so(::p, ::s, ::a, ::rng))
        return quote
            try
                $impl # trick to get the compiler to put the right backedges in
            catch
                failed_synth_warning($this, $cl, $gcl)
                throw(MethodError(generate_so, (p,s,a,rng)))
            end
        end
    end
end


function implemented(f::typeof(generate_sor), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    so_reqs_met = implemented(generate_so, TT) && implemented(reward, Tuple{TT.parameters[1:end-1]..., TT.parameters[2]})
    sr_reqs_met = implemented(generate_sr, TT) && implemented(generate_o, Tuple{TT.parameters[1:end-1]..., TT.parameters[2], TT.parameters[end]})
    if m.module == POMDPs && !so_reqs_met && !sr_reqs_met
        return false
    else # a more specific implementation exists
        return true
    end
end

@generated function generate_sor(p::POMDP, s, a, rng::AbstractRNG)
    so_impl = quote
        sp, o = generate_so(p, s, a, rng)
        sp, o, reward(p, s, a, sp)
    end

    sr_impl = quote
        sp, r = generate_sr(p, s, a, rng)
        o = generate_o(p, s, a, sp, rng)
        sp, o, r
    end

    if implemented(generate_so, Tuple{p, s, a, rng}) && implemented(reward, Tuple{p, s, a, s})
        return so_impl
    elseif implemented(generate_sr, Tuple{p, s, a, rng}) && implemented(generate_o, Tuple{p, s, a, s, rng})
        return sr_impl
    else
        reqs = [@req(transition(::p,::s,::a)), @req(observation(::p, ::s, ::a, ::s)), @req(reward(::p,::s,::a,::s))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_sr(::p,::s,::a,::AbstractRNG)), @req(generate_o(::p, ::s, ::a, ::s, ::AbstractRNG))]
        gcl = [(implemented(r...), r...) for r in greqs]
        this = @req(generate_sor(::p, ::s, ::a, ::rng))
        return quote
            try # dirty trick to get the compiler to insert the right backedges
                $so_impl
                $sr_impl
            catch
                failed_synth_warning($this, $cl, $gcl)
                throw(MethodError(generate_sor, (p,s,a,rng)))
            end
        end
    end
end


function implemented(f::typeof(generate_or), TT::Type)
    if !hasmethod(f, TT)
        return false
    end
    m = which(f, TT)
    reqs_met = implemented(generate_o, TT) && implemented(reward, Tuple{TT.parameters[1:end-1]..., TT.parameters[2]})
    if m.module == POMDPs && !reqs_met
        return false
    else # a more specific implementation exists
        return true
    end
end

@generated function generate_or(p::POMDP, s, a, sp, rng::AbstractRNG)
    impl = quote
        o = generate_o(p, s, a, sp, rng)
        return o, reward(p, s, a, sp)
    end

    if implemented(generate_o, Tuple{p, s, a, sp, rng}) && implemented(reward, Tuple{p, s, a, sp})
        return impl
    else
        reqs = [@req(observation(::p, ::s, ::a, ::sp)), @req(reward(::p,::s,::a,::sp))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_o(::p, ::s, ::a, ::s, ::AbstractRNG)), @req(reward(::p,::s,::a,::sp))]
        gcl = [(implemented(r...), r...) for r in greqs]
        this = @req(generate_or(::p, ::s, ::a, ::rng))
        return quote
            try
                $impl # trick to get the compiler to insert the right backedges
            catch
                failed_synth_warning($this, $cl, $gcl)
                throw(MethodError(generate_or, (p,s,a,sp,rng)))
            end
        end
    end
end


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
                failed_synth_warning($this, $reqs)
                throw(MethodError(initialstate, (p, rng)))
            end
        end
    end
end


function failed_synth_warning(gen::Tuple, reqs::Vector, greqs::Vector=[]) 
    io = IOBuffer()
    ioc = IOContext(io, stderr)
    print(ioc, "Hint: Either implement ")
    printstyled(ioc, format_method(gen...), color=:blue)
    println(ioc, " directly, or, to automatically synthesize it, implement the following methods from the explicit interface:\n")
    show_checked_list(ioc, reqs)
    if !isempty(greqs)
        println(ioc, """
    \nOR implement the following methods from the generative interface:
    """)
        show_checked_list(ioc, greqs)
    end
    println(ioc, "\n([✔] = already implemented correctly; [X] = missing)")
    @warn("""
          POMDPs.jl: Could not find or synthesize $(format_method(gen...)). Note that this is only a warning to help diagnose problems; consider fixing errors first.
          
          $(String(take!(io)))
          """)
end
