struct DistributionNotImplemented <: Exception
    sym::Symbol
    gen_firstarg::Type
    func::Function
    modeltype::Type
    dep_argtypes::NamedTuple
end

function Base.showerror(io::IO, ex::DistributionNotImplemented)
    println(io, """\n

        POMDPs.jl could not find an implementation for DDN Node :$(ex.sym). Consider the following options:
        """)

    argstring = string("::", ex.modeltype, string((", ::$T" for T in ex.dep_argtypes)...))

    i = 1
    if ex.gen_firstarg <: DDNOut
        printstyled(io, "$i) Implement POMDPs.gen($argstring, ::AbstractRNG) to return a NamedTuple with key :$(ex.sym).\n", bold=true)
        gen_analysis(io, ex)
        println(io)
        i += 1
    end
    printstyled(io, "$i) Implement POMDPs.gen(::DDNNode{:$(ex.sym)}, $argstring, ::AbstractRNG).\n",
                bold=true)
    Base.show_method_candidates(io, MethodError(gen, Tuple{DDNNode{ex.sym}, ex.modeltype, ex.dep_argtypes..., AbstractRNG})) # this is not exported - it may break
    i += 1
    printstyled(io, "\n\n$i) Implement $(ex.func)($argstring).\n", bold=true)
    Base.show_method_candidates(io, MethodError(transition, Tuple{ex.modeltype, ex.dep_argtypes...}))

    println(io, "\n\nThis error message uses heuristics to make recommendations for POMDPs.jl problem implementers. If it was misleading or you believe there is an inconsistency, please file an issue: https://github.com/JuliaPOMDP/POMDPs.jl/issues/new")
end

function distribution_impl_error(sym, func, modeltype, dep_argtypes)
    st = stacktrace()
    acceptable = (:distribution_impl_error, nameof(func), nameof(gen), nameof(genout))
    gen_firstarg = nothing # The first argument to the `gen` call that is furthest down in the stack trace

    for sf in stacktrace() # step up the stack trace

        # if it is a macro from ddn_struct.jl or gen_impl.jl it is ok
        if sf.func === Symbol("macro expansion")
            bn = basename(String(sf.file))
            if !(bn in ["ddn_struct.jl", "gen_impl.jl", "none"])
                break
                # the call stack includes a macro from some other package
            end

        # if it is not a function we know about, give up
        elseif !(sf.func in acceptable)
            break

        # if it is gen, check to see if it's the DDNNode version
        elseif sf.func === nameof(gen)
            sig = sf.linfo.def.sig
            if sig isa UnionAll &&
                sig.body.parameters[1] == typeof(gen) &&
                sig.body.parameters[2] <: Union{DDNNode, DDNOut}
                # bingo!
                gen_firstarg = sig.body.parameters[2]
            end
        end
    end

    if gen_firstarg === nothing
        throw(MethodError(transition, Tuple{modeltype, dep_argtypes...}))
    else
        throw(DistributionNotImplemented(:sp, gen_firstarg, func, modeltype, dep_argtypes))
    end
end

function gen_analysis(io, ex::DistributionNotImplemented)
    argtypes = Tuple{ex.modeltype, ex.dep_argtypes..., AbstractRNG}
    rts = Base.return_types(gen, argtypes)
    @assert length(rts) > 0 # there should always be the default NamedTuple() impl.
    if length(rts) == 1
        rt = first(rts)
        if rt == typeof(NamedTuple()) && !implemented(gen, argtypes)
            Base.show_method_candidates(io, MethodError(gen, argtypes))
            println(io)
        else
            println(io, "\nThis method was implemented and the return type was inferred to be $rt. Is this type always a NamedTuple with key :$(ex.sym)?")
        end
    else
        println(io, "(POMDPs.jl could not determine if this method was implemented correctly. [Base.return_types(gen, argtypes) = $(rts)])")
    end
end

transition(m, s, a) = distribution_impl_error(:sp, transition, typeof(m), (s=typeof(s), a=typeof(a)))
function implemented(t::typeof(transition), TT::TupleType)
    m = which(t, TT)
    return m.module != POMDPs # see if this was implemented by a user elsewhere
end

observation(m, sp) = distribution_impl_error(:o, observation, typeof(m), (sp=typeof(sp),))
function implemented(o::typeof(observation), TT::Type{Tuple{M, SP}}) where {M<:POMDP, SP}
    m = which(o, TT)
    return m.module != POMDPs
end
