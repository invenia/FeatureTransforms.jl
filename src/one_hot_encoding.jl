"""
    OneHotEncoding{R<:Real} <: Transform

One-hot encode the categorical value for each target element.

Construct a n-by-p binary matrix, given a `Vector` of target data `x` (of length n) and a
`Vector` of all unique possible values in x (of length p).

The element [i, j] is `true` if the i^th target in `x` corresponds to the j^th possible
value and `false` otherwise. Note that `R`can be specified to determine the return type
of results. It defaults to a `Matrix` of `Bool`s.

Note that this Transform does not support specifying dims other than `:` (all dims) because
it is a one-to-many transform (for example a `Vector` input produces a `Matrix` output).
"""
struct OneHotEncoding{R<:Real, T} <: Transform
    categories::Dict{T, Int}

    function OneHotEncoding{R}(possible_values::AbstractVector{T}) where {R<:Real, T}
        if length(unique(possible_values)) < length(possible_values)
            throw(ArgumentError("Expected a list of all unique possible values"))
        end

        # Create a dictionary that maps unique values in the input array to column positions
        # in the sparse matrix that results from applying the OneHotEncoding transform
        categories = Dict(value => i for (i, value) in enumerate(possible_values))
        return new{R, T}(categories)
    end
end

function OneHotEncoding(possible_values::AbstractVector{T}) where T
    return OneHotEncoding{Bool}(possible_values)
end

function _apply(x, encoding::OneHotEncoding{R}; kwargs...) where R <: Real
    n_categories = length(encoding.categories)
    results = zeros(R, length(x), n_categories)

    for (i, value) in enumerate(x)
        col_pos = encoding.categories[value]
        results[i, col_pos] = true
    end

    return results
end
