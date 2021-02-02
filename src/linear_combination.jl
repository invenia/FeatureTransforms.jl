"""
    LinearCombination <: Transform

Calculate the linear combination using the column weights passed in.
"""
struct LinearCombination <: Transform
    col_weights::Vector{Real}
end

function _check_dimensions_match(LC::LinearCombination, num_cols)
    num_weights = length(LC.col_weights)
    if num_cols != num_weights
        throw(DimensionMismatch(
            "Number of cols ($num_cols) doesn't match number of weights ($num_weights)"
        ))
    end
end

_sum_row(row, col_weights) = sum(map(*, row, col_weights))

function apply(x::AbstractVector, LC::LinearCombination; kwargs...)
    # Treat each element as it's own column
    # Error if dimensions don't match
    num_cols = length(x)
    _check_dimensions_match(LC, num_cols)

    return [_sum_row(x, LC.col_weights)]
end

function apply(x::AbstractArray, LC::LinearCombination; kwargs...)
    # Error if dimensions don't match
    num_cols = size(x, 2)
    _check_dimensions_match(LC, num_cols)

    return [_sum_row(row, LC.col_weights) for row in eachrow(x)]
end

function apply(x, LC::LinearCombination; kwargs...)
    # Error if dimensions don't match
    column_names = Tables.columnnames(x)
    num_cols = length(column_names)
    _check_dimensions_match(LC, num_cols)

    return [_sum_row(row, LC.col_weights) for row in Tables.rows(x)]
end
