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
    μ::Union{Real, Nothing}
    σ::Union{Real, Nothing}

    StandardScaling() = return new(nothing, nothing)
end

function fit!(ss::StandardScaling, args...; kwargs...)
    ss.μ isa Nothing || throw(ErrorException("StandardScaling should not be refit."))
    ss.μ, ss.σ = _fit(ss, args...; kwargs...)
    return ss
end

compute_stats(x) = (mean(x), std(x))

function _fit(::StandardScaling, data::AbstractArray; dims=:, inds=:)
    dims isa Colon && return compute_stats(data)
    compute_stats(selectdim(data, dims, inds))
end
function _fit(::StandardScaling, table; cols=_get_cols(table))
    Tables.istable(table) || throw(MethodError(StandardScaling, table))
    columntable = Tables.columns(table)
    data = reduce(vcat, [getproperty(columntable, c) for c in _to_vec(cols)])
    return compute_stats(data)
end

function _apply(A::AbstractArray, ss::StandardScaling; inverse=false, eps=1e-3, kwargs...)
    ss.μ isa Real || throw(ErrorException("`fit!` StandardScaling before applying."))
    inverse && return ss.μ .+ ss.σ .* A
    # Avoid division by 0
    # If std is 0 then data was uniform, so the scaled value would end up ≈ 0
    # Therefore the particular `eps` value should not matter much.
    σ_safe = max(ss.σ, eps)
    return (A .- ss.μ) ./ σ_safe
end
