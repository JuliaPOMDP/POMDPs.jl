push!(LOAD_PATH, "../src/")

using Documenter, POMDPs

makedocs(
    modules = [POMDPs],
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
            "static.md",
            "interfaces.md",
            "dynamics.md",
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

        "faq.md",
        "api.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPs.jl.git",
)
