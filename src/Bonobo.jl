module Bonobo

using DataStructures
using NamedTupleTools

abstract type AbstractNode end
abstract type AbstractSolution end
mutable struct BnBNode
    id :: Int
    lb :: Float64 
    ub :: Float64
end

mutable struct DefaultNode <: AbstractNode
    std :: BnBNode
end

mutable struct DefaultSolution{Node<:AbstractNode} <: AbstractSolution
    objective :: Float64
    solution  :: Vector{Float64}
    node      :: Node
end

mutable struct BnBTree{Node<:AbstractNode,Root<:Any,Solution<:AbstractSolution}
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

function initialize(;
    traverse = :BFS,
    Node = DefaultNode,
    Solution = DefaultSolution,
    root = nothing,
    sense = :Min
)
    return BnBTree(
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

function optimize!(tree::BnBTree)
    while !terminated(tree)
        node = get_next_node(tree)
        evaluate_node!(tree, node)

        update_best_bound!(tree, node)
        update_best_solution!(tree, node)

        heuristics!(tree, node)
        close_node!(tree, node)
        branch!(tree, node)
    end
end

terminated(tree::BnBTree) = isempty(tree.nodes)

function update_best_bound!(tree::BnBTree, node::AbstractNode)
    isinf(node.lb) && return
    node.lb <= tree.lb && return

    tree.lb = node.lb

    bound!(tree, node.id)
end

function bound!(tree::BnBTree, current_node_id)
    for (_,node) in tree.nodes
        if node.id != current_node_id && node.lb >= tree.lb
            close_node!(tree, node)
        end
    end
end

close_node!(tree::BnBTree, node::AbstractNode) = delete!(tree.nodes, node.id)

function update_best_solution!(tree::BnBTree, node::AbstractNode)
    isinf(node.ub) && return
    node.ub >= tree.incumbent && return

    tree.incumbent = node.ub

    add_new_solution!(tree, node)
end

function add_new_solution!(tree::BnBTree{N,R,S}, node::AbstractNode) where {N,R,S<:DefaultSolution}
    sol = DefaultSolution(node.ub, get_relaxed_values(tree), node)
    if isempty(tree.solutions)
        push!(tree.solutions, sol)
    else
        tree.solutions[1] = sol
    end
end

heuristics!(tree::BnBTree, node::AbstractNode) = nothing
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

export BnBTree, BnBNode, AbstractNode, isapprox_discrete

end
