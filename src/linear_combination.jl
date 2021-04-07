"""
    LinearCombination(coefficients) <: Transform

Calculates the linear combination of a collection of terms weighted be some `coefficients`.

When applied to an N-dimensional array, `LinearCombination` reduces along the `dim` provided
and returns an (N-1)-dimensional array.

If no `inds` are specified, then the transform is applied to all elements.
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
