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

function is_approx_discrete(tree::BnBTree, val)
    return is_approx_discrete(val; atol=tree.options.atol, rtol=tree.options.rtol)
end

function is_approx_discrete(val; atol=1e-6, rtol=1e-6)
    return isapprox(val, round(val); atol, rtol)
end