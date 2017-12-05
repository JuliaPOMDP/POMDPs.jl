# Default implementations of generative model functions

# Yes, this could be cleaned up with a macro to get rid of all the repetition, but figuring out how the macro would work exactly took more thought

function implemented(f::typeof(generate_s), TT::Type)
    if !method_exists(f, TT)
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
    if implemented(transition, Tuple{p, s, a})
        return quote
            td = transition(p, s, a)
            return rand(rng, td)
        end
    else
        treq = @req transition(::p,::s,::a)
        reqs = [(implemented(treq...), treq...)]
        failed_synth_warning(@req(generate_s(::p, ::s, ::a, ::rng)), reqs)
        return :(throw(MethodError(generate_s, (p,s,a,rng))))
    end
end


function implemented(f::typeof(generate_sr), TT::Type)
    if !method_exists(f, TT)
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
    if implemented(generate_s, Tuple{p, s, a, rng}) && implemented(reward, Tuple{p, s, a, s})
        return quote
            sp = generate_s(p, s, a, rng)
            return sp, reward(p, s, a, sp)
        end
    else
        reqs = [@req(transition(::p,::s,::a)), @req(reward(::p, ::s, ::a, ::s))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_s(::p, ::s, ::a, ::AbstractRNG)), @req(reward(::p, ::s, ::a, ::s))]
        gcl = [(implemented(r...), r...) for r in greqs]
        failed_synth_warning(@req(generate_sr(::p, ::s, ::a, ::rng)), cl, gcl)
        return :(throw(MethodError(generate_sr, (p,s,a,rng))))
    end
end

function implemented(f::typeof(generate_o), TT::Type)
    if !method_exists(f, TT)
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
    if implemented(observation, Tuple{p, s, a, sp})
        return quote
            od = observation(p, s, a, sp)
            return rand(rng, od)
        end
    else
        oreq = @req observation(::p, ::s, ::a, ::sp)
        reqs = [(implemented(oreq...), oreq...)]
        failed_synth_warning(@req(generate_o(::p, ::s, ::a, ::sp, ::rng)), reqs)
        return :(throw(MethodError(generate_o, (p, s, a, sp, rng))))
    end
end

function implemented(f::typeof(generate_so), TT::Type)
    if !method_exists(f, TT)
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
    if implemented(generate_s, Tuple{p, s, a, rng}) && implemented(generate_o, Tuple{p, s, a, s, rng})
        return quote
            sp = generate_s(p, s, a, rng)
            return sp, generate_o(p, s, a, sp, rng)
        end
    else
        reqs = [@req(transition(::p,::s,::a)), @req(observation(::p, ::s, ::a, ::s))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_s(::p,::s,::a,::AbstractRNG)), @req(generate_o(::p, ::s, ::a, ::s, ::AbstractRNG))]
        gcl = [(implemented(r...), r...) for r in greqs]
        failed_synth_warning(@req(generate_so(::p, ::s, ::a, ::rng)), cl, gcl)
        return :(throw(MethodError(generate_so, (p,s,a,rng))))
    end
end


function implemented(f::typeof(generate_sor), TT::Type)
    if !method_exists(f, TT)
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
    if implemented(generate_so, Tuple{p, s, a, rng}) && implemented(reward, Tuple{p, s, a, s})
        return quote
            sp, o = generate_so(p, s, a, rng)
            return sp, o, reward(p, s, a, sp)
        end
    elseif implemented(generate_sr, Tuple{p, s, a, rng}) && implemented(generate_o, Tuple{p, s, a, s, rng})
        return quote
            sp, r = generate_sr(p, s, a, rng)
            o = generate_o(p, s, a, sp, rng)
            return sp, o, r
        end
    else
        reqs = [@req(transition(::p,::s,::a)), @req(observation(::p, ::s, ::a, ::s)), @req(reward(::p,::s,::a,::s))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_sr(::p,::s,::a,::AbstractRNG)), @req(generate_o(::p, ::s, ::a, ::s, ::AbstractRNG))]
        gcl = [(implemented(r...), r...) for r in greqs]
        failed_synth_warning(@req(generate_sor(::p, ::s, ::a, ::rng)), cl, gcl)
        return :(throw(MethodError(generate_sor, (p,s,a,rng))))
    end
end



function implemented(f::typeof(generate_or), TT::Type)
    if !method_exists(f, TT)
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
    if implemented(generate_o, Tuple{p, s, a, sp, rng}) && implemented(reward, Tuple{p, s, a, sp})
        return quote
            o = generate_o(p, s, a, sp, rng)
            return o, reward(p, s, a, sp)
        end
    else
        reqs = [@req(observation(::p, ::s, ::a, ::sp)), @req(reward(::p,::s,::a,::sp))]
        cl = [(implemented(r...), r...) for r in reqs]
        greqs = [@req(generate_o(::p, ::s, ::a, ::s, ::AbstractRNG)), @req(reward(::p,::s,::a,::sp))]
        gcl = [(implemented(r...), r...) for r in greqs]
        failed_synth_warning(@req(generate_or(::p, ::s, ::a, ::rng)), cl, gcl)
        return :(throw(MethodError(generate_or, (p,s,a,sp,rng))))
    end
end


function implemented(f::typeof(initial_state), TT::Type)
    if !method_exists(f, TT)
        return false
    end
    m = which(f, TT)
    if m.module == POMDPs && !implemented(initial_state_distribution, Tuple{TT.parameters[1]})
        return false
    else
        return true
    end
end

@generated function initial_state(p::Union{POMDP,MDP}, rng::AbstractRNG)
    if implemented(initial_state_distribution, Tuple{p})
        return quote
            d = initial_state_distribution(p)
            return rand(rng, d)
        end
    else
        req = @req initial_state_distribution(::p)
        reqs = [(implemented(req...), req...)]
        failed_synth_warning(@req(initial_state(::p, ::rng)), reqs)
        return :(throw(MethodError(initial_state, (p, rng))))
    end
end

function failed_synth_warning(gen::Tuple, reqs::Vector, greqs::Vector=[]) 
    io = IOBuffer()
    show_checked_list(io, reqs)
    Core.println("""
WARNING: POMDPs.jl: Could not find or synthesize $(format_method(gen...)). Either implement it directly, or, to automatically synthesize it, implement the following methods from the explicit interface:

$(String(take!(io)))
    """)
    if !isempty(greqs)
        io = IOBuffer()
        show_checked_list(io, greqs)
        Core.println("""
OR implement the following methods from the generative interface:

$(String(take!(io)))
                     """)
    end
    Core.println("([✔] = already implemented correctly; [X] = missing)")
end
