struct DisplaySimulator
    display::Union{AbstractDisplay, Nothing}
    render_kwargs
    max_fps::Float64
    predisplay::Function
    extra_initial::Bool
    extra_final::Bool
    stepsim::StepSimulator
end

"""
    DisplaySimulator(;kwargs...)

Create a simulator that displays each step of a simulation.

Given a POMDP or MDP model `m`, this simulator roughly works like

    for step in stepthrough(m, ...)
        display(render(m, step))
    end

# Keyword Arguments
- `display::AbstractDisplay`: the display to use for the first argument to the `display` function. If this is `nothing`, `display(...)` will be called without an `AbstractDisplay` argument.
- `render_kwargs::NamedTuple`: keyword arguments for `POMDPModelTools.render(...)`
- `max_fps::Number=10`: maximum number of frames to be displayed per second - `sleep` will be used to skip extra time, so this is not designed for high precision
- `predisplay::Function`: function to call before every call to `display(...)`. The only argument to this function will be the display (if it is specified) or `nothing`
- `extra_initial::Bool=false`: if `true`, display an extra step at the beginning with only elements `t`, `sp`, and `bp` for POMDPs (this can be useful to see the initial state if `render` displays only `sp` and not `s`).
- `extra_final`::Bool=true`: if `true`, display an extra step at the end with only elements `t`, `done`, `s`, and `b` for POMDPs (this can be useful to see the final state if `render` displays only `s` and not `sp`).
- `max_steps::Integer`: maximum number of steps to run for
- `spec::NTuple{Symbol}`: specification of what step elements to display (see `eachstep`)
- `rng::AbstractRNG`: random number generator

See the POMDPSimulators documentation for more tips about using specific displays.
"""
function DisplaySimulator(;display=nothing,
                           render_kwargs=NamedTuple(),
                           max_fps=10,
                           predisplay=(d)->nothing,
                           extra_initial=false,
                           extra_final=true,
                           max_steps=nothing,
                           spec=CompleteSpec(),
                           rng=Random.GLOBAL_RNG
                         )
    stepsim = StepSimulator(rng, max_steps, spec)
    return DisplaySimulator(display,
                            render_kwargs,
                            max_fps,
                            predisplay,
                            extra_initial,
                            extra_final,
                            stepsim)
end

function simulate(sim::DisplaySimulator, m, args...)
    rsum = 0.0
    disc = 1.0
    dt = 1/sim.max_fps
    tm = time()
    isinitial = true
    last = NamedTuple() # for extra_final

    for step in simulate(sim.stepsim, m, args...)
        if isinitial && sim.extra_initial
            isinitial = false
            istep = initialstep(m, step)
            vis = render(m, istep; sim.render_kwargs...)
            perform_display(sim, vis)
            sleep_until(tm += dt)
        end

        vis = render(m, step; sim.render_kwargs...)
        perform_display(sim, vis)
        rsum += disc*get(step, :r, missing)
        disc *= discount(m)
        sleep_until(tm += dt)

        last = step # save for extra final
    end

    if sim.extra_final
        fstep = finalstep(m, last)
        vis = render(m, fstep; sim.render_kwargs...)
        perform_display(sim, vis)
    end

    if ismissing(rsum)
        return nothing
    else
        return rsum
    end
end

sleep_until(t) = sleep(max(t-time(), 0.0))

initialstep(m::MDP, step) = (t=0, sp=get(step, :s, missing))
initialstep(m::POMDP, step) = (t=0,
                               sp=get(step, :s, missing),
                               bp=get(step, :b, missing))
finalstep(m::MDP, last) = (done=true,
                           t=get(last, :t, missing) + 1,
                           s=get(last, :sp, missing))
finalstep(m::POMDP, last) = (done=true,
                             t=get(last, :t, missing) + 1,
                             s=get(last, :sp, missing),
                             b=get(last, :bp, missing))

function perform_display(sim::DisplaySimulator, vis)
    sim.predisplay(sim.display)
    if sim.display===nothing
        display(vis)
    else
        display(sim.display, vis)
    end
end
