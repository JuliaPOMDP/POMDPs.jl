### tools for checking if there is an implementation ###

typealias TupleType Type # should be Tuple{T1,T2,...}

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

### Requirements Tools for Solver Writers ###

type RequirementSet
    requirer::String
    set::Set{Tuple{Function, TupleType}}
end
RequirementSet(requirer::String) = RequirementSet(requirer, Set{Tuple{Function, TupleType}}())

Base.push!(r::RequirementSet, func::Function, argtypes::TupleType) = push!(r, (func, argtypes))
Base.push!(r::RequirementSet, t::Tuple{Function, TupleType}) = push!(r.set, t)


"""
    reqs = @POMDP_requirements "CoolSolver" begin
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

function pomdp_requirements(name::Union{Expr,String}, block::Expr)
    req_found = handle_reqs!(block, :reqs)
    if !req_found
        block = esc(block)
        warn("No @req found in @POMDP_requirements block.")
    end

    newblock = quote
        reqs = RequirementSet($(esc(name)))
        try
            $block
        catch exception
            if isa(exception, MethodError)
                checked = check_requirements(reqs, output = true)
                print_with_color(:red, "Note: There may be additional requirements that can be determined when the following error is fixed:\n")
                println()
                rethrow(exception)
            else
                rethrow(exception)
            end
        end
        reqs
    end
    return newblock
end


"""
    @check_requirements "CoolSolver" begin
        PType = typeof(p)
        @req states(::PType)
        @req actions(::PType)
        @req transition(::PType, ::S, ::A)
        s = first(states(p))
        a = first(actions(p))
        t_dist = transition(p, s, a)
        @req rand(::AbstractRNG, ::typeof(t_dist))
    end

Check requirements in a block return true if all are met, false otherwise.
"""
macro check_requirements(name, block)
    newblock = quote
        reqs = $(pomdp_requirements(name, block))
        check_requirements(reqs)
    end
end


"""
    @req

Convert a `f( ::T1, ::T2)` expression to a `(f, Tuple{T1,T2})` for pushing to a `RequirementSet`.

If in a `@POMDP_requirements` block or `@check_requirements` block, marks the requirement for including in the set of requirements.
"""
macro req(ex)
    return esc(convert_req(ex))
end


"""
    check_requirements(r::RequirementSet; output::Union{Bool,Symbol}=:ifmissing)

Check whether the methods in `r` have implementations with `implemented()` and print out a formatted list showing which are missing (output can be supressed with `output=false`). Return true if all methods have implementations.
"""
function check_requirements(r::RequirementSet; output::Union{Bool,Symbol}=:ifmissing)
    checked = CheckedList()
    missing = false
    for fp in r.set
        exists = implemented(first(fp), last(fp))
        if !exists
            missing = true
        end
        push!(checked, (exists, first(fp), last(fp)))
    end
    if output == :ifmissing
        shouldprint = missing
    else
        shouldprint = output
    end
    if shouldprint
        println()
        print("INFO: ")
        print_with_color(:blue, r.requirer)
        println(" requires the methods below. Methods with a [✔] were implemented correctly; methods with a [X] are missing.")
        println()
        print_checked_list(checked)
        println()
    end
    return !missing
end


### Helpers (not intended for public use) ###

typealias CheckedList Vector{Tuple{Bool, Function, TupleType}}

function print_checked_list(cl::CheckedList)
    for item in cl
        if first(item)
            print_with_color(:green, "[✔] $(format_method(item[2], item[3]))")
            println()
        else
            print_with_color(:red, "[X] $(format_method(item[2], item[3]))")
            println()
        end
    end
end

function format_method(f::Function, argtypes::TupleType)
    str = "$f("
    len = length(argtypes.parameters)
    for (i, t) in enumerate(argtypes.parameters)
        str = string(str, " ::$t")
        if i < len
            str = string(str, ",")
        end
    end
    str = string(str, ")")
end

"""
Return a `(f, Tuple{T1,T2})` expression given a `f( ::T1, ::T2)` expression.
"""
function convert_req(ex::Expr)
    malformed = false
    if ex.head == :call
        func = ex.args[1]
        argtypes = Union{Symbol, Expr}[]
        for a in ex.args[2:end]
            if a.head == :(::)
                if length(a.args) == 1
                    push!(argtypes, a.args[1])
                elseif length(a.args) == 2
                    push!(argtypes, a.args[2])
                else
                    malformed = true
                    break
                end
            else
                malformed = true
                break
            end
        end
    else 
        malformed = true
    end
    if malformed # throw error at parse time so solver writers will have to deal with this
        error("Malformed method expression: $ex")
    else
        return quote ($func, Tuple{$(argtypes...)}) end
    end
end

# this is where the freaking magic happens.
"""
    handle_reqs!(block, reqs_name::Symbol)

Replace any @req calls with `push!(\$reqs_name, <requirement>)`

Returns true if there was a requirement in there and so should not be escaped.
"""
function handle_reqs!(node::Expr, reqs_name::Symbol)
    
    if node.head == :macrocall && node.args[1] == Symbol("@req")
        macro_node = copy(node)
        node.head = :call
        node.args = [:push!, reqs_name, esc(macroexpand(macro_node))]
        return true
    else
        found = falses(length(node.args))
        for (i, arg) in enumerate(node.args)
            found[i] = handle_reqs!(arg, reqs_name)
        end
        if any(found)
            for i in 1:length(node.args)
                if !found[i]
                    node.args[i] = esc(node.args[i])
                end
            end
        end
        return any(found)
    end
end

function handle_reqs!(node::Any, reqs_name::Symbol)
    # for anything that's not an Expr
    return false
end
