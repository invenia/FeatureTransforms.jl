"""
    Periodic{T}(f, period::T, phase_shift::T) <: Transform

Applies a periodic function `f` with provided `period` and `phase_shift` to the data.

# Fields
* `f::Union{typeof(cos), typeof(sin)}`: the periodic function
* `period<:Union{Real, Period}`: the function period. Must be strictly positive.
* `phase_shift<:Union{Real, Period}`: adjusts the phase of the periodic function, measured
    in the same units as the input. Increasing the value translates the function to the
    right, toward higher/later input values.
"""
struct Periodic{T} <: Transform where T <: Union{Real, Period}
    f::Union{typeof(cos), typeof(sin)}
    period::T
    phase_shift::T

    function Periodic(f, period, phase_shift)
        if period <= zero(typeof(period))
            throw(ArgumentError("period must be strictly positive."))
        end
        return new{typeof(period)}(f, period, phase_shift)
    end
end

"""
    Periodic(f, period) -> Periodic

A constructor for [`Periodic`](@ref).
Returns a `Periodic` transform with zero phase shift.
"""
function Periodic(f, period)
    return Periodic(f, period, zero(typeof(period)))
end

function _apply!(x::AbstractArray{T}, P::Periodic; kwargs...) where T <: Real
    x[:] = P.f.(2π .* (x .- P.phase_shift) / P.period)
    return x
end

function apply(x::AbstractArray{T}, P::Periodic{U}; kwargs...) where {T <: TimeType, U <: Period}
    return map(xi -> _periodic(P.f, xi, P.period, P.phase_shift), x)
end

"""
    Transforms.apply(table, ::Periodic{T}; cols=nothing) where T <: Period -> Array

Applies [`Periodic`](@ref) to each of the specified columns in `table`.
If no `cols` are specified, then [`Periodic`](@ref) is applied to all columns.
Returns an array containing each transformed column, in the same order as `cols`.
"""
function apply(table, P::Periodic{T}; cols=nothing) where T <: Period
    Tables.istable(table) || throw(MethodError(apply, (table, P)))

    columntable = Tables.columns(table)
    cnames = cols === nothing ? propertynames(columntable) : cols
    return [apply(getproperty(columntable, cname), P) for cname in cnames]
end

"""
    _periodic(f, instant, period, phase_shift=Day(0))

Computes the value of periodic function `f` at the given instant in time.

!!! note
    The result will change depending on the type of `period` given, even if the same amount
    of time is described. Example: `Week(1)` vs `Second(Week(1))`; the former starts the
    period on the most recent Monday, while the latter starts the period on the most recent
    multiple of 604800 seconds since time 0.

# Arguments
* `f`: the periodic function
* `period`: the function period
* `phase_shift`: adjusts the phase of the periodic function. Increasing the value translates
    the function to the right, toward higher/later input values.
"""
function _periodic(f, instant, period, phase_shift=Day(0))
    period = abs(period)
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
