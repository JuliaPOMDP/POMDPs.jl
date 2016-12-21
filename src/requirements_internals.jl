typealias TupleType Type # should be Tuple{T1,T2,...}
typealias Req Tuple{Function, TupleType}

abstract AbstractRequirementSet

type Unspecified <: AbstractRequirementSet
    requirer
    parent::Nullable{Any}
end

Unspecified(requirer) = Unspecified(requirer, Nullable{Any}())

type RequirementSet <: AbstractRequirementSet
    requirer
    reqs::Vector{Req} # not actually a set - to preserve intuitive ordering
    deps::Vector{AbstractRequirementSet}
    parent::Nullable{Any}
    exception::Nullable{Any} # Exception that kept this from being created correctly (too scared to make this Nullable{Exception}, but that's what it should be
end

function RequirementSet(requirer, parent=nothing)
    return RequirementSet(requirer,
                          Vector{Tuple{Function, TupleType}}(),
                          AbstractRequirementSet[],
                          parent,
                          Nullable{Any}())
end

Base.push!(r::RequirementSet, func::Function, argtypes::TupleType) = push!(r, (func, argtypes))
Base.push!(r::RequirementSet, t::Tuple{Function, TupleType}) = push!(r.reqs, t)

function push_dep!(r::RequirementSet, dep::AbstractRequirementSet)
    dep.parent = Nullable{Any}(r.requirer)
    push!(r.deps, dep)
end

"""
Return an expression that creates a RequirementSet using the code in the block. The resulting code will *always* return a RequirementSet, but it may be incomplete if the exception field is not null.
"""
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
            reqs.exception = exception
            #=
            if isa(exception, MethodError)
                reqs.complete = false
                checked = check_requirements(reqs, output = true)
                print_with_color(:red, "Note: There may be additional requirements that can be determined after these requirements are met.\n")
                println()
                rethrow(exception)
            else
                rethrow(exception)
            end
            =#
        end
        reqs
    end
    return newblock
end

typealias CheckedList Vector{Tuple{Bool, Function, TupleType}}


"""
Return a `(f, Tuple{T1,T2})` expression given a `f( ::T1, ::T2)` expression.
"""
function convert_req(ex::Expr)
    malformed = false
    if ex.head == :call
        func = ex.args[1]
        argtypes = Union{Symbol, Expr}[]
        for a in ex.args[2:end]
            if isa(a, Expr) && a.head == :(::)
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
        throw(ErrorException("""
              Malformed requirement expression: $ex
              Requirements should be expressed in the form `function_name(::Type1, ::Type2)`
              """))
    else
        return quote ($func, Tuple{$(argtypes...)}) end
    end
end

function recursively_check(io::IO,
                           r::RequirementSet,
                           analyzed::Set,
                           reported::Set{Req})
    if r.requirer in analyzed
        return true
    end

    push!(analyzed, r.requirer)

    checked = CheckedList()
    allthere = true
    for fp in r.reqs
        if !(fp in reported)
            push!(reported, fp)
            exists = implemented(first(fp), last(fp))
            if !exists
                allthere = false
            end
            push!(checked, (exists, first(fp), last(fp)))
        end
    end

    show_requirer(io, r)
    if isempty(checked)
        println(io, "  [No additional requirements]")
    else
        show_checked_list(io, checked)
    end

    if isnull(r.exception) # no exception
        first_exception = Nullable{RequirementSet}()
    else
        allthere = false
        show_incomplete(io, r)
        first_exception = Nullable{RequirementSet}(r)
    end

    for dep in r.deps
        depcomplete, depexception = recursively_check(io, dep, analyzed, reported)
        allthere = allthere && depcomplete
        if isnull(first_exception) && !isnull(depexception)
            first_exception = Nullable{RequirementSet}(dep)
        end
    end

    return allthere, first_exception
end

function recursively_check(io::IO, r::Unspecified, analyzed::Set, reported::Set{Req})
    if r.requirer in analyzed
        return true, Nullable{RequirementSet}()
    else
        push!(analyzed, r.requirer)
        show_requirer(io::IO, r)
        println(io, "  [No requirements specified]")
        return true, Nullable{RequirementSet}()
    end
end

"""
Return a tuple (not an Expr) of the function name, arguments, and argument types.

E.g. `f(arg1::T1, arg2::T2)` would be unpacked to (:f, [:arg1, :arg2], [:T1, :T2])
"""
function unpack_typedcall(typedcall::Expr)
    malformed = false
    if typedcall.head != :call
        malformed = true
    end

    args = Union{Symbol,Expr}[]
    types = Union{Symbol,Expr}[]
    for expr in typedcall.args[2:end]
        if isa(expr,Expr) && expr.head == :(::)
            push!(args, expr.args[1])
            push!(types, expr.args[2])
        elseif isa(expr,Symbol)
            push!(args, expr)
            push!(types, :Any)
        else
            malformed = true
        end
    end

    if malformed
        error("""
              Malformed typed funciton call expression: $typedcall
              Expected the form `function_name(arg1::Type1, arg2::Type2)`.
              """)
    end

    return (typedcall.args[1], args, types)
end

"""
Return a `(f, (arg1,arg2))` expression given a `f(arg1, arg2)` expression.
"""
function convert_call(call::Expr)
    malformed = false
    if call.head == :call
        func = call.args[1]
        args = Union{Symbol, Expr}[]
        for a in call.args[2:end]
            if isa(a, Expr) && a.head == :(::)
                @assert length(args) == 2
                push!(args, a.args[1])
            else
                push!(args, a)
            end
        end
    else 
        malformed = true
    end
    if malformed # throw error at parse time so solver writers will have to deal with this
        error("""
              Malformed call expression: $call
              Expected the form `funcion_name(arg1, arg2)`
              """)
    else
        return quote ($func, ($(args...),)) end
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
        expanded = macroexpand(macro_node)
        if isa(expanded, Expr) && expanded.head == :error
            rethrow(expanded.args[1])
        end
        node.args = [:push!, reqs_name, esc(expanded)]
        return true
    elseif node.head == :macrocall && node.args[1] == Symbol("@subreq")
        macro_node = copy(node)
        node.head = :call
        expanded = macroexpand(macro_node)
        if isa(expanded, Expr) && expanded.head == :error
            rethrow(expanded.args[1])
        end
        node.args = [:push_dep!, reqs_name, esc(macroexpand(expanded))]
        return true
    else
        found = falses(length(node.args))
        for (i, arg) in enumerate(node.args)
            found[i] = handle_reqs!(arg, reqs_name)
        end
        if any(found)
            for i in 1:length(node.args)
                if !found[i] # && !(isa(node.args[i], Expr) && node.args[i].head == :line) # this would not escape lines (I don't know what implications that has)
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
