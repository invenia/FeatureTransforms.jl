"""
    Power(exponent) <: Transform

Raise the data by the given `exponent`.
"""
struct Power <: Transform
    exponent::Real
end

function _apply!(x::AbstractArray{T}, P::Power; kwargs...) where T <: Real
    x[:] = x .^ P.exponent
    return x
end
