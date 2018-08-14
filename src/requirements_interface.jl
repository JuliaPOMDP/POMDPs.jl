
"""
    implemented(function, Tuple{Arg1Type, Arg2Type})

Check whether there is an implementation available that will return a suitable value.
"""
implemented(f::Function, TT::TupleType) = hasmethod(f, TT)

"""
    @implemented function(::Arg1Type, ::Arg2Type)

Check whether there is an implementation available that will return a suitable value.
"""
macro implemented(ex)
    tplex = convert_req(ex)
    return quote
        implemented($(esc(tplex))...)
    end
end

"""
    get_requirements(f::Function, args::Tuple)

Return a RequirementSet for the function f and arguments args.
"""
get_requirements(f::Function, args::Tuple) = Unspecified((f, typeof(args)))


"""
    @get_requirements f(arg1, arg2)

Call get_requirements(f, (arg1,arg2)).
"""
macro get_requirements(call)
    return quote get_requirements($(esc(convert_call(call)))...) end
end


"""
    @POMDP_require solve(s::CoolSolver, p::POMDP) begin
        PType = typeof(p)
        @req states(::PType)
        @req actions(::PType)
        @req transition(::PType, ::S, ::A)
        s = first(states(p))
        a = first(actions(p))
        t_dist = transition(p, s, a)
        @req rand(::AbstractRNG, ::typeof(t_dist))
    end

Create a get_requirements implementation for the function signature and the requirements block.
"""
macro POMDP_require(typedcall, block)
    fname, args, types = unpack_typedcall(typedcall)
    tconstr = Expr[:($(Symbol(:T,i))<:$(esc(C))) for (i,C) in enumerate(types)] # oh snap
    ts = Symbol[Symbol(:T,i) for i in 1:length(types)]
    req_spec = :(($fname, Tuple{$(types...)}))
    fimpl = quote
        function POMDPs.get_requirements(f::typeof($(esc(fname))), args::Tuple{$(ts...)}) where {$(tconstr...)} # dang
            ($([esc(a) for a in args]...),) = args # whoah
            return $(pomdp_requirements(req_spec, block))
        end
    end
    return fimpl
end

"""
    reqs = @POMDP_requirements CoolSolver begin
        PType = typeof(p)
        @req states(::PType)
        @req actions(::PType)
        @req transition(::PType, ::S, ::A)
        s = first(states(p))
        a = first(actions(p))
        t_dist = transition(p, s, a)
        @req rand(::AbstractRNG, ::typeof(t_dist))
    end

Create a RequirementSet object.
"""
macro POMDP_requirements(name, block)
    return pomdp_requirements(name, block)
end


"""
    @warn_requirements solve(solver, problem)

Print a warning if there are unmet requirements.
"""
macro warn_requirements(call::Expr)
    quote
        reqs = get_requirements($(esc(convert_call(call)))...)
        if !check_requirements(reqs)
            show_requirements(reqs)
        end
    end
end


"""
    @show_requirements solve(solver, problem)

Print a a list of requirements for a function call.
"""
macro show_requirements(call::Expr)
    quote
        reqs = get_requirements($(esc(convert_call(call)))...)
        show_requirements(reqs)
    end
end

"""
    @requirements_info ASolver() [YourPOMDP()]

Print information about the requirements for a solver.
"""
macro requirements_info(exprs...)
    quote
        requirements_info($([esc(ex) for ex in exprs]...))
    end
end

"""
    requirements_info(s::Solver, p::Union{POMDP,MDP}, ...)

Print information about the requirement for solver s.
"""
function requirements_info(s::Union{Solver,Simulator})
    stype = typeof(s)
    try
        stype = stype.name.name
    catch ex
        # do nothing
    end
    println("""Please supply a POMDP as a second argument to requirements_info.
            e.g. `@requirements_info $(stype)() YourPOMDP()`
            """)
end
function requirements_info(s::Union{Solver,Simulator}, p::Union{POMDP,MDP}, args...)
    reqs = get_requirements(solve, (s, p))
    show_requirements(reqs)
end

"""
    @req f( ::T1, ::T2)

Convert a `f( ::T1, ::T2)` expression to a `(f, Tuple{T1,T2})::Req` for pushing to a `RequirementSet`.

If in a `@POMDP_requirements` or `@POMDP_require` block, marks the requirement for including in the set of requirements.
"""
macro req(ex)
    return esc(convert_req(ex))
end

"""
    @subreq f(arg1, arg2)

In a `@POMDP_requirements` or `@POMDP_require` block, include the requirements for `f(arg1, arg2)` as a child argument set.
"""
macro subreq(ex)
    return quote
        get_requirements($(esc(convert_call(ex)))...)
    end
end

"""
    check_requirements(r::AbstractRequirementSet)

Check whether the methods in `r` have implementations with `implemented()`. Return true if all methods have implementations.
"""
function check_requirements(r::AbstractRequirementSet)
    analyzed = Set()
    return recursively_check(r, analyzed)
end

"""
    show_requirements(r::AbstractRequirementSet)

Check whether the methods in `r` have implementations with `implemented()` and print out a formatted list showing which are missing. Return true if all methods have implementations.
"""
function show_requirements(r::AbstractRequirementSet)
    buf = stdout
    reported = Set{Req}()
    analyzed = Set()

    show_heading(buf, r.requirer)
    println(buf)

    allthere, first_exception = recursively_show(buf, r, analyzed, reported)

    if !allthere
        println("Note: Missing methods are often due to incorrect importing. You must explicitly import POMDPs functions to add new methods.")
        println()
    end

    if first_exception != nothing
        print("Throwing the first exception (from processing ")
        printstyled(handle_method(first_exception.requirer), color=:blue)
        println(" requirements):\n")
        rethrow(first_exception.exception)
    end

    return allthere
end
