"""
    LinearCombination(coefficients) <: Transform

Calculate the linear combination using the vector coefficients passed in.
"""
struct LinearCombination <: Transform
    coefficients::Vector{Real}
end

function _check_dimensions_match(LC::LinearCombination, num_inds)
    num_coefficients = length(LC.coefficients)
    if num_inds != num_coefficients
        throw(DimensionMismatch(
            "Size $num_inds doesn't match number of coefficients ($num_coefficients)"
        ))
    end
end

_sum_row(row, coefficients) = sum(map(*, row, coefficients))

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

    # Get the number of slices - error if doesn't match the number of coefficients
    num_slices = inds === Colon() ? size(A, dims) : length(inds)
    _check_dimensions_match(LC, num_slices)

    return _sum_row(eachslice(selectdim(A, dims, inds); dims=dims), LC.coefficients)
end


"""
    apply(table, LC::LinearCombination; cols=nothing, [header])

Applies the [`LinearCombination`](@ref) across the specified cols in `table`. If no `cols`
are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(table, LC::LinearCombination; cols=nothing, header=[:Column1])
    Tables.istable(table) || throw(MethodError(apply, (table, LC)))

    cols = _to_vec(cols)  # handle single column name

    # Error if dimensions don't match
    num_cols = cols === nothing ? length(Tables.columnnames(table)) : length(cols)
    _check_dimensions_match(LC, num_cols)

    # Keep the generic form when not specifying column names
    # because that is much more performant than selecting each col by name
    result = if cols === nothing
        _to_mat([_sum_row(row, LC.coefficients) for row in Tables.rows(table)])
    else
        _to_mat([
            _sum_row([row[cname] for cname in cols], LC.coefficients)
            for row in Tables.rows(table)
        ])
    end

    return Tables.materializer(table)(Tables.table(result, header=header))
end
