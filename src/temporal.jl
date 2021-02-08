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

function apply(table, t::HoD; cols=nothing, kwargs...)
    Tables.istable(table) || throw(MethodError(apply!, (table, t)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)

    cnames = cols === nothing ? propertynames(columntable) : cols
    return [_apply(getproperty(columntable, cname), t)  for cname in cnames]
end
