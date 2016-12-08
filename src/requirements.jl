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
    @try_with_reqs begin
        # some expressions
    end reqs

Run some expressions. If these expressions throw a method error, the `RequirementSet` `reqs` will be printed and the error will be rethrown.
"""
macro try_with_reqs(expression, set)
    block = quote
        try
            $expression
        catch exception
            if isa(exception, MethodError)
                check_requirements($set, output = true)
                print_with_color(:red, "Note: There may be additional requirements that can be determined when the following error is fixed.\n")
                println()
                rethrow(exception)
            else
                rethrow(exception)
            end
        end
    end
    return esc(block)
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

### Convenience Macros ###

"""
    @req f( ::T1, ::T2)
    
The expression above is transformed to `(f, Tuple{T1,T2})`.
"""
macro req(ex)
    return esc(convert_req(ex))
end

"""
    @push_req! r f( ::T1, ::T2)

Push requirement f( ::T1, ::T2) into RequirementSet `r`.
"""
macro push_req!(r, req)
    return esc(quote push!($r, $(convert_req(req))) end)
end

"""
    @push_reqs! r begin
        f1( ::T1, ::T2)
        f2( ::T2, ::T4)
    end

Push all of the requirements in a block into RequirementSet `r`.
"""
macro push_reqs!(r, blk)
    @assert blk.head == :block
    for (i,a) in enumerate(blk.args)
        if a.head == :line
            continue
        else
            blk.args[i] = quote push!($r, $(convert_req(a))) end
        end
    end
    return esc(blk)
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
        error("Malformed requirement expression: $ex")
    else
        return quote ($func, Tuple{$(argtypes...)}) end
    end
end

#=
function get_requirements(s::Union{Solver, Simulator}, p::Union{POMDP,MDP})

end
=#
