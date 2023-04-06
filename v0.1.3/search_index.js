var documenterSearchIndex = {"docs":
[{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"CurrentModule = Bonobo","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [Bonobo]","category":"page"},{"location":"reference/#Bonobo.AbstractBranchStrategy","page":"Reference","title":"Bonobo.AbstractBranchStrategy","text":"AbstractBranchStrategy\n\nThe abstract type for a branching strategy.  If you implement a new branching strategy, this must be the supertype. \n\nIf you want to implement your own strategy, you must implement a new method for get_branching_variable which dispatches on the branch_strategy argument. \n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.AbstractNode","page":"Reference","title":"Bonobo.AbstractNode","text":"AbstractNode\n\nThe abstract type for a tree node. Your own type for Node given to initialize needs to subtype it. The default if you don't provide your own is DefaultNode.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.AbstractSolution","page":"Reference","title":"Bonobo.AbstractSolution","text":"AbstractSolution{Node<:AbstractNode, Value}\n\nThe abstract type for a Solution object. The default is DefaultSolution. It is parameterized by Node and Value where Value is the value which describes the full solution i.e the value for every variable.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.AbstractTraverseStrategy","page":"Reference","title":"Bonobo.AbstractTraverseStrategy","text":"AbstractTraverseStrategy\n\nThe abstract type for a traverse strategy.  If you implement a new traverse strategy this must be the supertype. \n\nIf you want to implement your own strategy the get_next_node function needs a new method  which dispatches on the traverse_strategy argument. \n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.BestFirstSearch","page":"Reference","title":"Bonobo.BestFirstSearch","text":"BestFirstSearch <: AbstractTraverseStrategy\n\nThe BestFirstSearch traverse strategy always picks the node with the lowest bound first. If there is a tie then the smallest node id is used as a tie breaker.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.BnBNodeInfo","page":"Reference","title":"Bonobo.BnBNodeInfo","text":"BnBNodeInfo\n\nHolds the necessary information of every node. This needs to be added by every AbstractNode as std::BnBNodeInfo\n\nid :: Int\nlb :: Float64\nub :: Float64\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.BnBTree","page":"Reference","title":"Bonobo.BnBTree","text":"BnBTree{Node<:AbstractNode,Root,Value,Solution<:AbstractSolution{Node,Value}}\n\nHolds all the information of the branch and bound tree. \n\nincumbent::Float64 - The best objective value found so far. Is stores as problem is a minimization problem\nincumbent_solution::Solution - The currently best solution object\nlb::Float64        - The highest current lower bound \nsolutions::Vector{Solution} - A list of solutions\nnode_queue::PriorityQueue{Int,Tuple{Float64, Int}} - A priority queue with key being the node id and the priority consists of the node lower bound and the node id.\nnodes::Dict{Int, Node}  - A dictionary of all nodes with key being the node id and value the actual node.\nroot::Root      - The root node see [`set_root!`](@ref)\nbranching_indices::Vector{Int} - The indices to be able to branch on used for [`get_branching_variable`](@ref)\nnum_nodes::Int  - The number of nodes created in total\nsense::Symbol   - The objective sense: `:Max` or `:Min`.\noptions::Options  - All options for the branch and bound tree. See [`Options`](@ref).\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.DefaultNode","page":"Reference","title":"Bonobo.DefaultNode","text":"DefaultNode <: AbstractNode\n\nThe default structure for saving node information. Currently this includes only the necessary std::BnBNodeInfo which needs to be part of every AbstractNode.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.DefaultSolution","page":"Reference","title":"Bonobo.DefaultSolution","text":"DefaultSolution{Node<:AbstractNode,Value} <: AbstractSolution{Node, Value}\n\nThe default struct to save a solution of the branch and bound run. It holds\n\nobjective :: Float64\nsolution  :: Value\nnode      :: Node\n\nBoth the Value and the Node type are determined by the initialize method.\n\nsolution holds the information to obtain the solution for example the values of all variables.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.FIRST","page":"Reference","title":"Bonobo.FIRST","text":"FIRST <: AbstractBranchStrategy\n\nThe FIRST strategy always picks the first variable which isn't fixed yet and can be branched on.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.MOST_INFEASIBLE","page":"Reference","title":"Bonobo.MOST_INFEASIBLE","text":"MOST_INFEASIBLE <: AbstractBranchStrategy\n\nThe MOST_INFEASIBLE strategy always picks the variable which is furthest away from being \"fixed\" and can be branched on.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Bonobo.add_new_solution!-Union{Tuple{S}, Tuple{V}, Tuple{R}, Tuple{N}, Tuple{BnBTree{N, R, V, S}, AbstractNode}} where {N, R, V, S<:Bonobo.DefaultSolution{N, V}}","page":"Reference","title":"Bonobo.add_new_solution!","text":"add_new_solution!(tree::BnBTree{N,R,V,S}, node::AbstractNode) where {N,R,V,S<:DefaultSolution{N,V}}\n\nCurrently it changes the general solution itself by calling get_relaxed_values which needs to be implemented by you.\n\nThis function needs to be implemented by you if you have a different type of Solution object than DefaultSolution.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.add_node!-Union{Tuple{Node}, Tuple{BnBTree{Node, Root, Value, Solution} where {Root, Value, Solution<:AbstractSolution{Node, Value}}, Union{Nothing, AbstractNode}, NamedTuple}} where Node<:AbstractNode","page":"Reference","title":"Bonobo.add_node!","text":"add_node!(tree::BnBTree{Node}, parent::Union{AbstractNode, Nothing}, node_info::NamedTuple)\n\nAdd a new node to the tree using the node_info. For information on that see set_root!.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.bound!-Tuple{BnBTree, Int64}","page":"Reference","title":"Bonobo.bound!","text":"bound!(tree::BnBTree, current_node_id::Int)\n\nClose all nodes which have a lower bound higher or equal to the incumbent\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.branch!-Tuple{Any, Any}","page":"Reference","title":"Bonobo.branch!","text":"branch!(tree, node)\n\nGet the branching variable with get_branching_variable and then calls get_branching_nodes_info and add_node!.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.close_node!-Tuple{BnBTree, AbstractNode}","page":"Reference","title":"Bonobo.close_node!","text":"close_node!(tree::BnBTree, node::AbstractNode)\n\nDelete the node from the nodes dictionary and the priority queue.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.create_node-Tuple{Any, Int64, Union{Nothing, AbstractNode}, NamedTuple}","page":"Reference","title":"Bonobo.create_node","text":"create_node(Node, node_id::Int, parent::Union{AbstractNode, Nothing}, node_info::NamedTuple)\n\nCreates a node of type Node with id node_id and the named tuple node_info.  For information on that see set_root!.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.evaluate_node!","page":"Reference","title":"Bonobo.evaluate_node!","text":"evaluate_node!(tree, node)\n\nEvaluate the current node and return the lower and upper bound of that node.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Bonobo.get_branching_indices","page":"Reference","title":"Bonobo.get_branching_indices","text":"get_branching_indices(root)\n\nReturn a vector of variables to branch on from the current root object.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Bonobo.get_branching_nodes_info","page":"Reference","title":"Bonobo.get_branching_nodes_info","text":"get_branching_nodes_info(tree::BnBTree, node::AbstractNode, vidx::Int)\n\nCreate the information for new branching nodes based on the variable index vidx. Return a list of those information as a NamedTuple vector.\n\nExample\n\nThe following would add the necessary information about a new node and return it. The necessary information are the fields required by the AbstractNode. For this examle the required fields are the lower and upper bounds of the variables as well as the status of the node.\n\nnodes_info = NamedTuple[]\npush!(nodes_info, (\n    lbs = lbs,\n    ubs = ubs,\n    status = MOI.OPTIMIZE_NOT_CALLED,\n))\nreturn nodes_info\n\n\n\n\n\n","category":"function"},{"location":"reference/#Bonobo.get_branching_variable-Tuple{BnBTree, Bonobo.FIRST, AbstractNode}","page":"Reference","title":"Bonobo.get_branching_variable","text":"get_branching_variable(tree::BnBTree, ::FIRST, node::AbstractNode)\n\nReturn the first possible branching variable which is a branching variable based on tree.branching_indices and is currently not valid based on is_approx_feasible. Return -1 if all integer constraints are respected.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.get_branching_variable-Tuple{BnBTree, Bonobo.MOST_INFEASIBLE, AbstractNode}","page":"Reference","title":"Bonobo.get_branching_variable","text":"get_branching_variable(tree::BnBTree, ::MOST_INFEASIBLE, node::AbstractNode)\n\nReturn the branching variable which is furthest away from being feasible based on get_distance_to_feasible or -1 if all integer constraints are respected.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.get_distance_to_feasible-Tuple{BnBTree, Number}","page":"Reference","title":"Bonobo.get_distance_to_feasible","text":"get_distance_to_feasible(tree::BnBTree, value)\n\nReturn the distance of feasibility for the given value.\n\nif value::Number this returns the distance to the nearest discrete value\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.get_next_node-Tuple{BnBTree, Bonobo.BestFirstSearch}","page":"Reference","title":"Bonobo.get_next_node","text":"get_next_node(tree::BnBTree, ::BestFirstSearch)\n\nGet the next node of the tree which shall be evaluted next by evaluate_node!. If you want to implement your own traversing strategy check out AbstractTraverseStrategy.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.get_num_solutions-Tuple{BnBTree}","page":"Reference","title":"Bonobo.get_num_solutions","text":"get_num_solutions(tree::BnBTree)\n\nReturn the number of solutions available.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.get_objective_value-Union{Tuple{BnBTree{N, R, V, S}}, Tuple{S}, Tuple{V}, Tuple{R}, Tuple{N}} where {N, R, V, S<:Bonobo.DefaultSolution{N, V}}","page":"Reference","title":"Bonobo.get_objective_value","text":"get_objective_value(tree::BnBTree; result=1)\n\nReturn the objective value\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.get_relaxed_values","page":"Reference","title":"Bonobo.get_relaxed_values","text":"get_relaxed_values(tree::BnBTree, node::AbstractNode)\n\nGet the values of the current node. This is always called only after evaluate_node! is called. It is used to store a Solution object. Return the type of Value given to the initialize method.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Bonobo.get_solution-Union{Tuple{BnBTree{N, R, V, S}}, Tuple{S}, Tuple{V}, Tuple{R}, Tuple{N}} where {N, R, V, S<:Bonobo.DefaultSolution{N, V}}","page":"Reference","title":"Bonobo.get_solution","text":"get_solution(tree::BnBTree; result=1)\n\nReturn the solution values of the problem.  See get_objective_value to obtain the objective value instead.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.initialize-Tuple{}","page":"Reference","title":"Bonobo.initialize","text":"initialize(; kwargs...)\n\nInitialize the branch and bound framework with the the following arguments. Later it can be dispatched on BnBTree{Node, Root, Solution} for various methods.\n\nKeyword arguments\n\ntraverse_strategy [BestFirstSearch] currently the only supported traverse strategy is BestFirstSearch. Should be an AbstractTraverseStrategy\nbranch_strategy [FIRST] currently the only supported branching strategies are FIRST and MOST_INFEASIBLE. Should be an AbstractBranchStrategy\natol [1e-6] the absolute tolerance to check whether a value is discrete\nrtol [1e-6] the relative tolerance to check whether a value is discrete\nNode DefaultNode can be special structure which is used to store all information about a node. \nneeds to have AbstractNode as the super type\nneeds to have std :: BnBNodeInfo as a field (see BnBNodeInfo)\nSolution DefaultSolution stores the node and several other information about a solution\nroot [nothing] the information about the root problem. The type can be used for dispatching on types \nsense [:Min] can be :Min or :Max depending on the objective sense\nValue [Vector{Float64}] the type of a solution  \n\nReturn a BnBTree object which is the input for optimize!.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.is_approx_feasible-Tuple{BnBTree, Number}","page":"Reference","title":"Bonobo.is_approx_feasible","text":"is_approx_feasible(tree::BnBTree, value)\n\nReturn whether a given value is approximately feasible based on the tolerances defined in the tree options. \n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.optimize!-Tuple{BnBTree}","page":"Reference","title":"Bonobo.optimize!","text":"optimize!(tree::BnBTree; callback=(args...; kwargs...)->())\n\nOptimize the problem using a branch and bound approach. \n\nThe steps, repeated until terminated is true, are the following:\n\n# 1. get the next open node depending on the traverse strategy\nnode = get_next_node(tree, tree.options.traverse_strategy)\n# 2. evaluate the current node and return the lower and upper bound\n# if the problem is infeasible both values should be set to NaN\nlb, ub = evaluate_node!(tree, node)\n# 3. update the upper and lower bound of the node struct\nset_node_bound!(tree.sense, node, lb, ub)\n\n# 4. update the best solution\nupdated = update_best_solution!(tree, node)\nupdated && bound!(tree, node.id)\n\n# 5. remove the current node\nclose_node!(tree, node)\n# 6. compute the node children and adds them to the tree\n# internally calls get_branching_variable and branch_on_variable!\nbranch!(tree, node)\n\nA callback function can be provided which will be called whenever a node is closed. It always has the arguments tree and node and is called after the node is closed.  Additionally the callback function must accept additional keyword arguments (kwargs)  which are set in the following ways:\n\nIf the node is infeasible the kwarg node_infeasible is set to true.\nIf the node has a higher lower bound than the incumbent the kwarg worse_than_incumbent is set to true.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.set_node_bound!-Tuple{Symbol, AbstractNode, Any, Any}","page":"Reference","title":"Bonobo.set_node_bound!","text":"set_node_bound!(objective_sense::Symbol, node::AbstractNode, lb, ub)\n\nSet the bounds of the node object to the lower and upper bound given.  Internally everything is stored as a minimization problem. Therefore the objective_sense :Min/:Max is needed.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.set_root!-Tuple{BnBTree, NamedTuple}","page":"Reference","title":"Bonobo.set_root!","text":"set_root!(tree::BnBTree, node_info::NamedTuple)\n\nSet the root node information based on the node_info which needs to include the same fields as the Node struct given  to the initialize method. (Besides the std field which is set by Bonobo automatically)\n\nExample\n\nIf your node structure is the following:\n\nmutable struct MIPNode <: AbstractNode\n    std :: BnBNodeInfo\n    lbs :: Vector{Float64}\n    ubs :: Vector{Float64}\n    status :: MOI.TerminationStatusCode\nend\n\nthen you can call the function with this syntax:\n\nBonobo.set_root!(tree, (\n    lbs = fill(-Inf, length(x)),\n    ubs = fill(Inf, length(x)),\n    status = MOI.OPTIMIZE_NOT_CALLED\n))\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.sort_solutions!-Tuple{Vector{<:AbstractSolution}, Symbol}","page":"Reference","title":"Bonobo.sort_solutions!","text":"sort_solutions!(solutions::Vector{<:AbstractSolution}, sense::Symbol)\n\nSort the solutions vector by objective value such that the best solution is at index 1.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.terminated-Tuple{BnBTree}","page":"Reference","title":"Bonobo.terminated","text":"terminated(tree::BnBTree)\n\nReturn true when the branch-and-bound loop in optimize! should be terminated. Default behavior is to terminate the loop only when no nodes exist in the priority queue or when the relative or absolute duality gap are below the tolerances fixed in the options.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Bonobo.update_best_solution!-Tuple{BnBTree, AbstractNode}","page":"Reference","title":"Bonobo.update_best_solution!","text":"update_best_solution!(tree::BnBTree, node::AbstractNode)\n\nUpdate the best solution when we found a better incumbent. Calls [add_new_solution!] if this is the case, returns whether a solution was added.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = Bonobo","category":"page"},{"location":"#Bonobo","page":"Home","title":"Bonobo","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Bonobo is a general branch and bound framework at a very early stage.  The idea is to make it very customizable and provide useful methods regarding branching strategies and cuts. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"The following three functions need to be implemented to start the process.","category":"page"},{"location":"","page":"Home","title":"Home","text":"initialize (Bonobo.initalize(; kwargs...))\nFor initializing the BnBTree structure itself with the model information and setting options like the traverse and branch strategy.\nIt returns the created BnBTree object which I'll call tree.\nset_root! (Bonobo.set_root!(tree, node_info::NamedTuple))\nSetting the information for the root node which will be evaluated first with evaluate_node!\noptimize! (Bonobo.optimize!(tree))\nThe optimization function calls several branch and bound functions in a loop. Check the docstring for detailed information.","category":"page"},{"location":"","page":"Home","title":"Home","text":"A couple of methods need to be implemented by you to apply it to your need.  When you call the above methods some warnings might pop up in the terminal which specify which functions need to be implemented by you.","category":"page"},{"location":"how_to/#How-To-Guide","page":"How-To","title":"How-To Guide","text":"","category":"section"},{"location":"tutorial/#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial/#Creating-a-MIP-Solver-using-a-LP-solver","page":"Tutorial","title":"Creating a MIP Solver using a LP solver","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"In this short tutorial you'll use a LP solver HiGHS.jl and use it as a MIP solver. Attention: HiGHS itself can solve MIP problems as well so if you don't want to experiment with your own branching strategies you probably don't want to use Bonobo.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"First we create the LP problem using JuMP.jl and HiGHS.jl:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"using Bonobo\nusing JuMP\nusing HiGHS\n\nconst BB = Bonobo","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Those need to be installed with ] add Bonobo, JuMP, HiGHS.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"A standard LP model:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"m = Model(HiGHS.Optimizer)\nset_optimizer_attribute(m, \"log_to_console\", false)\n@variable(m, x[1:3] >= 0)\n@constraint(m, 0.5x[1]+3.1x[2]+4.2x[3] >= 6.1)\n@constraint(m, 1.9x[1]+0.7x[2]+0.2x[3] >= 8.1)\n@constraint(m, 2.9x[1]-2.3x[2]+4.2x[3] >= 10.5)\n@objective(m, Min, x[1]+1.2x[2]+3.2x[3])","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Now we need to initialize the branch and bound solver:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"bnb_model = BB.initialize(;\n    branch_strategy = BB.MOST_INFEASIBLE,\n    Node = MIPNode,\n    root = m,\n    sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min\n)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Here we use the branch strategy MOST_INFEASIBLE, we want to use our own node type MIPNode which shall hold information about the current lower and upper bounds of each variable. Then we give Bonobo the model/root information and the objective sense.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Let's define our MIPNode:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"mutable struct MIPNode <: AbstractNode\n    std :: BnBNodeInfo\n    lbs :: Vector{Float64}\n    ubs :: Vector{Float64}\n    status :: MOI.TerminationStatusCode\nend","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The two things we need to be aware of is that it has to be an AbstractNode and it needs the field: std::BnBNodeInfo.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The initialize function also calls get_branching_indices(::Model) where Model is the type of our root node. There one needs to specify the variables that one can branch on. In our case we want to branch on all variables so we define:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"function BB.get_branching_indices(model::JuMP.Model)\n    # every variable should be discrete\n    vis = MOI.get(model, MOI.ListOfVariableIndices())\n    return 1:length(vis)\nend","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Next we need to specify the information we have about the root node using set_root!. This will be the info that is send to evaluate_node! at the very beginning.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"BB.set_root!(bnb_model, (\n    lbs = zeros(length(x)),\n    ubs = fill(Inf, length(x)),\n    status = MOI.OPTIMIZE_NOT_CALLED\n))","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"We define the lower bounds of each variable as 0 as we defined them in the model @variable(m, x[1:3] >= 0). There are no upper bounds. We also specify the status of this node. Important is that we specify all fields of our MIPNode besides the std field.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Now we can call optimize! and see which methods still need to be implemented.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"BB.optimize!(bnb_model)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"It will show the following error:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"ERROR: MethodError: no method matching evaluate_node!(::BnBTree{MIPNode, Model, Vector{Float64}, Bonobo.DefaultSolution{MIPNode, Vector{Float64}}}, ::MIPNode)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"This means we need to define a method to evaluate a node and return back a lower and upper bound.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"function BB.evaluate_node!(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode)\n    m = tree.root # this is the JuMP.Model\n    vids = MOI.get(m ,MOI.ListOfVariableIndices())\n    # we set the bounds for the current node based on `node.lbs` and `node.ubs`.\n    vars = VariableRef.(m, vids)\n    for vidx in eachindex(vars)\n        if isfinite(node.lbs[vidx])\n            JuMP.set_lower_bound(vars[vidx], node.lbs[vidx])\n        elseif node.lbs[vidx] == -Inf && JuMP.has_lower_bound(vars[vidx])\n            JuMP.delete_lower_bound(vars[vidx])\n        elseif node.lbs[vidx] == Inf # making problem infeasible\n            error(\"Invalid lower bound for variable $vidx: $(node.lbs[vidx])\")\n        end\n        if isfinite(node.ubs[vidx])\n            JuMP.set_upper_bound(vars[vidx], node.ubs[vidx])\n        elseif node.ubs[vidx] == Inf && JuMP.has_upper_bound(vars[vidx])\n            JuMP.delete_upper_bound(vars[vidx])\n        elseif node.ubs[vidx] == -Inf # making problem infeasible\n            error(\"Invalid upper bound for variable $vidx: $(node.lbs[vidx])\")\n        end\n    end\n\n    # get the relaxed solution of the current model using HiGHS\n    optimize!(m)\n    status = termination_status(m)\n    node.status = status\n    # if it is infeasible we return `NaN` for bother lower and upper bound\n    if status != MOI.OPTIMAL\n        return NaN,NaN\n    end\n\n    obj_val = objective_value(m)\n    # we check whether the values are approximately feasible (are integer)\n    # in that case we return the same value for lower and upper bound for this node\n    if all(BB.is_approx_feasible.(tree, value.(vars)))\n        node.ub = obj_val\n        return obj_val, obj_val\n    end\n    # otherwise we only have a lower bound\n    return obj_val, NaN\nend","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"now calling BB.optimize!(bnb_model) again will give the following error:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"ERROR: MethodError: no method matching get_relaxed_values(::BnBTree{MIPNode, Model, Vector{Float64}, Bonobo.DefaultSolution{MIPNode, Vector{Float64}}}, ::MIPNode)\nStacktrace:\n [1] get_branching_variable(tree::BnBTree{MIPNode, Model, Vector{Float64}, Bonobo.DefaultSolution{MIPNode, Vector{Float64}}}, #unused#::Bonobo.MOST_INFEASIBLE, node::MIPNode)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"This gets called to figure out the next branching variable as you can see in the stacktrace where we can see that the ::MOST_INFEASIBLE strategy is used as specified in the initialize call.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"function BB.get_relaxed_values(tree::BnBTree{MIPNode, JuMP.Model}, node)\n    vids = MOI.get(tree.root, MOI.ListOfVariableIndices())\n    vars = VariableRef.(tree.root, vids)\n    return JuMP.value.(vars)\nend","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"We simply need to return the current values of all the variables. The last thing we need to implement is how we want to branch on a node by defining get_branching_nodes_info.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"It takes as input the tree, the current node as well as the variable index to branch on.  This function shall return all information about new nodes we want to create. In our case we want to create two new nodes one where we set the upper bound below the current relaxed value and one where we set the lower bound about the relaxed value. The only thing one needs to take care of is that one doesn't remove an actual discrete solution by splitting up the current problem into  two or more subproblems.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The information for the nodes needs to be returned as a vector of NamedTuple which consist of the same fields as in the set_root! call earlier.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"function BB.get_branching_nodes_info(tree::BnBTree{MIPNode, JuMP.Model}, node::MIPNode, vidx::Int)\n    m = tree.root\n    node_info = NamedTuple[]\n\n    var = VariableRef(m, MOI.VariableIndex(vidx))\n\n    lbs = copy(node.lbs)\n    ubs = copy(node.ubs)\n\n    val = JuMP.value(var)\n\n    # left child set upper bound\n    ubs[vidx] = floor(Int, val)\n\n    push!(node_info, (\n        lbs = copy(node.lbs),\n        ubs = ubs,\n        status = MOI.OPTIMIZE_NOT_CALLED,\n    ))\n\n    # right child set lower bound\n    lbs[vidx] = ceil(Int, val)\n\n    push!(node_info, (\n        lbs = lbs,\n        ubs = copy(node.ubs),\n        status = MOI.OPTIMIZE_NOT_CALLED,\n    ))\n    return node_info\nend","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Now we can actually solve our problem with BB.optimize!(bnb_model). Afterwards we can retrieve the optimal solution with:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"julia> BB.get_solution(bnb_model)\n3-element Vector{Float64}:\n 5.999999999999998\n 1.0\n 0.0","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"and the objective value:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"julia> BB.get_objective_value(bnb_model)\n7.199999999999998","category":"page"},{"location":"tutorial/#Recap","page":"Tutorial","title":"Recap","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The main three functions that need to be called to optimize a problem using Bonobo are for using it as a JuMP MIP solver are initialize, set_root! and `optimize!.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"m = Model(HiGHS.Optimizer)\nset_optimizer_attribute(m, \"log_to_console\", false)\n@variable(m, x[1:3] >= 0)\n@constraint(m, 0.5x[1]+3.1x[2]+4.2x[3] >= 6.1)\n@constraint(m, 1.9x[1]+0.7x[2]+0.2x[3] >= 8.1)\n@constraint(m, 2.9x[1]-2.3x[2]+4.2x[3] >= 10.5)\n@objective(m, Min, x[1]+1.2x[2]+3.2x[3])\n\nbnb_model = BB.initialize(;\n    branch_strategy = BB.MOST_INFEASIBLE,\n    Node = MIPNode,\n    root = m,\n    sense = objective_sense(m) == MOI.MAX_SENSE ? :Max : :Min\n)\n\nBB.set_root!(bnb_model, (\n    lbs = zeros(length(x)),\n    ubs = fill(Inf, length(x)),\n    status = MOI.OPTIMIZE_NOT_CALLED\n))\n\nBB.optimize!(bnb_model)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"The functions that get called internally and need to be implemented are: get_branching_indices, evaluate_node!, [get_relaxed_values] and get_branching_nodes_info.","category":"page"}]
}
