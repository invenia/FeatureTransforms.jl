"""
    Periodic{T}(f, period::T, phase_shift::T) <: Transform

Applies a periodic function `f` with provided `period` and `phase_shift` to the data.

!!! note
    For `TimeType` data, the result will change depending on the type of `period` given,
    even if the same amount of time is described. Example: `Week(1)` vs `Second(Week(1))`;
    the former starts the period on the most recent Monday, while the latter starts the
    period on the most recent multiple of 604800 seconds since time 0.

# Fields
* `f::Union{typeof(cos), typeof(sin)}`: the periodic function
* `period::Union{Real, Period}`: the function period. Must be strictly positive.
* `phase_shift::Union{Real, Period}`: adjusts the phase of the periodic function, measured
    in the same units as the input. Increasing the value translates the function to the
    right, toward higher/later input values.
"""
struct Periodic{T} <: Transform where T <: Union{Real, Period}
    f::Union{typeof(cos), typeof(sin)}
    period::T
    phase_shift::T

    function Periodic(f, period::T, phase_shift::T) where T
        period > zero(T) || throw(ArgumentError("period must be strictly positive."))
        return new{T}(f, period, phase_shift)
    end
end

"""
    Periodic(f, period) -> Periodic

A constructor for [`Periodic`](@ref).
Returns a `Periodic` transform with zero phase shift.
"""
Periodic(f, period::T) where T = Periodic(f, period, zero(T))

function _apply(x, P::Periodic; kwargs...)
    return P.f.(2π .* (x .- P.phase_shift) / P.period)
end

function _apply(x, P::Periodic{T}; kwargs...) where T <: Period
    map(xi -> _periodic(P.f, xi, P.period, P.phase_shift), x)
end

"""
    _periodic(f, instant, period, phase_shift=Day(0))

Computes the value of periodic function `f` at the given instant in time.

# Arguments
* `f`: the periodic function
* `period`: the function period
* `phase_shift`: adjusts the phase of the periodic function. Increasing the value translates
    the function to the right, toward higher/later input values.
"""
function _periodic(f, instant, period, phase_shift=Day(0))
    period_begin = floor(instant, period) + phase_shift

    # Make sure the `instant - period_begin < period` after we add the `phase_shift`.
    # Performing these adjustments isn't necessary since we're dealing with a periodic
    # function but it will reduce floating-point errors.
    if phase_shift > zero(typeof(period))
        while period_begin > instant
            period_begin -= period
        end
    elseif phase_shift < zero(typeof(period))
        while period_begin < instant
            period_begin += period  # Make sure `period_begin <= instant`
        end
    end

    period_end = period_begin + period
    # `period_end - period_begin` converts to the same units so that `/` is defined
    normalized = (instant - period_begin) / (period_end - period_begin)
    return f(2π * normalized)
end
