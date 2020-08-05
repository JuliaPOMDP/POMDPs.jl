# Contributing to POMDPs.jl and the JuliaPOMDP ecosystem

The JuliaPOMDP project enthusiastically welcomes contributions from all community members and users. As outlined in our [code of conduct](/CODE_OF_CONDUCT.md), we are seeking to build a diverse community of contributors. In particular, we encourage new users with **all levels of software development experience** to contribute and are happy to address your questions.

Maintaining a consistent and flexible framework for POMDPs is a challenging goal, and we are striving to develop high quality code and documentation to accomplish this. This means that you should expect other community members to give feedback and ask for improvements to your contribution before we accept it. This is meant to be a positive learning experience, and we ask that everyone give and gracefully accept constructive feedback in accordance with the [code of conduct](/CODE_OF_CONDUCT.md).

Welcome to the JuliaPOMDP community, we are happy to have you here!

## Types of Contributions

There are a variety of ways to contribute to the POMDPs.jl ecosystem. Perhaps the most obvious ways involve writing code to create new functionality, including

- Creating a new solver
- Contributing a sample (PO)MDP model
- Proposing changes to the interface
- Creating new tools for the auxiliary packages

However, it is often even more helpful to make contributions that improve the quality of existing functionality such as

- Pointing out bugs and ambiguities
- Improving documentation
- Writing tests

All contributions begin with the same first step described below.

## Contribution Process

Contributions should usually begin by [opening a new issue](https://github.com/JuliaPOMDP/POMDPs.jl/issues/new) that briefly describes the contribution you would like to make and the problem that it fixes, if there is one (More documentation on issues can be found [here](https://guides.github.com/features/issues/)). This will allow the community to discuss whether the contribution is a good idea before the bulk of effort is put into it.

> **Note**: For minor changes such as fixing a typo, it is usually easiest to [edit the file and open a small pull request directly on github.com](https://docs.github.com/en/github/managing-files-in-a-repository/editing-files-in-another-users-repository) rather then opening an issue.

The JuliaPOMDP team uses [Github Flow](https://guides.github.com/introduction/flow/) to manage development.

> **Note**: Github and git have a steep learning curve for some, but they provide a robust system for collaborating. In particular, unless you are a member of the [JuliaPOMDP github team](https://github.com/orgs/JuliaPOMDP/people), you cannot make permanent changes, and you should feel free to experiment **without worrying about breaking anything**. There are many learning resources that can be found through a web search.

The process differs slightly depending whether you are modifying an existing repo or creating a new one.

### Contributing to existing JuliaPOMDP repositories

If your contribution is making changes to an existing JuliaPOMDP repository such as POMDPs.jl or an existing solver, follow these basic steps:

1. [Fork the repository](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo)
2. Make the changes [on the github site](https://docs.github.com/en/github/managing-files-in-a-repository/editing-files-in-your-repository) or [with git on your computer](https://docs.github.com/en/github/getting-started-with-github/set-up-git).
3. [Open a pull request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) to receive feedback, discuss, and finally merge the changes.

### Creating a new repository

If your contribution involves creating a new repository

1. [Organize your code into a Julia Package](https://tlienart.github.io/pub/julia/dev-pkg.html)
2. [Create a github repository](https://docs.github.com/en/github/getting-started-with-github/create-a-repo) an upload your code.
3. [Transfer ownership of the repository](https://docs.github.com/en/github/administering-a-repository/transferring-a-repository) to the JuliaPOMDP organization. At this point we will check that the repository works, has tests, and is documented.
4. Open a pull request to modify the POMDPs.jl README to link to your new repository.

(These instructions are meant to be an overview. Community members will guide you through the details.)

## Code Principles

The JuliaPOMDP community values performance, clarity, and flexibility in the code that we produce. Fortunately, Julia is designed to make this easy. In general, the principles discussed in the [Julia style guide](https://docs.julialang.org/en/v1/manual/style-guide/) should be used, but in some cases these may be broken to maintain consistency with existing code.

## Documentation Principles

Improving documentation is one of the best ways to contribute to the JuliaPOMDP project, but creating useful documentation requires careful thought. A few important principles and guidelines that we seek to follow are outlined below:
1. [Don't repeat yourself](https://en.wikipedia.org/wiki/Don't_repeat_yourself) (DRY): In order to maintain consistent and correct documentation, it is better to provide links to a single explanation of a concept rather than re-explaining it.
2. Don't provide documentation about the Julia language or programming techniques. This is a special case of DRY. Many users of POMDPs.jl are learning Julia for the first time, but explanations of how Julia works should be provided by links to the [Julia Documentation](https://docs.julialang.org/) rather than in line with POMDPs.jl documentation.
3. Try to fit in to one of the [four types of documentation](https://documentation.divio.com/). Write either a tutorial, how-to guide, explanation, or reference, but try to stick to the goals of that particular genre to produce the most usable documentation.

## Questions About Contributing

This contributions guide is currently brief and geared towards new contributors. If there are any questions, you are encouraged to ask in a new issue or on one of our forums and we will amend this guide.
