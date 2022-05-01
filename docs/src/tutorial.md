# Tutorial

## Creating a MIP Solver using a LP solver

In this short tutorial you'll use a LP solver [HiGHS.jl](https://github.com/jump-dev/HiGHS.jl) and use it as a MIP solver.
**Attention:** HiGHS itself can solve MIP problems as well so if you don't want to experiment with your own branching strategies you probably don't want to use Bonobo.

First we create the LP problem using [JuMP.jl](https://github.com/jump-dev/JuMP.jl) and HiGHS.jl:

```
using Bonobo
using JuMP
using HiGHS

const BB = Bonobo
```

Those need to be installed with `] add Bonobo, JuMP, HiGHS`.

A standard LP model:
```
m = Model(HiGHS.Optimizer)
set_optimizer_attribute(m, "log_to_console", false)
@variable(m, x[1:3] >= 0)
@constraint(m, 0.5x[1]+3.1x[2]+4.2x[3] >= 6.1)   
@constraint(m, 1.9x[1]+0.7x[2]+0.2x[3] >= 8.1)   
@constraint(m, 2.9x[1]-2.3x[2]+4.2x[3] >= 10.5)   
@objective(m, Min, x[1]+1.2x[2]+3.2x[3])
```

Now we need to initialize the branch and bound solver:

```
bnb_model = BB.initialize(; 
    branch_strategy = BB.MOST_INFEASIBLE,
    Node = MIPNode,
    root = m,
    sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min
)
```

Here we use the branch strategy `MOST_INFEASIBLE`, we want to use our own node type `MIPNode` which shall hold information about the current lower and upper bounds of each variable. Then we give Bonobo the model/root information and the objective sense.

Let's define our `MIPNode`:
```
mutable struct MIPNode <: AbstractNode
    std :: BnBNodeInfo
    lbs :: Vector{Float64}
    ubs :: Vector{Float64}
    status :: MOI.TerminationStatusCode
end
```

The two things we need to be aware of is that it has to be an `AbstractNode` and it needs the field: `std::BnBNodeInfo`.

The [`initialize`](@ref) function also calls `get_branching_indices(::Model)` where `Model` is the type of our root node.
There one needs to specify the variables that one can branch on. In our case we want to branch on all variables so we define:

```
function BB.get_branching_indices(model::JuMP.Model)
    # every variable should be discrete
    vis = MOI.get(model, MOI.ListOfVariableIndices())
    return 1:length(vis)
end
```

Next we need to specify the information we have about the root node using [`set_root!`](@ref). This will be the info that is send to [`evaluate_node!`](@ref) at the very beginning.

```
BB.set_root!(bnb_model, (
    lbs = zeros(length(x)),
    ubs = fill(Inf, length(x)),
    status = MOI.OPTIMIZE_NOT_CALLED
))
```
We define the lower bounds of each variable as `0` as we defined them in the model `@variable(m, x[1:3] >= 0)`.
There are no upper bounds. We also specify the status of this node. Important is that we specify all fields of our `MIPNode` besides the `std` field.

Now we can call [`optimize!`](ref) and see which methods still need to be implemented.

```
BB.optimize!(bnb_model)
```

It will show the following error:
```
ERROR: MethodError: no method matching evaluate_node!(::BnBTree{MIPNode, Model, Vector{Float64}, Bonobo.DefaultSolution{MIPNode, Vector{Float64}}}, ::MIPNode)
```

This means we need to define a method to evaluate a node and return back a lower and upper bound.

```
function BB.evaluate_node!(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode)
    m = tree.root # this is the JuMP.Model
    vids = MOI.get(m ,MOI.ListOfVariableIndices())
    # we set the bounds for the current node based on `node.lbs` and `node.ubs`.
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

    # get the relaxed solution of the current model using HiGHS
    optimize!(m)
    status = termination_status(m)
    node.status = status
    # if it is infeasible we return `NaN` for bother lower and upper bound
    if status != MOI.OPTIMAL
        return NaN,NaN
    end

    obj_val = objective_value(m)
    # we check whether the values are approximately feasible (are integer)
    # in that case we return the same value for lower and upper bound for this node
    if all(BB.is_approx_feasible.(tree, value.(vars)))
        node.ub = obj_val
        return obj_val, obj_val
    end
    # otherwise we only have a lower bound
    return obj_val, NaN
end
```

now calling `BB.optimize!(bnb_model)` again will give the following error:

```
ERROR: MethodError: no method matching get_relaxed_values(::BnBTree{MIPNode, Model, Vector{Float64}, Bonobo.DefaultSolution{MIPNode, Vector{Float64}}}, ::MIPNode)
Stacktrace:
 [1] get_branching_variable(tree::BnBTree{MIPNode, Model, Vector{Float64}, Bonobo.DefaultSolution{MIPNode, Vector{Float64}}}, #unused#::Bonobo.MOST_INFEASIBLE, node::MIPNode)
```

This gets called to figure out the next branching variable as you can see in the stacktrace where we can see that the `::MOST_INFEASIBLE` strategy is used as specified in the [`initialize`](@ref) call.

```
function BB.get_relaxed_values(tree::BnBTree{MIPNode, JuMP.Model}, node)
    vids = MOI.get(tree.root, MOI.ListOfVariableIndices())
    vars = VariableRef.(tree.root, vids)
    return JuMP.value.(vars)
end
```

We simply need to return the current values of all the variables.
The last thing we need to implement is how we want to branch on a node by defining [`get_branching_nodes_info`](@ref).


It takes as input the `tree`, the current `node` as well as the variable index to branch on. 
This function shall return all information about new nodes we want to create.
In our case we want to create two new nodes one where we set the upper bound below the current relaxed value and one where we set the lower bound about the
relaxed value. The only thing one needs to take care of is that one doesn't remove an actual discrete solution by splitting up the current problem into 
two or more subproblems.

The information for the nodes needs to be returned as a vector of `NamedTuple` which consist of the same fields as in the `set_root!` call earlier.

```
function BB.get_branching_nodes_info(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode, vidx::Int)
    m = tree.root
    node_info = NamedTuple[]

    var = VariableRef(m, MOI.VariableIndex(vidx))

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
```


Now we can actually solve our problem with `BB.optimize!(bnb_model)`.
Afterwards we can retrieve the optimal solution with:

```
julia> BB.get_solution(bnb_model)
3-element Vector{Float64}:
 5.999999999999998
 1.0
 0.0
```

and the objective value:

```
julia> BB.get_objective_value(bnb_model)
7.199999999999998
```

### Recap

The main three functions that need to be called to optimize a problem using Bonobo are for using it as a JuMP MIP solver are
[`initialize`](@ref), [`set_root!`](@ref) and [`optimize!](@ref).

```
m = Model(HiGHS.Optimizer)
set_optimizer_attribute(m, "log_to_console", false)
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
```

The functions that get called internally and need to be implemented are:
[`get_branching_indices`](@ref), [`evaluate_node!`](@ref), [`get_relaxed_values`] and [`get_branching_nodes_info`](@ref).

