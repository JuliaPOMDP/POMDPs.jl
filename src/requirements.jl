### Requirements Tools for Solver Writers ###
# TODO allow for function names

typealias TupleType Type # should be Tuple{T1,T2,...}

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
    @req f( ::T1, ::T2)
    
Marks the expression as a requirement.

Only works within @POMDP_requirements block. Cannot be expanded (will throw an error).
"""
macro req(ex)
    error("@req was used outside a @POMDP_requirements block or was expanded within one.")
end


"""
    @convert_req

Convert a `f( ::T1, ::T2)` expression to a `(f, Tuple{T1,T2})` for pushing to a `RequirementSet`.
"""
macro convert_req(ex)
    return esc(convert_req(ex))
end


"""
    check_requirements(r::RequirementSet; output::Union{Bool,Symbol}=:ifmissing)

Check whether the methods in `r` have implementations with `method_exists()` and print out a formatted list showing which are missing (output can be supressed with `output=false`). Return true if all methods have implementations.
"""
function check_requirements(r::RequirementSet; output::Union{Bool,Symbol}=:ifmissing)
    checked = CheckedList()
    missing = false
    for fp in r.set
        exists = method_exists(first(fp), last(fp))
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
        error("Malformed @req expression: $ex")
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
        req_node = convert_req(node.args[2])
        node.head = :call
        node.args = [:push!, reqs_name, esc(req_node)]
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
