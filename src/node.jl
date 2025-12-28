"""
    set_root!(tree::BnBTree, node_info::NamedTuple)

Set the root node information based on the `node_info` which needs to include the same fields as the `Node` struct given 
to the [`initialize`](@ref) method. (Besides the `std` field which is set by Bonobo automatically)

# Example
If your node structure is the following:
```julia
mutable struct MIPNode <: AbstractNode
    std :: BnBNodeInfo
    lbs :: Vector{Float64}
    ubs :: Vector{Float64}
    status :: MOI.TerminationStatusCode
end
```

then you can call the function with this syntax:

```julia
Bonobo.set_root!(tree, (
    lbs = fill(-Inf, length(x)),
    ubs = fill(Inf, length(x)),
    status = MOI.OPTIMIZE_NOT_CALLED
))
```
"""
function set_root!(tree::BnBTree, node_info::NamedTuple)
    add_node!(tree, nothing, node_info)
end

"""
    add_node!(tree::BnBTree{Node}, parent::Union{AbstractNode, Nothing}, node_info::NamedTuple)

Add a new node to the tree using the `node_info`. For information on that see [`set_root!`](@ref).
"""
function add_node!(tree::BnBTree{Node}, parent::Union{AbstractNode, Nothing}, node_info::NamedTuple) where Node <: AbstractNode
    node_id = tree.num_nodes + 1
    node = create_node(Node, node_id, parent, node_info)
    # only add the node if it's better than the current best solution
    if node.lb < tree.incumbent
        tree.nodes[node_id] = node
        tree.node_queue[node_id] = (node.lb, node_id)
        tree.num_nodes += 1
    end
end

"""
    create_node(Node, node_id::Int, parent::Union{AbstractNode, Nothing}, node_info::NamedTuple)

Creates a node of type `Node` with id `node_id` and the named tuple `node_info`. 
For information on that see [`set_root!`](@ref).
"""
function create_node(Node, node_id::Int, parent::Union{AbstractNode, Nothing}, node_info::NamedTuple)
    lb = -Inf
    depth = 1
    if !isnothing(parent)
        lb = parent.lb
        depth = parent.depth + 1
    end
    bnb_node = structfromnt(BnBNodeInfo, (id = node_id, lb = lb, ub = Inf, depth = depth))
    bnb_nt = (std = bnb_node,)
    node_nt = merge(bnb_nt, node_info)
    return structfromnt(Node, node_nt)
end

"""
    get_next_node(tree::BnBTree, ::BestFirstSearch)

Get the next node of the tree which shall be evaluted next by [`evaluate_node!`](@ref).
If you want to implement your own traversing strategy check out [`AbstractTraverseStrategy`](@ref).
"""
function get_next_node(tree::BnBTree, ::BestFirstSearch)
    node_id, _ = first(tree.node_queue)
    return tree.nodes[node_id]
end

function get_next_node(tree::BnBTree, ::DepthFirstSearch)
    node_id = argmax(k -> tree.nodes[k].depth, keys(tree.nodes))
    return tree.nodes[node_id]
end

"""
    evaluate_node!(tree, node)

Evaluate the current node and return the lower and upper bound of that node.
"""
function evaluate_node! end