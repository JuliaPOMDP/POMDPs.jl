push!(LOAD_PATH, "../src/")

using Documenter, POMDPs, POMDPTools

makedocs(
    modules = [POMDPs, POMDPTools],
    format = Documenter.HTML(),
    sitename = "POMDPs.jl",
    pages = [
        ##############################################
        ## MAKE SURE TO SYNC WITH docs/src/index.md ##
        ##############################################
        "Basics" => [
            "index.md",
            "install.md",
            "get_started.md",
            "concepts.md"
           ],

        "Defining (PO)MDP Models" => [
            "def_pomdp.md",
            "interfaces.md",
           ],

        "Writing Solvers" => [
            "def_solver.md",
            "offline_solver.md",
            "online_solver.md"
           ],

        "Writing Belief Updaters" => [
            "def_updater.md"
           ],

        "Analyzing Results" => [
            "simulation.md",
            "run_simulation.md",
            "policy_interaction.md"
           ],
           
        "Examples and Gallery" => [
            "examples.md",
            "example_defining_problems.md",
            "example_solvers.md",
            "example_simulations.md",
            "example_gridworld_mdp.md",
            "gallery.md"
           ],

        "POMDPTools" => [
            "POMDPTools/index.md",
            "POMDPTools/distributions.md",
            "POMDPTools/model.md",
            "POMDPTools/visualization.md",
            "POMDPTools/beliefs.md",
            "POMDPTools/policies.md",
            "POMDPTools/simulators.md",
            "POMDPTools/common_rl.md",
            "POMDPTools/testing.md"
           ],

        "faq.md",
        "api.md",

    ],
    warnonly = [:missing_docs]
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPs.jl.git",
    push_preview=true
)
