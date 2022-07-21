struct DummyRoot end

BB.get_branching_indices(::DummyRoot) = 1:1

function BB.evaluate_node!(tree::BnBTree{BB.DefaultNode, DummyRoot}, node::BB.DefaultNode)
    lb = -0.9
    ub = sum(BB.get_relaxed_values(tree, node))
    if node.id % 2 == 0
        lb = 1.0
        ub = 1.0
    end
    return lb, ub
end

function BB.get_relaxed_values(::BnBTree{BB.DefaultNode, DummyRoot}, node::BB.DefaultNode)
    return [-node.id/10]
end

function BB.get_branching_nodes_info(tree::BnBTree{BB.DefaultNode, DummyRoot}, node::BB.DefaultNode, vidx::Int)
    node_info = NamedTuple[]
    push!(node_info, NamedTuple())
    push!(node_info, NamedTuple())
    return node_info
end

function dummy_callback(tree, node; node_infeasible=false, worse_than_incumbent=false)
    if node.id % 2 == 0
        @test worse_than_incumbent
    else 
        @test !worse_than_incumbent
    end
    @test !node_infeasible
end

@testset "Dummy callback" begin
    bnb_model = BB.initialize(; 
        root = DummyRoot(),
        sense = :Min
    )
   
    BB.set_root!(bnb_model, NamedTuple())

    BB.optimize!(bnb_model; callback=dummy_callback)

    @test -0.9 ≈ BB.get_solution(bnb_model)[1]
    @test BB.get_objective_value(bnb_model) ≈ -0.9

    @test BB.get_num_solutions(bnb_model) > 1
    @test BB.get_objective_value(bnb_model; result=2) >  BB.get_objective_value(bnb_model; result=1)
end