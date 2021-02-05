"""
    HoD <: Transform

Get the hour of day corresponding to the data.
"""
struct HoD <: Transform end


_apply(x, ::HoD) = hour.(x)

function apply(A::AbstractArray, t::HoD; dims=:, kwargs...)
    dims == Colon() && return _apply(A, t; kwargs...)

    return [_apply(x, t; kwargs...) for x in eachslice(A, dims=dims)]
end
