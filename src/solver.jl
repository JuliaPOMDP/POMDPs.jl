abstract Solver{S,A,O}

@pomdp_func create_policy{S,A,O}(solver::Solver{S,A,O}, pomdp::POMDP{S,A,O})
@pomdp_func solve{S,A,O}(solver::Solver{S,A,O}, pomdp::POMDP{S,A,O}, policy=create_policy(solver, pomdp))
