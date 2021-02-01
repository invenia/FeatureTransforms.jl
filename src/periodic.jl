const PeriodicFunction = Union{typeof(cos), typeof(sin)}

"""
    Periodic(f, period, phase_shift) <: Transform

Applies a periodic function `f` with the given period and phase shift to the data.
"""
struct Periodic <: Transform
    f::PeriodicFunction
    period::Real
    phase_shift::Real
end

function _apply!(x::AbstractArray{T}, P::Periodic; kwargs...) where T <: Real
    x[:] = P.f.(2π .* x ./ P.period .+ P.phase_shift)
    return x
end
