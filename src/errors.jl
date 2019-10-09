struct DistributionNotImplemented <: Exception
    sym::Symbol
    gen_firstarg::Type
    func::Function
    modeltype::Type
    dep_argtypes::AbstractVector
end

function Base.showerror(io::IO, ex::DistributionNotImplemented)
    println(io, """\n

        POMDPs.jl could not find an implementation for DDN Node :$(ex.sym). Consider the following options:
        """)

    argstring = string("::", ex.modeltype, string((", ::$T" for T in ex.dep_argtypes)...))

    i = 1
    if ex.gen_firstarg <: DDNOut
        M = ex.modeltype
        S = statetype(M)
        A = actiontype(M)
        printstyled(io, "$i) Implement POMDPs.gen(::$M, ::$S, ::$A, ::AbstractRNG) to return a NamedTuple with key :$(ex.sym).\n", bold=true)
        gen_analysis(io, ex.sym, M, [S,A])
        println(io)
        i += 1
    end
    printstyled(io, "$i) Implement POMDPs.gen(::DDNNode{:$(ex.sym)}, $argstring, ::AbstractRNG).\n",
                bold=true)
    try_show_method_candidates(io, MethodError(gen, Tuple{DDNNode{ex.sym}, ex.modeltype, ex.dep_argtypes..., AbstractRNG}))
    i += 1
    printstyled(io, "\n\n$i) Implement $(ex.func)($argstring).\n", bold=true)
    try_show_method_candidates(io, MethodError(ex.func, Tuple{ex.modeltype, ex.dep_argtypes...}))

    println(io, "\n\nThis error message uses heuristics to make recommendations for POMDPs.jl problem implementers. If it was misleading or you believe there is an inconsistency, please file an issue: https://github.com/JuliaPOMDP/POMDPs.jl/issues/new")
end

function distribution_impl_error(sym, func, modeltype, dep_argtypes)
    st = stacktrace()
    acceptable = (:distribution_impl_error, nameof(func), nameof(gen), nameof(genout))
    gen_firstarg = nothing # The first argument to the `gen` call that is furthest down in the stack trace

    try
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
                    dep_argtypes = [sig.body.parameters[3:end-1]...]
                end
            end
        end
    catch ex
        @debug("Error throwing DistributionNotImplemented error:\n$(sprint(showerror, ex))")
        throw(MethodError(func, Tuple{modeltype, dep_argtypes...}))
    end

    if gen_firstarg === nothing
        throw(MethodError(func, Tuple{modeltype, dep_argtypes...}))
    else
        throw(DistributionNotImplemented(sym, gen_firstarg, func, modeltype, dep_argtypes))
    end
end

function gen_analysis(io, sym::Symbol, modeltype::Type, dep_argtypes)
    argtypes = Tuple{modeltype, dep_argtypes..., AbstractRNG}
    rts = Base.return_types(gen, argtypes)
    if length(rts) <= 0 # there should always be the default NamedTuple() impl.
        @debug("Error analyzing the return types for gen. Please submit an issue at https://github.com/JuliaPOMDP/POMDPs.jl/issues/new", argtypes=argtypes, rts=rts)
    elseif length(rts) == 1
        rt = first(rts)
        if rt == typeof(NamedTuple()) && !implemented(gen, argtypes)
            try_show_method_candidates(io, MethodError(gen, argtypes))
            println(io)
        else
            println(io, "\nThis method was implemented and the return type was inferred to be $rt. Is this type always a NamedTuple with key :$(sym)?")
        end
    else
        println(io, "(POMDPs.jl could not determine if this method was implemented correctly. [Base.return_types(gen, argtypes) = $(rts)])")
    end
end

function try_show_method_candidates(io, args...)
    try
        Base.show_method_candidates(io, args...) # this isn't exported, so it might break
    catch ex
        @debug("Unable to show method candidates. Please submit an issue at https://github.com/JuliaPOMDP/POMDPs.jl/issues/new.\n$(sprint(showerror, ex))")
    end
end

transition(m, s, a) = distribution_impl_error(:sp, transition, typeof(m), [typeof(s), typeof(a)])
function implemented(t::typeof(transition), TT::TupleType)
    m = which(t, TT)
    return m.module != POMDPs # see if this was implemented by a user elsewhere
end

observation(m, sp) = distribution_impl_error(:o, observation, typeof(m), [typeof(sp)])
function implemented(o::typeof(observation), TT::Type{Tuple{M, SP}}) where {M<:POMDP, SP}
    m = which(o, TT)
    return m.module != POMDPs
end
