"""
    OneHotEncoding <: Transform

One-hot encode the categorical value for each target element.

Construct a n-by-p binary matrix, given a `Vector` of target data `x` (of length n) and a
`Vector` of all unique possible values in x (of length p).

The element [i, j] is `1` if the i^th target in `x` corresponds to the j^th possible
value and `0` otherwise.

Note that this Transform does not support specifying dims other than `:` (all dims) because
it is a one-to-many transform (for example a `Vector` input produces a `Matrix` output).
"""
struct OneHotEncoding <: Transform
    categories::Dict{Any, Int}

    function OneHotEncoding(possible_values::AbstractVector)
        if length(unique(possible_values)) < length(possible_values)
            throw(ArgumentError("Expected an ordered list of all unique possible values"))
        end

        # Create a dictionary that maps unique values in the input array to column positions
        # in the sparse matrix that results from applying the OneHotEncoding transform
        categories = Dict(value => i for (i, value) in enumerate(possible_values))
        return new(categories)
    end
end

function _apply(x, encoding::OneHotEncoding; kwargs...)
    n_categories = length(encoding.categories)

    results = zeros(Int, length(x), n_categories)

    for (i, value) in enumerate(x)
        col_pos = encoding.categories[value]
        results[i, col_pos] = 1
    end

    return results
end
