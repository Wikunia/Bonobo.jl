function set_root!(tree::BnBTree, node_info::NamedTuple)
    add_node!(tree, node_info)
end

function add_node!(tree::BnBTree{Node}, node_info::NamedTuple) where Node <: AbstractNode
    node_id = tree.num_nodes + 1
    node = create_node(Node, node_id, node_info)
    tree.nodes[node_id] = node
    tree.num_nodes += 1
end

function create_node(Node, node_id::Int, node_info::NamedTuple)
    bnb_node = structfromnt(BnBNode, (id = node_id, lb = -Inf, ub = Inf))
    bnb_nt = (std = bnb_node,)
    node_nt = merge(bnb_nt, node_info)
    return structfromnt(Node, node_nt)
end

function get_next_node(tree::BnBTree)
    id, node = peek(tree.nodes)
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

evaluate_node!(tree, node) = @warn "You have to implement evaluate_node! yourself ;)"