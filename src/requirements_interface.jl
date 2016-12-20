
"""
    implemented(function, Tuple{Arg1Type, Arg2Type})

Check whether there is an implementation available that will return a suitable value.
"""
implemented(f::Function, TT::TupleType) = method_exists(f, TT)

"""
    @implemented function(::Arg1Type, ::Arg2Type)

Check whether there is an implementation available that will return a suitable value.
"""
macro implemented(ex)
    tplex = esc(convert_req(ex))
    return quote
        implemented($tplex...)
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
    fimpl = quote 
        function get_requirements{$(tconstr...)}(f::typeof($(esc(fname))), # dang
                                                 args::Tuple{$(ts...)})
            ($([esc(a) for a in args]...),) = args # whoah
            return $(pomdp_requirements(convert_req(typedcall), block))
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
        check_requirements(reqs, output=:ifmissing)
    end
end


"""
    @show_requirements solve(solver, problem)

Print a a list of requirements.
"""
macro show_requirements(call::Expr)
    quote
        reqs = get_requirements($(esc(convert_call(call)))...)
        check_requirements(reqs, output=true)
    end
end


"""
    @req f( ::T1, ::T2)

Convert a `f( ::T1, ::T2)` expression to a `(f, Tuple{T1,T2})` for pushing to a `RequirementSet`.

If in a `@POMDP_requirements` or `@POMDP_require` block, marks the requirement for including in the set of requirements.
"""
macro req(ex)
    return esc(convert_req(ex))
end

"""
    @subreq f(arg1, arg2)

In a `@POMDP_requirements` or `@POMDP_require` block, include the requirements for `f(arg1, arg2) as a child argument set.
"""
macro subreq(ex)
    return quote
        get_requirements($(esc(convert_call(ex)))...)
    end
end

"""
    check_requirements(r::RequirementSet; output::Union{Bool,Symbol}=:ifmissing)

Check whether the methods in `r` have implementations with `implemented()` and print out a formatted list showing which are missing (output can be supressed with `output=false`). Return true if all methods have implementations.
"""
function check_requirements(r::RequirementSet; output::Union{Bool,Symbol}=:ifmissing)
    buf = IOBuffer()
    reported = Set{Req}()
    analyzed = Set()

    show_heading(buf, r.requirer)
    println(buf)

    allthere, first_exception = recursively_check(buf, r, analyzed, reported)

    if output == :ifmissing
        shouldprint = !allthere
    else
        shouldprint = output
    end
    if shouldprint
        println()
        print(takebuf_string(buf))
        println()
    end

    if !isnull(first_exception)
        print("Throwing the first exception (from processing ")
        print_with_color(:blue, handle_method(get(first_exception).requirer))
        println(" requirements):\n")
        rethrow(get(get(first_exception).exception))
    end

    return allthere
end


"""
    @impl_dep {P<:POMDP,S,A} reward(::P,::S,::A,::S) reward(::P,::S,::A)

Declare an implementation dependency and automatically implement `implemented`.

In the example above, `@implemented reward(::P,::S,::A,::S)` will return true if the user has implemented `reward(::P,::S,::A,::S)` OR `reward(::P,::S,::A)`

THIS IS ONLY INTENDED FOR USE INSIDE POMDPs AND MAY NOT FUNCTION CORRECTLY ELSEWHERE
"""
macro impl_dep(curly, signature, dependency)
    # this is kinda hacky and fragile with the cell1d - email Zach if it breaks 
    @assert curly.head == :cell1d
    implemented_curly = :(implemented{$(curly.args...)})
    tplex = convert_req(signature)
    deptplex = convert_req(dependency)
    impled = quote
        function $implemented_curly(f::typeof(first($tplex)), TT::Type{last($tplex)})
            m = which(f,TT)
            if m.module == POMDPs && !implemented($deptplex...)
                return false
            else # a more specific implementation exists
                return true
            end
        end
    end
    return esc(impled)
end

