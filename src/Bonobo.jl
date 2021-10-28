module Bonobo

using DataStructures
using NamedTupleTools

abstract type AbstractNode end
abstract type AbstractSolution{Node<:AbstractNode, Value} end
mutable struct BnBNode
    id :: Int
    lb :: Float64 
    ub :: Float64
end

mutable struct DefaultNode <: AbstractNode
    std :: BnBNode
end

mutable struct DefaultSolution{Node<:AbstractNode,Value} <: AbstractSolution{Node, Value}
    objective :: Float64
    solution  :: Value
    node      :: Node
end

mutable struct BnBTree{Node<:AbstractNode,Root,Value,Solution<:AbstractSolution{Node,Value}}
    incumbent::Float64
    lb::Float64
    solutions::Vector{Solution}
    nodes::PriorityQueue{Int,Node}
    root::Root
    traverse_strategy::Symbol
    num_nodes::Int
    sense::Symbol
end

include("util.jl")
include("node.jl")

"""
    initialize(; kwargs...)

Initialize the branch and bound framework with the the following arguments.
Later it can be dispatched on `BnBTree{Node, Root, Solution}` for various methods.

# Keyword arguments
- `traverse` [`:BFS`] currently the only supported traverse strategy is `BFS`.
- `Node` [`DefaultNode`](@ref) can be special structure which is used to store all information about a node. 
    - needs to have `AbstractNode` as the super type
    - needs to have `std :: BnBNode` as a field (see [`BnBNode`](@ref))
- `Solution` [`DefaultSolution`](@ref) stores the node and several other information about a solution
- `root` [`nothing`] the information about the root problem. The type can be used for dispatching on types 
- `sense` [`:Min`] can be `:Min` or `:Max` depending on the objective sense
- `Value` [`Vector{Float64}`] the type of a solution  

Return a [`BnBTree`](@ref) object which is the input for [`optimize!`](@ref).
"""
function initialize(;
    traverse = :BFS,
    Node = DefaultNode,
    Value = Vector{Float64},
    Solution = DefaultSolution{Node,Value},
    root = nothing,
    sense = :Min,
)
    return BnBTree{Node,typeof(root),Value,Solution}(
        NaN, 
        NaN,
        Vector{Solution}(),
        PriorityQueue{Int,Node}(),
        root,
        traverse,
        0,
        sense,
    )
end

"""
    optimize!(tree::BnBTree)

Optimize the problem using a branch and bound approach. 

The steps are the following:
```julia
while !terminated(tree) # as long as there are open nodes
    # get the next open node depending on the traverse strategy
    node = get_next_node(tree) 
    # needs to be implemented by you
    # Should evaluate the current node and return the lower and upper bound
    # if the problem is infeasible both values should be set to NaN
    lb, ub = evaluate_node!(tree, node) 
    # updates the upper and lower bound of the node struct
    set_node_bound!(tree.sense, node, lb, ub)

    # update the best solution 
    updated = update_best_solution!(tree, node)
    updated && bound!(tree, node.id)
    
    # remove the current node
    close_node!(tree, node)
    # needs to be implemented by you
    # create branches from the current node
    branch!(tree, node)
end
```

every function of the above can be overriden by your own method. 
"""
function optimize!(tree::BnBTree)
    while !terminated(tree)
        node = get_next_node(tree)
        lb, ub = evaluate_node!(tree, node) 
        # if the problem was infeasible we simply close the node and continue
        if isnan(lb) && isnan(ub)
            close_node!(tree, node)
            continue
        end

        set_node_bound!(tree.sense, node, lb, ub)

        updated = update_best_solution!(tree, node)
        updated && bound!(tree, node.id)

        close_node!(tree, node)
        branch!(tree, node)
    end
end

"""
    terminated(tree::BnBTree)

Return true when the branch and bound loop in [`optimize!`](@ref) should be terminated.
Default behavior is to terminate the loop only when no nodes exist in the priority queue.
"""
terminated(tree::BnBTree) = isempty(tree.nodes)

"""
    set_node_bound!(objective_sense::Symbol, node::AbstractNode, lb, ub)

Set the bounds of the `node` object to the lower and upper bound given. 
Internally everything is stored as a minimization problem. Therefore the objective_sense `:Min`/`:Max` is needed.
"""
function set_node_bound!(objective_sense::Symbol, node::AbstractNode, lb, ub)
    if isnan(ub)
        ub = Inf
    end
    if objective_sense == :Min
        node.lb = lb
        node.ub = ub
    else
        node.lb = -lb
        node.ub = -ub
    end
end

"""
    bound!(tree::BnBTree, current_node_id)

Close all nodes which have a lower bound higher or equal to the incumbent
"""
function bound!(tree::BnBTree, current_node_id)
    for (_,node) in tree.nodes
        if node.id != current_node_id && node.lb >= tree.incumbent
            close_node!(tree, node)
        end
    end
end

close_node!(tree::BnBTree, node::AbstractNode) = delete!(tree.nodes, node.id)

function update_best_solution!(tree::BnBTree, node::AbstractNode)
    isinf(node.ub) && return false
    node.ub >= tree.incumbent && return false

    tree.incumbent = node.ub

    add_new_solution!(tree, node)
    return true
end

function add_new_solution!(tree::BnBTree{N,R,V,S}, node::AbstractNode) where {N,R,V,S<:DefaultSolution{N,V}}
    sol = DefaultSolution(node.ub, get_relaxed_values(tree), node)
    if isempty(tree.solutions)
        push!(tree.solutions, sol)
    else
        tree.solutions[1] = sol
    end
end

branch!(tree::BnBTree, node::AbstractNode) = @warn "branch! needs to be implemented by you ;)"

get_relaxed_values(tree::BnBTree) = @warn "get_relaxed_values needs to be implemented by you ;)" 

function get_solution(tree::BnBTree; result=1)
    return tree.solutions[result].solution
end

function get_objective_value(tree::BnBTree; result=1)
    if tree.sense == :Max
        return -tree.solutions[result].objective
    else
        return tree.solutions[result].objective
    end
end

export BnBTree, BnBNode, AbstractNode, AbstractSolution, isapprox_discrete

end
