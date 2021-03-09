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
    apply(x::AbstractVector, LC::LinearCombination; inds=Colon())

Applies the [`LinearCombination`](@ref) to each of the specified indices in `x`.

If no `inds` are specified, then the [`LinearCombination`](@ref) is applied to all elements.
"""
function apply(x::AbstractVector, LC::LinearCombination; inds=Colon())
    # Treat each element as it's own column
    # Error if dimensions don't match
    num_inds = inds isa Colon ? length(x) : length(inds)
    _check_dimensions_match(LC, num_inds)

    return [_sum_row(x[inds], LC.coefficients)]
end

"""
    apply(x::AbstractMatrix, LC::LinearCombination; dims=1, inds=Colon())

Applies the [`LinearCombination`](@ref) to each of the specified indices in `x` along the
dimension specified, which defaults to applying it row-wise for each column of x.

If no `inds` are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(x::AbstractMatrix, LC::LinearCombination; dims=1, inds=Colon())
    if dims === Colon()
        throw(ArgumentError("Colon() dims is not supported, use 1 or 2 instead"))
    end

    # Get the number of slices - error if doesn't match the number of coefficients
    num_inds = inds isa Colon ? size(x, dims) : length(inds)
    _check_dimensions_match(LC, num_inds)
    A = selectdim(x, dims, inds)
    return _sum_row(eachslice(A; dims=dims), LC.coefficients)
end

"""
    apply(x::Table, LC::LinearCombination; cols=nothing)

Applies the [`LinearCombination`](@ref) to each of the specified cols in `x`.

If no `cols` are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(x, LC::LinearCombination; cols=nothing)
    cols = _to_vec(cols)  # handle single column name

    # Error if dimensions don't match
    num_cols = cols === nothing ? length(Tables.columnnames(x)) : length(cols)
    _check_dimensions_match(LC, num_cols)

    # Keep the generic form when not specifying column names
    # because that is much more performant than selecting each col by name
    if cols === nothing
        return [_sum_row(row, LC.coefficients) for row in Tables.rows(x)]
    else
        return [
            _sum_row([row[cname] for cname in cols], LC.coefficients)
            for row in Tables.rows(x)
        ]
    end
end
