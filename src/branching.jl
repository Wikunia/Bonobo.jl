"""
    branch!(tree, node)

Get the branching variable with [`get_branching_variable`](@ref) and then calls [`get_branching_nodes_info`](@ref) and [`add_node!`](@ref).
"""
function branch!(tree, node)
    variable_idx = get_branching_variable(tree, tree.options.branch_strategy, node)
    # no branching variable selected => return
    variable_idx == -1 && return 
    nodes_info = get_branching_nodes_info(tree, node, variable_idx)
    for node_info in nodes_info
        add_node!(tree, nodes_info)
    end
end

"""
    get_branching_variable(tree::BnBTree, ::FIRST, node::AbstractNode)

Return the first possible branching variable which should be discrete based on `tree.discrete_indices`
and is currently not discrete based on [`is_approx_discrete`](@ref).
Return `-1` if all integer constraints are respected.
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

Return the branching variable which is furthest away from being discrete
or `-1` if all integer constraints are respected.
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
    get_branching_nodes_info(tree::BnBTree, node::AbstractNode, vidx::Int)

Create the information for new branching nodes based on the variable index `vidx`.
Return a list of those information as a `NamedTuple` vector.

# Example
The following would add the necessary information about a new node and return it. The necessary information are the fields required by the [`AbstractNode`](@ref).
For this examle the required fields are the lower and upper bounds of the variables as well as the status of the node.
```julia
nodes_info = NamedTuple[]
push!(nodes_info, (
    lbs = lbs,
    ubs = ubs,
    status = MOI.OPTIMIZE_NOT_CALLED,
))
return nodes_info
```
"""
function get_branching_nodes_info end
