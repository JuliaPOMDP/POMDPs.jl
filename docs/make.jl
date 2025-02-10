push!(LOAD_PATH, "../src/")

using Documenter, POMDPs, POMDPTools

page_order = [
    "POMDPs.jl" => "index.md",
    "Basics" => [
        "install.md",
        "get_started.md",
        "concepts.md"
    ],
    "Defining (PO)MDP Models" => [
        "def_pomdp.md",
        "interfaces.md"
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
    "References" => [
        "faq.md",
        "api.md"
    ]
]

# Append the @contents blocks to the index.md file
index_md_file = joinpath(@__DIR__, "src", "index.md")

# Copy original index.md to restore it after the build
original_index_md_file = joinpath(@__DIR__, "src", "original_index.md")
cp(index_md_file, original_index_md_file)

open(index_md_file, "a") do f
    write(f, "\n\n")
    # Loop over the sections and generate a @contents block for each.
    for (section, pages) in page_order
        if section isa String && pages isa Vector{String}  # Only sections with pages
            write(f, "### $(section)\n\n")
            write(f, "```@contents\n")
            write(f, "Pages = $(pages)\n")
            if section == "Defining (PO)MDP Models"
                write(f, "Depth = 3\n")
            else
                write(f, "Depth = 2\n")
            end
            write(f, "```\n\n")
        end
    end
end

makedocs(
    modules = [POMDPs, POMDPTools],
    format = Documenter.HTML(),
    sitename = "POMDPs.jl",
    pages = page_order,
    warnonly = [:missing_docs]
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPs.jl.git",
    push_preview=true
)

# Restore the original index.md file
if isfile(original_index_md_file)
    mv(original_index_md_file, index_md_file, force=true)
end
