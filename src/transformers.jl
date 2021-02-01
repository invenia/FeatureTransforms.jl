
"""
    Transform

Abstract supertype for all Transforms.
"""
abstract type Transform end

# Make Transforms callable types
(t::Transform)(x; kwargs...) = apply(x, t; kwargs...)


"""
    transform!(::T, data)

Defines the feature engineering pipeline for some type `T`, which comprises a collection of
[`Transform`](@ref)s to be peformed on the `data`.

`transform!` should be overloaded for custom types `T` that require feature engineering.
"""
function transform! end

"""
    transform(::T, data)

Non-mutating version of [`transform!`](@ref).
"""
function transform end

"""
    Transforms.apply!(data::T, Transform::Transform; kwargs...) -> T

Applies the [`Transform`](@ref) mutating the input `data`.
Where possible, this should be extended for new data types `T`.
"""
function apply! end

"""
    Transforms.apply(data::T, Transform::Transform; kwargs...) -> T

Non-mutating version of [`apply!`](@ref), which it delegates to by default.
Does not need to be extended unless a mutating [`Transform`](@ref) is not possible.
"""
function apply end

"""
    apply!(A::AbstractArray{T}, ::Transform; dims=:, kwargs...) where T <: Real

Applies the [`Transform`](@ref) to each element of `A`.
Optionally specify the `dims` to apply the [`Transform`](@ref) along certain dimensions.
"""
function apply!(
    A::AbstractArray{T}, t::Transform; dims=:, kwargs...
) where T <: Real
    dims == Colon() && return _apply!(A, t; kwargs...)

    for x in eachslice(A; dims=dims)
        _apply!(x, t; kwargs...)
    end

    return A
end

apply(x, t::Transform; kwargs...) = apply!(_try_copy(x), t; kwargs...)

"""
    Transforms.apply!(table::T, ::Transform; cols=nothing)::T where T

Applies the [`Transform`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`Transform`](@ref) is applied to all columns.
"""
function apply!(table::T, t::Transform; cols=nothing)::T where T
    # TODO: We could probably handle iterators of tables here
    Tables.istable(table) || throw(MethodError(apply!, (table, t)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)

    cnames = cols === nothing ? propertynames(columntable) : cols
    for cname in cnames
        apply!(getproperty(columntable, cname), t)
    end

    return table
end
