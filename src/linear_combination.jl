"""
    LinearCombination(coefficients) <: Transform

Calculate the linear combination using the vector coefficients passed in.
"""
struct LinearCombination <: Transform
    coefficients::Vector{Real}
end

cardinality(::LinearCombination) = ManyToOne()

function _apply(terms, LC::LinearCombination; kwargs...)
    # Need this check because map will work even if there are more/less terms than coeffs
    if length(terms) != length(LC.coefficients)
        throw(DimensionMismatch(
            "Number of terms $(length(terms)) does not match "*
            "number of coefficients $(length(LC.coefficients))."
        ))
    end

   return sum(map(*, terms, LC.coefficients))
end
