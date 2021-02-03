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
    if !(P.period isa Real && P.phase_shift isa Real)
        throw(ArgumentError("period and phase_shift must be of type Real"))
    end
    x[:] = P.f.(2π .* (x .- P.phase_shift) / P.period)
    return x
end

function apply(x::AbstractArray{T}, P::Periodic{U}; kwargs...) where {T <: TimeType, U <: Period}
    if !(P.period isa Period && P.phase_shift isa Period)
        throw(ArgumentError("period and phase_shift must be of type Period"))
    end
    return map(xi -> _periodic(P.f, xi, P.period, P.phase_shift), x)
end

"""
    Transforms.apply(x, ::Periodic{T}; cols=nothing) where T <: Period -> Array

Applies [`Periodic`](@ref) to each of the specified columns in `x`.
If no `cols` are specified, then [`Periodic`](@ref) is applied to all columns.
Returns an array containing each transformed column.
"""
function apply(x, P::Periodic{T}; cols=nothing) where T <: Period
    columntable = Tables.columns(x)
    cnames = cols === nothing ? propertynames(columntable) : cols
    return [apply(getproperty(columntable, cname), P) for cname in cnames]
end

function _periodic(
    f::PeriodicFunction,
    instant::TimeType,
    period::Period,
    phase_shift::Period=Day(0)
)
    # Save the direction of `period` while using abs(period)
    direction = period < zero(typeof(period)) ? -1 : 1
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
    return f(2π * normalized * direction)
end
