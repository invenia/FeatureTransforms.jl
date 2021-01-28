
"""
    Transformation

Abstract supertype for all transformations.
"""
abstract type Transformation end

# Make Transforms callable types
(t::Transformation)(x; kwargs...) = transform(x, t; kwargs...)

"""
    transform!(data::T, transformation::Transformation; kwargs...) -> T

Apply the`transformation` mutating the input `data`.
Where possible, this should be extended for new data types `T`.
"""
function transform! end

"""
    transform(data::T, transformation::Transformation; kwargs...) -> T

Non-mutating version of [`transform!`](@ref), which it delegates to by default.
Does not need to be extended unless a mutating transformation is not possible.
"""
function transform end

"""
    transform!(A::AbstractArray{T}, ::Transformation; dims=:, kwargs...) where T <: Real

Applies the transformation to each element of `A`.
Optionally specify the `dims` to apply the transformation along certain dimensions.
"""
function transform!(
    A::AbstractArray{T}, t::Transformation; dims=:, kwargs...
) where T <: Real
    dims == Colon() && return _transform!(A, t; kwargs...)

    for x in eachslice(A; dims=dims)
        _transform!(x, t; kwargs...)
    end

    return A
end

transform(x, t::Transformation; kwargs...) = transform!(_try_copy(x), t; kwargs...)

"""
    transform!(table::T, ::Transformation; cols=nothing)::T where T

Applies the transformation to each of the specified columns in the `table`.
If no `cols` are specified, then the transformation is applied to all columns.
"""
function transform!(table::T, t::Transformation; cols=nothing)::T where T
    # TODO: We could probably handle iterators of tables here
    Tables.istable(table) || throw(MethodError(transform!, (table, t)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)

    cnames = cols === nothing ? propertynames(columntable) : cols
    for cname in cnames
        transform!(getproperty(columntable, cname), t)
    end

    return table
end
