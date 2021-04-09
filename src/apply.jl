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
    if dims === Colon()
        if inds === Colon()
            return _apply(cardinality(t), A, t; dims=:, kwargs...)
        else
            return _apply(cardinality(t), A[:][inds], t; dims=:, kwargs...)
        end
    end

    return _apply(cardinality(t), selectdim(A, dims, inds), t; dims=dims, kwargs...)
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

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    coltable = Tables.columntable(table)
    components = reduce(hcat, getproperty(coltable, col) for col in _to_vec(cols))

    # We call hcat to convert any Vector components/results into a Matrix.
    # Passing dims=2 only matters for ManyToOne transforms - otherwise it has no effect.
    result = hcat(_apply(cardinality(t), hcat(components), t; dims=2, kwargs...))
    return Tables.materializer(table)(_to_table(result, header))
end

"""
    apply!(table::T, ::Transform; [cols])::T where T

Applies the [`Transform`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`Transform`](@ref) is applied to all columns.
"""
function apply!(table::T, t::Transform; cols=_get_cols(table), kwargs...)::T where T
    Tables.istable(table) || throw(MethodError(apply!, (table, t)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    coltable = Tables.columntable(table)
    for cname in _to_vec(cols)
        apply!(getproperty(coltable, cname), t; kwargs...)
    end

    return table
end

"""
    apply_append(A::AbstractArray, ::Transform; append_dim, kwargs...)

Applies the [`Transform`](@ref) to `A` and returns the result in a new array where the output
is appended to `A` along the `append_dim` dimension. The remaining `kwargs` correspond to
the usual [`Transform`](@ref) being invoked.
"""
function apply_append(A::AbstractArray, t; append_dim, kwargs...)::AbstractArray
    result = _apply_append(cardinality(t), A, t; append_dim=append_dim, kwargs...)
    return cat(A, result; dims=append_dim)
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

# These intermediate _apply methods take the cardinality of the Transform into account.
# Most Transforms operate on all the data provided, where the transformation is typically
# broadcast over all the elements using the same parameters. Note: we don't have an example
# of a ManyToMany transform yet so there might be a separate method for that when we do.
_apply(::Cardinality, A, t; kwargs...) = _apply(A, t; kwargs...)

# ManyToOne Transforms typically reduce many compoments over a certain dimension. Hence it
# needs to be applied to along the slices of the data provided.
function _apply(::ManyToOne, A, t; dims, kwargs...)
    return _apply(eachslice(A; dims=dims), t; kwargs...)
end

_apply_append(::Cardinality, A, t; kwargs...) = apply(A, t; kwargs...)
function _apply_append(::ManyToOne, A, t; append_dim, kwargs...)
    # A was reduced along the append_dim so we must reshape the result setting that dim to 1
    new_size = collect(size(A))
    setindex!(new_size, 1, dim(A, append_dim))
    return reshape(apply(A, t; kwargs...), new_size...)
end
