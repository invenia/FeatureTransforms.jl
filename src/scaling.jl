"""
    AbstractScaling <: Transform

Linearly scale the data according to some statistics.
"""
abstract type AbstractScaling <: Transform end
cardinality(::AbstractScaling) = OneToOne()

"""
    IdentityScaling <: AbstractScaling

Represents the no-op scaling which simply returns the `data` it is applied on.
"""
struct IdentityScaling <: AbstractScaling end
IdentityScaling(args...) = IdentityScaling()

@inline _apply(x, ::IdentityScaling; kwargs...) = x

"""
    StandardScaling <: AbstractScaling

Transforms the data according to

    x -> (x - μ) / σ

where μ and σ are the mean and standard deviation of the training data.

!!! note
    `fit!(scaling, data)` needs to be called before the transform can be `apply`ed.
    By default _all the data_ is considered when `fit!`ing the mean and standard deviation.
"""
mutable struct StandardScaling <: AbstractScaling
    μ::Real
    σ::Real
    fitted::Bool

    StandardScaling() = return new(0.0, 1.0, false)
end

"""
    fit!(scaling::StandardScaling, data::AbstractArray; dims=:, inds=:)
    fit!(scaling::StandardScaling, table, [cols])

Fit the [`StandardScaling`](@ref) transform to the given data. By default _all the data_
is considered when computing the mean and standard deviation.
This can be restricted to certain slices via the keyword arguments (see below).

# `AbstractArray` keyword arguments
* `dims=:`: the dimension along which to take the `inds` slices. Default uses all dims.
* `inds=:`: the indices to use in computing the statistics. Default uses all indices.

# `Table` keyword arguments
* `cols`: the columns to use in computing the statistics. Default uses all columns.

!!! note
    If you want the `StandardScaling` to transform your data consistently you should use
    the same `inds`, `dims`, or `cols` keywords when calling `apply`. Otherwise, `apply`
    might rescale the wrong data or throw an error.
"""
function fit!(ss::StandardScaling, args...; kwargs...)
    ss.fitted === true && @warn("StandardScaling is being refit, why?")
    μ, σ = _fit(ss, args...; kwargs...)
    ss.μ, ss.σ, ss.fitted = μ, σ, true
    return ss
end

compute_stats(x) = (mean(x), std(x))

function _fit(::StandardScaling, data::AbstractArray; dims=:, inds=:)
    return if dims isa Colon
        compute_stats(data)
    else
        compute_stats(selectdim(data, dims, inds))
    end
end
function _fit(::StandardScaling, table; cols=_get_cols(table))
    Tables.istable(table) || throw(MethodError(StandardScaling, table))
    columntable = Tables.columns(table)
    data = reduce(vcat, [getproperty(columntable, c) for c in _to_vec(cols)])
    return compute_stats(data)
end

function _apply(A::AbstractArray, ss::StandardScaling; inverse=false, eps=1e-3, kwargs...)
    ss.fitted === true || throw(ErrorException("`fit!` StandardScaling before applying."))
    inverse && return ss.μ .+ ss.σ .* A
    # Avoid division by 0
    # If std is 0 then data was uniform, so the scaled value would end up ≈ 0
    # Therefore the particular `eps` value should not matter much.
    σ_safe = max(ss.σ, eps)
    return (A .- ss.μ) ./ σ_safe
end
