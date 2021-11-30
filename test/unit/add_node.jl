struct TestRoot end

#=
    Test that adding a new node inherits the lower bound from its parent
=#
@testset "Adding node after evaluating root node" begin 
    function BB.get_branching_indices(tree::TestRoot)
        return [1]
    end

    function BB.evaluate_node!(tree::BnBTree{BB.DefaultNode, TestRoot}, node::BB.DefaultNode)
        return 0.0, Inf
    end

    bnb_model = BB.initialize(; 
        branch_strategy = BB.MOST_INFEASIBLE,
        root = TestRoot(),
        sense = :Min
    )
    BB.set_root!(bnb_model, NamedTuple())
    root = BB.get_next_node(bnb_model, BB.BFS())
    lb, ub = BB.evaluate_node!(bnb_model, root)
    BB.set_node_bound!(bnb_model.sense, root, lb, ub)

    # adding a new node with the root as parent
    BB.add_node!(bnb_model, root, NamedTuple())
    last_node_id = bnb_model.num_nodes
    @test bnb_model.nodes[last_node_id].lb == 0.0
end
