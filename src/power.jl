"""
    Power(exponent) <: Transformation

Raise the data by the given `exponent`.
"""
struct Power <: Transformation
    exponent::Real
end

function _transform!(x::AbstractArray{T}, P::Power; kwargs...) where T <: Real
    x[:] = x.^ P.exponent
end
