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

        "Defining POMDP Models" => [
            "def_pomdp.md",
            "explicit.md",
            "generative.md",
            "requirements.md",
            "interfaces.md"
           ],


        "Writing Solvers and Updaters" => [
            "def_solver.md",
            "specifying_requirements.md",
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
