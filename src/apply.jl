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

    return _apply(selectdim(A, dims, inds), t; kwargs...)
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
function apply(table, t::Transform; cols=_get_cols(table), kwargs...)
    Tables.istable(table) || throw(MethodError(apply, (table, t)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    coltable = Tables.columntable(table)
    cols = _to_vec(cols)

    result = reduce(hcat, [_apply(getproperty(coltable, col), t; kwargs...) for col in cols])
    header = get(kwargs, :header, nothing)
    return Tables.materializer(table)(_to_table(result, header))
end

_to_table(x, ::Nothing) = Tables.table(x)
_to_table(x, header) = Tables.table(x, header=header)

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
    cols = _to_vec(cols)  # handle single column name

    for cname in cols
        apply!(getproperty(coltable, cname), t; kwargs...)
    end

    return table
end

_get_cols(table) = propertynames(Tables.columns(table))
