
"""
    Transform

Abstract supertype for all feature Transforms.
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
    apply(data::T, ::Transform; kwargs...)

Applies the [`Transform`](@ref) to the data. New transforms should usually only extend
`_apply` which this method delegates to.

Where necessary, this should be extended for new data types `T`.
"""
function apply end

"""
    apply!(data::T, ::Transform; kwargs...) -> T

Applies the [`Transform`](@ref) mutating the input `data`. This method delegates to
[`apply`](@ref) under the hood so does not need to be defined separately.

If [`Transform`](@ref) does not support mutation, this method will error.
"""
function apply! end


"""
    apply(A::AbstractArray, ::Transform; dims=:, inds=:, kwargs...)

Applies the [`Transform`](@ref) to the elements of `A`.

Provide the `dims` keyword to apply the [`Transform`](@ref) along a certain dimension.
For example, given a `Matrix`, `dims=1` applies to each column, while `dims=2` applies
to each row.

Provide the `inds` keyword to apply the [`Transform`](@ref) to certain indices along the
`dims` specified.

Note: if `dims === :` (all dimensions), then `inds` will be the global indices of the array,
instead of being relative to a certain dimension.

This method does not guarantee the data type of what is returned. It will try to conserve
type but the returned type depends on what the original `A` was, and the `dims` and `inds`
specified.
"""
function apply(A::AbstractArray, t::Transform; dims=:, inds=:, kwargs...)
    if dims === Colon()
        if inds === Colon()
            return _apply(A, t; kwargs...)
        else
            return @views _apply(A[:][inds], t; kwargs...)
        end
    end

    return @views mapslices(A, dims=dims) do x
        _apply(x[inds], t; kwargs...)
    end
end

"""
    apply!(A::AbstractArray, ::Transform; dims=:, kwargs...)

Applies the [`Transform`](@ref) to each element of `A`, mutating the data.
"""
function apply!(A::AbstractArray, t::Transform; kwargs...)
    A[:] = apply(A, t; kwargs...)
    return A
end

"""
    apply(table, ::Transform; cols=nothing, kwargs...) -> Vector

Applies the [`Transform`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`Transform`](@ref) is applied to all columns.

# Return
* If `cols` is a single value (not in a list): the transformed column vector.
* Otherwise: an array containing each transformed column, in the same order as `cols`.
"""
function apply(table, t::Transform; cols=nothing, kwargs...)
    Tables.istable(table) || throw(MethodError(apply, (table, t)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)
    cnames = cols === nothing ? propertynames(columntable) : cols
    return _apply(columntable, t, cnames; kwargs...)
end

# 3-arg forms are simply to dispatch on whether cols is a Symbol or a collection
function _apply(table, t::Transform, col; kwargs...)
    return _apply(getproperty(table, col), t; kwargs...)
end

function _apply(table, t::Transform, cols::Union{Tuple, AbstractArray}; kwargs...)
    return [_apply(table, t, col; kwargs...) for col in cols]
end

"""
    apply!(table::T, ::Transform; cols=nothing)::T where T

Applies the [`Transform`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`Transform`](@ref) is applied to all columns.
"""
function apply!(table::T, t::Transform; cols=nothing, kwargs...)::T where T
    # TODO: We could probably handle iterators of tables here
    Tables.istable(table) || throw(MethodError(apply!, (table, t)))

    cols = _to_vec(cols)  # handle single column name

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)

    cnames = cols === nothing ? propertynames(columntable) : cols
    for cname in cnames
        apply!(getproperty(columntable, cname), t; kwargs...)
    end

    return table
end
