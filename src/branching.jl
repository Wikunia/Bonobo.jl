function branch!(tree, node)
    variable = get_branching_variable(tree, tree.options.branch_strategy, node)
    branch_on_variable!(tree, node, variable)
end

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

function branch_on_variable! end