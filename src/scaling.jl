"""
    Scaling <: Transform

Linearly scale the data as `ax + b`, according to some statistics `a` and `b`.
"""
abstract type Scaling <: Transform end

"""
    IdentityScaling

Represents the no-op scaling which simply returns the data it is applied on.
"""
struct IdentityScaling <: Scaling end
# Convenience method
IdentityScaling(args...; kwargs...) = IdentityScaling()

"""
    MeanStdScaling(mean, std) <: Scaling

Linearly scale the data by a statistical `mean` and standard deviation `std`.
"""
mutable struct MeanStdScaling <: Scaling
    mean::Union{Real, AbstractArray}
    std::Union{Real, AbstractArray}
    populated::Bool

    """
        MeanStdScaling() <: Scaling

    Construct a `MeanStdScaling` transform which will populate its `mean` and `std`
    parameters from the first data it is applied to.
    """
    MeanStdScaling() = new(0, 1, false)
end

"""
    MeanStdScaling(A; dims) <: Scaling

Construct a [`MeanStdScaling`](@ref) using the mean and standard deviation of `A` along
the dimensions given by `dims`.
"""
function MeanStdScaling(A; dims)
    scaling = MeanStdScaling()
    populate_stats!(scaling, A; dims)
    return scaling
end

function populate_stats!(scaling::MeanStdScaling, A; dims)
    scaling.mean = mean(A; dims=dims)
    scaling.std = std(A; dims=dims)
    scaling.populated = true
    return scaling
end

apply!(A::AbstractArray{T}, scaling::IdentityScaling; kwargs...) where T <: Real = A

"""
    apply!(
        x::AbstractArray{T}, t::Scaling;
        dims=:, inverse=false, kwargs...
    ) where T <: Real

Applies [`Scaling`](@ref) to each element of `x`.
Optionally specify the `dims` to apply the [`Scaling`](@ref) along certain dimensions,
and `inverse=true` to reconstruct the originally scaled data from `x`.
"""
function apply!(
    A::AbstractArray{T}, scaling::MeanStdScaling;
    dims=:, inverse=false, kwargs...
) where T <: Real
    if !scaling.populated
        populate_stats!(scaling, A; dims)
    end
    if inverse
        A[:] = A .* scaling.std .+ scaling.mean
    else
        # TODO: avoid division by zero?
        A[:] = (A .- scaling.mean) ./ scaling.std
    end
    return A
end
