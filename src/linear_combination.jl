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

"""
    apply(x, LC::LinearCombination; cols=Colon())

Applies the [`LinearCombination`](@ref) to each of the specified columns in `x`.
If no `cols` are specified, then the [`LinearCombination`](@ref) is applied to all columns.
"""
function apply(x::AbstractVector, LC::LinearCombination; cols=Colon())
    # Treat each element as it's own column
    # Error if dimensions don't match
    num_cols = cols isa Colon ? length(x) : length(cols)
    _check_dimensions_match(LC, num_cols)

    return [_sum_row(x[cols], LC.col_weights)]
end

function apply(x::AbstractArray, LC::LinearCombination; cols=Colon())
    # Error if dimensions don't match
    num_cols = cols isa Colon ? size(x, 2) : length(cols)
    _check_dimensions_match(LC, num_cols)

    return [_sum_row(row[cols], LC.col_weights) for row in eachrow(x)]
end

function apply(x, LC::LinearCombination; cols=nothing)
    # Error if dimensions don't match
    num_cols = cols === nothing ? length(Tables.columnnames(x)) : length(cols)
    _check_dimensions_match(LC, num_cols)

    # Keep the generic form when not specifying column names
    # because that is much more performant than selecting each col by name
    if cols === nothing
        return [_sum_row(row, LC.col_weights) for row in Tables.rows(x)]
    else
        return [
            _sum_row([row[cname] for cname in cols], LC.col_weights)
            for row in Tables.rows(x)
        ]
    end
end
