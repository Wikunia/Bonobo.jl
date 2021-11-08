#=
    Access standard AbstractNode internals without using .std syntax
=#
@inline function Base.getproperty(c::AbstractNode, s::Symbol)
    if s in (
        :id,
        :lb,
        :ub,
    )
        Core.getproperty(Core.getproperty(c, :std), s)
    else
        getfield(c, s)
    end
end

@inline function Base.setproperty!(c::AbstractNode, s::Symbol, v)
    if s in (
        :id,
        :lb,
        :ub,
    )
        Core.setproperty!(c.std, s, v)
    else
        Core.setproperty!(c, s, v)
    end
end

"""
    is_approx_feasible(tree::BnBTree, value)

Return whether a given `value` is approximately feasible based on the tolerances defined in the tree options. 
"""
function is_approx_feasible(tree::BnBTree, value::Number)
    return is_approx_feasible(value; atol=tree.options.atol, rtol=tree.options.rtol)
end

function is_approx_feasible(value::Number; atol=1e-6, rtol=1e-6)
    return isapprox(value, round(value); atol, rtol)
end

"""
    get_distance_to_feasible(tree::BnBTree, value)

Return the distance of feasibility for the given value.

- if `value::Number` this returns the distance to the nearest discrete value
"""
function get_distance_to_feasible(tree::BnBTree, value::Number)
    return abs(round(value)-value)
end
