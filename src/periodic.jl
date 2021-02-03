const PeriodicFunction = Union{typeof(cos), typeof(sin)}
const PeriodicParameter = Union{Real,Period}

"""
    Periodic(f, period, phase_shift) <: Transform

Applies a periodic function `f` with provided `period` and `phase_shift` to the data.

# Fields
* `f::PeriodicFunction`: the periodic function
* `period<:PeriodicParameter`: the duration it takes for the periodic function to repeat.
    The sign of the value determines the direction of the function. Must be non-zero.
* `phase_shift<:PeriodicParameter`: adjusts the phase of the periodic function, measured
    in the same units as the input. Increasing the value translates the function to the
    right, toward higher/later input values.
"""
struct Periodic{T<:PeriodicParameter} <: Transform
    f::PeriodicFunction
    period::T
    phase_shift::T
end

"""
    Periodic(f::PeriodicFunction, period<:PeriodicParameter) -> Periodic

A constructor for [`Periodic`](@ref).
Returns a `Periodic` transform with zero phase shift.
"""
function Periodic(f, period)
    return Periodic{typeof(period)}(f, period, zero(typeof(period)))
end

function _apply!(x::AbstractArray{T}, P::Periodic; kwargs...) where T <: Real
    x[:] = P.f.(2π .* (x .- P.phase_shift) / P.period)
    return x
end
