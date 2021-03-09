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
    apply(x::AbstractVector, LC::LinearCombination; inds=:)

Applies the [`LinearCombination`](@ref) to each of the specified indices in `x`.

If no `inds` are specified, then the [`LinearCombination`](@ref) is applied to all elements.
"""
function apply(x::AbstractVector, LC::LinearCombination; inds=:)
    # Treat each element as it's own column - error if not equal to number of coefficients
    num_elems = inds === Colon() ? length(x) : length(inds)
    _check_dimensions_match(LC, num_elems)

    return [_sum_row(x[inds], LC.coefficients)]
end

"""
    apply(A::AbstractArray, LC::LinearCombination; dims=1, inds=:)

Applies the [`LinearCombination`](@ref) to each of the specified indices in `A` along the
dimension specified, which defaults to applying it row-wise for each column of `A`.

If no `inds` are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(A::AbstractArray, LC::LinearCombination; dims=1, inds=:)
    dims === Colon() && throw(ArgumentError("dims=: is not supported, use 1 or 2 instead"))

    # Get the number of slices - error if doesn't match the number of coefficients
    num_slices = inds === Colon() ? size(A, dims) : length(inds)
    _check_dimensions_match(LC, num_slices)

    return _sum_row(eachslice(selectdim(A, dims, inds); dims=dims), LC.coefficients)
end

"""
    apply(table, LC::LinearCombination; cols=nothing)

Applies the [`LinearCombination`](@ref) to each of the specified cols in `table`.

If no `cols` are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(table, LC::LinearCombination; cols=nothing)
    Tables.istable(table) || throw(MethodError(apply, (table, LC)))

    cols = _to_vec(cols)  # handle single column name

    # Error if dimensions don't match
    num_cols = cols === nothing ? length(Tables.columnnames(table)) : length(cols)
    _check_dimensions_match(LC, num_cols)

    # Keep the generic form when not specifying column names
    # because that is much more performant than selecting each col by name
    cols === nothing && return [_sum_row(row, LC.coefficients) for row in Tables.rows(table)]

    return [
        _sum_row([row[cname] for cname in cols], LC.coefficients)
        for row in Tables.rows(table)
    ]
end
