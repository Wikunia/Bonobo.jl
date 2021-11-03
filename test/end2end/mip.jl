
mutable struct MIPNode <: AbstractNode
    std :: BnBNode
    lbs :: Vector{Float64}
    ubs :: Vector{Float64}
    status :: MOI.TerminationStatusCode
end

function BB.get_relaxed_values(tree::BnBTree{MIPNode, JuMP.Model}, node)
    vids = MOI.get(tree.root ,MOI.ListOfVariableIndices())
    vars = VariableRef.(tree.root, vids)
    return JuMP.value.(vars)
end

_ci(vi::MOI.VariableIndex, S::Type) = MOI.ConstraintIndex{MOI.SingleVariable, S}(vi.value)

function BB.get_discrete_indices(model::JuMP.Model)
    vis = MOI.get(model, MOI.ListOfVariableIndices())
    integer_bool_arr = map(vis) do vi
        MOI.is_valid(model.moi_backend, _ci(vi, MOI.Integer))
    end
    binary_bool_arr = map(vis) do vi
        MOI.is_valid(model.moi_backend, _ci(vi, MOI.ZeroOne))
    end
    return findall(integer_bool_arr .| binary_bool_arr)
end

function BB.evaluate_node!(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode)
    m = tree.root
    vids = MOI.get(m ,MOI.ListOfVariableIndices())
    vars = VariableRef.(m, vids)
    JuMP.set_lower_bound.(vars, node.lbs)
    JuMP.set_upper_bound.(vars, node.ubs)

    optimize!(m)
    status = termination_status(m)
    node.status = status
    if status != MOI.OPTIMAL
        return NaN,NaN
    end

    obj_val = objective_value(m)
    if all(isapprox_discrete.(value.(vars)))
        node.ub = obj_val
        return obj_val, obj_val
    end
    return obj_val, NaN
end

function BB.branch!(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode)
    !isinf(node.ub) && return
    node.status != MOI.OPTIMAL && return 
    m = tree.root
    vids = MOI.get(m ,MOI.ListOfVariableIndices())
    vars = VariableRef.(m, vids)
    # first variable which is not discrete

    lbs = copy(node.lbs)
    ubs = copy(node.ubs)

    vx = value.(vars)
    for (i,x) in enumerate(vx)
        if !isapprox_discrete(x)
            # left child set upper bound
            ubs[i] = floor(Int, x)

            BB.add_node!(tree, (
                lbs = copy(node.lbs),
                ubs = ubs,
                status = MOI.OPTIMIZE_NOT_CALLED,
            ))

            # left child set upper bound
            lbs[i] = ceil(Int, x)

            BB.add_node!(tree, (
                lbs = lbs,
                ubs = copy(node.ubs),
                status = MOI.OPTIMIZE_NOT_CALLED,
            ))
            break
        end
    end
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