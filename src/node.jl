"""
    set_root!(tree::BnBTree, node_info::NamedTuple)

Set the root node information based on the `node_info` which needs to include the same fields as the `Node` struct given 
to the [`initialize`](@ref) method. (Besides the `std` field which is set by Bonobo automatically)

# Example
If your node structure is the following:
```julia
mutable struct MIPNode <: AbstractNode
    std :: BnBNode
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
    add_node!(tree, node_info)
end

"""
    add_node!(tree::BnBTree{Node}, node_info::NamedTuple)

Add a new node to the tree using the `node_info`. For information on that see [`set_root!`](@ref).
"""
function add_node!(tree::BnBTree{Node}, node_info::NamedTuple) where Node <: AbstractNode
    node_id = tree.num_nodes + 1
    node = create_node(Node, node_id, node_info)
    tree.nodes[node_id] = node
    tree.num_nodes += 1
end

"""
    create_node(Node, node_id::Int, node_info::NamedTuple)

Creates a node of type `Node` with id `node_id` and the named tuple `node_info`. 
For information on that see [`set_root!`](@ref).
"""
function create_node(Node, node_id::Int, node_info::NamedTuple)
    bnb_node = structfromnt(BnBNode, (id = node_id, lb = -Inf, ub = Inf))
    bnb_nt = (std = bnb_node,)
    node_nt = merge(bnb_nt, node_info)
    return structfromnt(Node, node_nt)
end

"""
    get_next_node(tree::BnBTree, travese_strategy::BFS)

Get the next node of the tree which shall be evaluted next by [`evaluate_node!`](@ref).
If you want to implement your own traversing strategy check out [`AbstractTraverseStrategy`](@ref).
"""
function get_next_node(tree::BnBTree, travese_strategy::BFS)
    _, node = peek(tree.nodes)
    return node
end

function Base.isless(n1::AbstractNode, n2::AbstractNode)
    if n1.lb < n2.lb
        return true
    elseif n1.lb == n2.lb
        return n1.id < n2.id
    end
    return false
end

"""
    evaluate_node!(tree, node)

Evaluate the current node and return the lower and upper bound of that node.
"""
function evaluate_node! end