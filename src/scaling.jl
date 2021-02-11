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

apply!(A::AbstractArray{T}, scaling::IdentityScaling; kwargs...) where T <: Real = A

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
    MeanStdScaling() = new(0, 1, false)  # initialising to 0 and 1 may be confusing
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

"""
    apply!(
        x::AbstractArray{T}, t::MeanStdScaling;
        dims=:, inverse=false, kwargs...
    ) where T <: Real

Applies [`MeanStdScaling`](@ref) to each element of `x`.
Optionally specify the `dims` to apply [`MeanStdScaling`](@ref) along certain dimensions,
and `inverse=true` to reconstruct the originally scaled data from `x`.
For `inverse=false`, all 0 std values get replaced by the value `eps` before scaling.
"""
function apply!(
    A::AbstractArray{T}, scaling::MeanStdScaling;
    dims=:, inverse=false, eps=1e-3, kwargs...
) where T <: Real
    if !scaling.populated
        populate_stats!(scaling, A; dims)
    end
    if inverse
        A[:] = A .* scaling.std .+ scaling.mean
    else
        # Avoid division by 0
        # If std is 0 then data was uniform, so the scaled value would end up ≈0
        # Therefore the particular `eps` value should not matter much.
        scaling_std_safe = if scaling.std isa Real
            scaling.std == 0 ? eps : scaling.std
        else  # AbstractArray
            replace(scaling.std, 0 => eps)
        end
        A[:] = (A .- scaling.mean) ./ scaling_std_safe
    end
    return A
end
