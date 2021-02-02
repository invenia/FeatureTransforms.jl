const PeriodicFunction = Union{typeof(cos), typeof(sin)}
const PeriodicInput = Union{Real,TimeType}

"""
    Periodic(f, period, phase_shift) <: Transform

Applies a periodic function `f` with provided `period` and `phase_shift` to the data.

# Fields
* `f::PeriodicFunction`: the periodic function
* `period<:PeriodicInput`: the duration it takes for the periodic function to repeat
* `phase_shift<:PeriodicInput`: adjusts the phase of the periodic function. A positive
    value translates the function to the left, toward lower input values.
"""
struct Periodic{T<:PeriodicInput} <: Transform
    f::PeriodicFunction
    period::T
    phase_shift::T
end

"""
    Periodic(f::PeriodicFunction, period<:PeriodicInput) -> Periodic

A constructor for [`Periodic`](@ref).
Returns a `Periodic` transform with zero phase shift.
"""
function Periodic(f, period)
    return Periodic{typeof(period)}(f, period, zero(typeof(period)))
end

function _apply!(x::AbstractArray{T}, P::Periodic; kwargs...) where T <: Real
    x[:] = P.f.(2π .* x ./ P.period .+ P.phase_shift)
    return x
end
