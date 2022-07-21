struct TerminalTestMDP <: MDP{Union{Int,TerminalState}, Int} end
@test terminalstate == terminalstate
@test isterminal(TerminalTestMDP(), terminalstate)
@test promote_type(Int, TerminalState) == Union{Int, TerminalState}
@test typeof([1,terminalstate]) == Vector{statetype(TerminalTestMDP())}
