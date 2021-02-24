"""
    Periodic{P, S}(f, period::P, [phase_shift::S]) <: Transform

Applies a periodic function `f` with provided `period` and `phase_shift` to the data.

The `period` and `phase_shift` must have the same supertype of `Real` or `Period`, depending on
whether the data is `Real` or `TimeType` respectively.

!!! note
    For `TimeType` data, the result will change depending on the type of `period` given,
    even if the same amount of time is described. Example: `Week(1)` vs `Second(Week(1))`;
    the former starts the period on the most recent Monday, while the latter starts the
    period on the most recent multiple of 604800 seconds since time 0.

# Fields
* `f::Union{typeof(cos), typeof(sin)}`: the periodic function
* `period::Union{Real, Period}`: the function period. Must be strictly positive.
* `phase_shift::Union{Real, Period}` (optional): adjusts the phase of the periodic function,
  measured in the same units as the input. Increasing the value translates the function to
  the right, toward higher/later input values.
"""
struct Periodic{P, S} <: Transform
    f::Union{typeof(cos), typeof(sin)}
    period::P
    phase_shift::S

    function Periodic(f, period::P, phase_shift::S) where {P, S}
        if !((P <: Real && S <: Real) || (P <: Period && S <: Period))
            throw(ArgumentError("period and phase_shift must have the same supertype"))
        end
        period > zero(P) || throw(DomainError(period, "period must be strictly positive."))
        return new{P, S}(f, period, phase_shift)
    end
end

"""
    Periodic(f, period) -> Periodic

A constructor for [`Periodic`](@ref).
Returns a `Periodic` transform with zero phase shift.
"""
Periodic(f, period::P) where P = Periodic(f, period, zero(P))

function _apply(x, P::Periodic; kwargs...)
    return P.f.(2π .* (x .- P.phase_shift) / P.period)
end

function _apply(x, p::Periodic{P}; kwargs...) where P <: Period
    map(xi -> _periodic(p.f, xi, p.period, p.phase_shift), x)
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
