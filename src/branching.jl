"""
    branch!(tree, node)

Get the branching variable with [`get_branching_variable`](@ref) and then calls [`branch_on_variable!`](@ref).
"""
function branch!(tree, node)
    variable = get_branching_variable(tree, tree.options.branch_strategy, node)
    branch_on_variable!(tree, node, variable)
end

"""
    get_branching_variable(tree::BnBTree, ::FIRST, node::AbstractNode)

Return the first possible branching variable which should be discrete based on `tree.discrete_indices`
and is currently not discrete based on [`is_approx_discrete`](@ref).
"""
function get_branching_variable(tree::BnBTree, ::FIRST, node::AbstractNode)
    values = get_relaxed_values(tree, node)
    for i in tree.discrete_indices
        value = values[i]
        if !is_approx_discrete(tree, value)
            return i
        end
    end
    return -1
end

"""
    get_branching_variable(tree::BnBTree, ::MOST_INFEASIBLE, node::AbstractNode)

Return the branching variable which is furthest away from being discrete.
"""
function get_branching_variable(tree::BnBTree, ::MOST_INFEASIBLE, node::AbstractNode)
    values = get_relaxed_values(tree, node)
    best_idx = -1
    max_distance_to_feasible = 0.0
    for i in tree.discrete_indices
        value = values[i]
        if !is_approx_discrete(tree, value)
            distance_to_feasible = abs(round(value)-value)
            if distance_to_feasible > max_distance_to_feasible
                best_idx = i
                max_distance_to_feasible = distance_to_feasible
            end
        end
    end
    return best_idx
end

"""
    branch_on_variable!(tree::BnBTree, node::AbstractNode, vidx::Int)

Create new branching nodes based on the variable index `vidx`.

# Example
A new node can be created with the [`add_node!`](@ref) function.

The following would create a new node with the additional fields required by the [`AbstractNode`](@ref).
For this examle the required fields are the lower and upper bounds of the variables as well as the status of the node.
```julia
Bonobo.add_node!(tree, (
    lbs = lbs,
    ubs = ubs,
    status = MOI.OPTIMIZE_NOT_CALLED,
))
```
"""
function branch_on_variable! end
