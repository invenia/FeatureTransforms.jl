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
"""
function apply(A::AbstractArray, t::Transform; dims=:, inds=:, kwargs...)

    # TODO: remove this https://github.com/invenia/FeatureTransforms.jl/issues/82
    if t isa LinearCombination && dims === Colon()
        Base.depwarn(
           "The default `dims=1` for `LinearCombination` is deprecated and will be removed " *
           "in a future release. Please set `dims` explicitly.",
           :apply,
        )
        dims=1
    end

    c = cardinality(t)
    if dims === Colon()
        if inds === Colon()
            return _apply(_preformat(c, A, :), t; dims=:, kwargs...)
        else
            return _apply(_preformat(c, A[:][inds], :), t; dims=:, kwargs...)
        end
    end

    input = _preformat(c, selectdim(A, dims, inds), dims)
    return _apply(input, t; dims=dims, kwargs...)
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
    apply(table, ::Transform; [cols], [header], kwargs...) -> Table

Applies the [`Transform`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`Transform`](@ref) is applied to all columns.

Optionally provide a `header` for the output table. If none is provided the default in
`Tables.table` is used.
"""
function apply(table, t::Transform; cols=_get_cols(table), header=nothing, kwargs...)
    Tables.istable(table) || throw(MethodError(apply, (table, t)))

    indices = Tables.columnindex.(Ref(table), _to_vec(cols))
    components = Tables.matrix(table)[:, indices]

    # Passing dims=2 only matters for ManyToOne transforms - otherwise it has no effect.
    input = _preformat(cardinality(t), components, 2)
    result = hcat(_apply(input, t; dims=2, kwargs...))
    return Tables.materializer(table)(_to_table(result, header))
end

# Prevents Vector{NamedTuple} from using the AbstractArray method above
function apply(table::Tables.RowTable, t::Transform; kwargs...)
    return rowtable(apply(Tables.columntable(table), t; kwargs...))
end

"""
    apply!(table::T, ::Transform; [cols])::T where T

Applies the [`Transform`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`Transform`](@ref) is applied to all columns.

!!! Note
  `apply!` does not support `RowTable`s since the `NamedTuple` rows are immutable.
"""
function apply!(table::T, t::Transform; cols=_get_cols(table), kwargs...)::T where T
    Tables.istable(table) || throw(MethodError(apply!, (table, t)))

    for cname in _to_vec(cols)
        apply!(getproperty(table, cname), t; kwargs...)
    end

    return table
end

# Prevents Vector{NamedTuple} from using the AbstractArray method above
function apply!(table::Tables.RowTable, t::Transform; kwargs...)
    return throw(MethodError(apply!, (table, t)))
end

"""
    apply_append(A::AbstractArray, ::Transform; append_dim, kwargs...)

Applies the [`Transform`](@ref) to `A` and returns the result in a new array where the output
is appended to `A` along the `append_dim` dimension. The remaining `kwargs` correspond to
the usual [`Transform`](@ref) being invoked.
"""
function apply_append(A::AbstractArray, t; append_dim, kwargs...)::AbstractArray
    result = apply(A, t; kwargs...)
    result = _postformat(cardinality(t), result, A, append_dim)
    # Conver result to Array to avoid clashing axis/key names in concatenated result
    return cat(A, Array(result); dims=append_dim)
end

"""
    apply_append(table, ::Transform; [header], kwargs...)

Applies the [`Transform`](@ref) to the `table` and appends the result in a new table with an
optional `header`. If none is provided the default in `Tables.table` is used. The remaining
`kwargs` correspond to the [`Transform`](@ref) being invoked.
"""
function apply_append(table, t; kwargs...)
    T = Tables.materializer(table)
    result = Tables.columntable(apply(table, t; kwargs...))
    return T(merge(Tables.columntable(table), result))
end

# Prevents Vector{NamedTuple} from using the AbstractArray method above
function apply_append(table::Tables.RowTable, t; kwargs...)
    T = Tables.materializer(table)
    result = apply(table, t; kwargs...)
    return T(merge.(Tables.rowtable(table), result))
end

# These methods format data according to the cardinality of the Transform.
# Most Transforms don't require any formatting, only those that are ManyToOne do.
# Note: we don't yet have a ManyToMany transform, so those might need separate treatment.

# _preformat formats the data before calling _apply. Needed for all apply methods.
# Before applying a ManyToOne Transform we must first slice up the data along the dimension
# we are reducing over.
_preformat(::Cardinality, A, d) = A
_preformat(::ManyToOne, A, d) = eachslice(A; dims=d)

# _postformat formats the data after calling _apply so it will work with apply_append.
# Basically, when we call LinearCombination it always returns a column vector. But if we
# want to append the result as a row we have to reshape to get it to fit.
# In general, after applying a ManyToOne Transform, we have to reshape the reduced dimension
# to 1 if we want to cat the result.
_postformat(::Cardinality, result, A, append_dim) = result
function _postformat(::ManyToOne, result, A, append_dim)
    new_size = collect(size(A))
    setindex!(new_size, 1, dim(A, append_dim))
    return copy(reshape(result, new_size...))  # return a copy to remove the reshape type
end
