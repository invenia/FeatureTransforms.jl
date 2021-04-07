"""
    HoD <: Transform

Get the hour of day corresponding to the data.
"""
struct HoD <: Transform end
cardinality(::HoD) = OneToOne()

_apply(x, ::HoD; kwargs...) = hour.(x)
