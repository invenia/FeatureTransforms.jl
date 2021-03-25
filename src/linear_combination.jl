"""
    LinearCombination(coefficients) <: Transform

Calculate the linear combination using the vector coefficients passed in.
"""
struct LinearCombination <: Transform
    coefficients::Vector{Real}
end

function _sum_row(row, coefficients)
    if length(row) != length(coefficients)
        throw(DimensionMismatch(
            "Size $length(row) doesn't match number of coefficients $(length(coefficients))"
        ))
    end
   return sum(map(*, row, coefficients))
end

"""
    apply(
        ::AbstractArray{<:Real, N}, ::LinearCombination; dims=1, inds=:
    ) -> AbstractArray{<:Real, N-1}

Applies the [`LinearCombination`](@ref) to each of the specified indices in the N-dimensional
array `A`, reducing along the `dim` provided. The result is an (N-1)-dimensional array.

The default behaviour reduces along the column dimension.

If no `inds` are specified, then the transform is applied to all elements.
"""
function apply(
    A::AbstractArray{<:Real, N}, LC::LinearCombination; dims=1, inds=:
)::AbstractArray{<:Real, N-1} where N

    dims === Colon() && throw(ArgumentError("dims=: not supported, choose dims ∈ [1, $N]"))

    return _sum_row(eachslice(selectdim(A, dims, inds); dims=dims), LC.coefficients)
end


"""
    apply(table, LC::LinearCombination; [cols], [header]) -> Table

Applies the [`LinearCombination`](@ref) across the specified cols in `table`. If no `cols`
are specified, then the [`LinearCombination`](@ref) is applied to all columns.

Optionally provide a `header` for the output table. If none is provided the default in
`Tables.table` is used.
"""
function apply(table, LC::LinearCombination; cols=_get_cols(table), kwargs...)
    Tables.istable(table) || throw(MethodError(apply, (table, LC)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    coltable = Tables.columntable(table)
    cols = _to_vec(cols)

    # Keep the generic form when not specifying column names
    # because that is much more performant than selecting each col by name
    result = hcat([
        _sum_row([row[cname] for cname in cols], LC.coefficients)
        for row in Tables.rows(table)
    ])

    header = get(kwargs, :header, nothing)
    return Tables.materializer(table)(_to_table(result, header))
end
