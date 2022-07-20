"""
    showpolicy([io], [mime], m::MDP, p::Policy)
    showpolicy([io], [mime], statelist::AbstractVector, p::Policy)
    showpolicy(...; pre=" ")

Print the states in `m` or `statelist` and the actions from policy `p` corresponding to those states.

For the MDP version, if `io[:limit]` is `true`, will only print enough states to fill the display.
"""
function showpolicy(io::IO, mime::MIME"text/plain", m::MDP, p::Policy; pre=" ", kwargs...)
    slist = nothing
    truncated = false
    limited = get(io, :limit, false)
    rows = first(get(io, :displaysize, displaysize(io)))
    rows -= 3 # Yuck! This magic number is also in Base.print_matrix
    try
        if limited && length(states(m)) > rows
            slist = collect(take(states(m), rows-1))
            truncated = true
        else
            slist = collect(states(m))
        end
    catch ex
        @info("""Unable to pretty-print policy:
              $(sprint(showerror, ex))
              """)
        show(io, mime, m)
        return show(io, mime, p)
    end
    showpolicy(io, mime, slist, p; pre=pre, kwargs...)
    if truncated
        print(io, '\n', pre, "…")
    end
end

function showpolicy(io::IO, mime::MIME"text/plain", slist::AbstractVector, p::Policy; pre::AbstractString=" ")
    S = eltype(slist)
    sa_con = IOContext(io, :compact => true)

    if !isempty(slist)
        # print first element without a newline
        print(io, pre)
        print_sa(sa_con, first(slist), p, S)

        # print all other elements
        for s in slist[2:end]
            print(io, '\n', pre)
            print_sa(sa_con, s, p, S)
        end
    end
end

showpolicy(io::IO, m::Union{MDP,AbstractVector}, p::Policy; kwargs...) = showpolicy(io, MIME("text/plain"), m, p; kwargs...)
showpolicy(m::Union{MDP,AbstractVector}, p::Policy; kwargs...) = showpolicy(stdout, m, p; kwargs...)

function print_sa(io::IO, s, p::Policy, S::Type)
    show(IOContext(io, :typeinfo => S), s)
    print(io, " -> ")
    try
        show(io, action(p, s))
    catch ex
        showerror(IOContext(io, :limit=>true), ex)
    end
end
