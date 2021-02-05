"""
    LinearCombination(coefficients) <: Transform

Calculate the linear combination using the column weights passed in.
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
    apply(x::AbstractArray, LC::LinearCombination; dims=1, inds=Colon())

Applies the [`LinearCombination`](@ref) to each of the specified indices in `x` along the
dimension specified, which defaults to applying across the columns of x.

If no `inds` are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(x::AbstractArray, LC::LinearCombination; dims=1, inds=Colon())
    # Get the number of vectors in the dimension not specified
    other_dim = dims ==  1 ? 2 : 1
    num_inds = inds isa Colon ? size(x, other_dim) : length(inds)
    # Error if dimensions don't match
    _check_dimensions_match(LC, num_inds)

    return [_sum_row(row[inds], LC.coefficients) for row in eachslice(x; dims=dims)]
end

"""
    apply(x::Table, LC::LinearCombination; inds=nothing

Applies the [`LinearCombination`](@ref) to each of the specified indices (columns) in `x`.

If no `inds` are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(x, LC::LinearCombination; inds=nothing)
    # Error if dimensions don't match
    num_inds = inds === nothing ? length(Tables.columnnames(x)) : length(inds)
    _check_dimensions_match(LC, num_inds)

    # Keep the generic form when not specifying column names
    # because that is much more performant than selecting each col by name
    if inds === nothing
        return [_sum_row(row, LC.coefficients) for row in Tables.rows(x)]
    else
        return [
            _sum_row([row[cname] for cname in inds], LC.coefficients)
            for row in Tables.rows(x)
        ]
    end
end
