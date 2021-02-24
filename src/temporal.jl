"""
    HoD <: Transform

Get the hour of day corresponding to the data.
"""
struct HoD <: Transform end

_apply(x, ::HoD; kwargs...) = hour.(x)
