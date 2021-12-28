
mutable struct MIPNode <: AbstractNode
    std :: BnBNodeInfo
    lbs :: Vector{Float64}
    ubs :: Vector{Float64}
    status :: MOI.TerminationStatusCode
end

function BB.get_relaxed_values(tree::BnBTree{MIPNode, JuMP.Model}, node)
    vids = MOI.get(tree.root ,MOI.ListOfVariableIndices())
    vars = VariableRef.(tree.root, vids)
    return JuMP.value.(vars)
end

function BB.get_branching_indices(model::JuMP.Model)
    # every variable should be discrete
    vis = MOI.get(model, MOI.ListOfVariableIndices())
    return 1:length(vis)
end

function BB.evaluate_node!(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode)
    m = tree.root
    vids = MOI.get(m ,MOI.ListOfVariableIndices())
    vars = VariableRef.(m, vids)
    for vidx in eachindex(vars)
        if isfinite(node.lbs[vidx])
            JuMP.set_lower_bound(vars[vidx], node.lbs[vidx])
        elseif node.lbs[vidx] == -Inf && JuMP.has_lower_bound(vars[vidx])
            JuMP.delete_lower_bound(vars[vidx])
        elseif node.lbs[vidx] == Inf # making problem infeasible
            error("Invalid lower bound for variable $vidx: $(node.lbs[vidx])")
        end
        if isfinite(node.ubs[vidx])
            JuMP.set_upper_bound(vars[vidx], node.ubs[vidx])
        elseif node.ubs[vidx] == Inf && JuMP.has_upper_bound(vars[vidx])
            JuMP.delete_upper_bound(vars[vidx])
        elseif node.ubs[vidx] == -Inf # making problem infeasible
            error("Invalid upper bound for variable $vidx: $(node.lbs[vidx])")
        end
    end

    optimize!(m)
    status = termination_status(m)
    node.status = status
    if status != MOI.OPTIMAL
        return NaN,NaN
    end

    obj_val = objective_value(m)
    if all(BB.is_approx_feasible.(tree, value.(vars)))
        node.ub = obj_val
        return obj_val, obj_val
    end
    return obj_val, NaN
end

function BB.get_branching_nodes_info(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode, vidx::Int)
    m = tree.root
    node_info = NamedTuple[]

    var = VariableRef(m, MOI.VariableIndex(vidx))

    # first variable which is not discrete
    lbs = copy(node.lbs)
    ubs = copy(node.ubs)

    val = JuMP.value(var)

    # left child set upper bound
    ubs[vidx] = floor(Int, val)

    push!(node_info, (
        lbs = copy(node.lbs),
        ubs = ubs,
        status = MOI.OPTIMIZE_NOT_CALLED,
    ))

    # right child set lower bound
    lbs[vidx] = ceil(Int, val)

    push!(node_info, (
        lbs = lbs,
        ubs = copy(node.ubs),
        status = MOI.OPTIMIZE_NOT_CALLED,
    ))
    return node_info
end

@testset "MIP Problem with 3 variables" begin
    m = Model(Cbc.Optimizer)
    set_optimizer_attribute(m, "logLevel", 0)
    @variable(m, x[1:3] >= 0)
    @constraint(m, 0.5x[1]+3.1x[2]+4.2x[3] <= 6.1)   
    @constraint(m, 1.9x[1]+0.7x[2]+0.2x[3] <= 8.1)   
    @constraint(m, 2.9x[1]-2.3x[2]+4.2x[3] <= 10.5)   
    @objective(m, Max, x[1]+1.2x[2]+3.2x[3])

    bnb_model = BB.initialize(; 
        traverse_strategy = BB.BFS,
        Node = MIPNode,
        root = m,
        sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min
    )
    BB.set_root!(bnb_model, (
        lbs = zeros(length(x)),
        ubs = fill(Inf, length(x)),
        status = MOI.OPTIMIZE_NOT_CALLED
    ))

    BB.optimize!(bnb_model)

    sol_x = convert.(Int, BB.get_solution(bnb_model))

    @test sol_x == [2,0,1]
    @test BB.get_objective_value(bnb_model) ≈ 5.2
end

@testset "MIP Problem with 3 variables minimize" begin
    m = Model(Cbc.Optimizer)
    set_optimizer_attribute(m, "logLevel", 0)
    @variable(m, x[1:3] >= 0)
    @constraint(m, 0.5x[1]+3.1x[2]+4.2x[3] >= 6.1)   
    @constraint(m, 1.9x[1]+0.7x[2]+0.2x[3] >= 8.1)   
    @constraint(m, 2.9x[1]-2.3x[2]+4.2x[3] >= 10.5)   
    @objective(m, Min, x[1]+1.2x[2]+3.2x[3])

    bnb_model = BB.initialize(; 
        branch_strategy = BB.MOST_INFEASIBLE,
        Node = MIPNode,
        root = m,
        sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min
    )
    BB.set_root!(bnb_model, (
        lbs = zeros(length(x)),
        ubs = fill(Inf, length(x)),
        status = MOI.OPTIMIZE_NOT_CALLED
    ))

    BB.optimize!(bnb_model)

    sol_x = BB.get_solution(bnb_model)

    @test sol_x ≈ [6.0,1.0,0.0]
    @test BB.get_objective_value(bnb_model) ≈ 7.2
end

@testset "MIP Problem with callback" begin
    nr_callback_checks_successful = 0 
    function callback_test(tree, node; kwargs...)
        # test that a node 
        #   where the lower bound is wore than the incumbent
        #   and the node didn't set the incumbent itself 
        # is closed and the keyword: worse_than_incumbent is set
        if node.lb >= tree.incumbent && node.ub != tree.incumbent
            # node should be closed in this case
            @test !haskey(tree.nodes, node.id)
            # in this case one kwarg should be set as worse_than_incumbent
            found = false
            for kwarg in kwargs
                if kwarg.first == :worse_than_incumbent && kwarg.second
                    found = true
                    break
                end
            end
            @test found
            nr_callback_checks_successful += 1
        end
    end

    m = Model(Cbc.Optimizer)
    @variable(m, x[1:3] >= 0)
    @constraint(m, 0.5x[1]+3.1x[2]+4.2x[3] >= 6.1)   
    @constraint(m, 1.9x[1]+0.7x[2]+0.2x[3] >= 8.1)   
    @constraint(m, 2.9x[1]-2.3x[2]+4.2x[3] >= 10.5)   
    @objective(m, Min, x[1]+1.2x[2]+3.2x[3])

    bnb_model = BB.initialize(; 
        branch_strategy = BB.MOST_INFEASIBLE,
        Node = MIPNode,
        root = m,
        sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min
    )
    BB.set_root!(bnb_model, (
        lbs = zeros(length(x)),
        ubs = fill(Inf, length(x)),
        status = MOI.OPTIMIZE_NOT_CALLED
    ))

    BB.optimize!(bnb_model; cb=callback_test)
    @test nr_callback_checks_successful > 0
end
