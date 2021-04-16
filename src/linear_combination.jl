"""
    LinearCombination(coefficients) <: Transform

Calculate the linear combination using the vector coefficients passed in.
"""
struct LinearCombination <: Transform
    coefficients::Vector{Real}
end

cardinality(::LinearCombination) = ManyToOne()

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

    return _sum_terms(eachslice(selectdim(A, dims, inds); dims=dims), LC.coefficients)
end

"""
    apply(table, LC::LinearCombination; [cols], [header]) -> Table

Applies the [`LinearCombination`](@ref) across the specified cols in `table`. If no `cols`
are specified, then the [`LinearCombination`](@ref) is applied to all columns.

Optionally provide a `header` for the output table. If none is provided the default in
`Tables.table` is used.
"""
function apply(table, LC::LinearCombination; cols=_get_cols(table), header=nothing, kwargs...)
    Tables.istable(table) || throw(MethodError(apply, (table, LC)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    coltable = Tables.columntable(table)
    cols = _to_vec(cols)

    result = hcat(_sum_terms([getproperty(coltable, col) for col in cols], LC.coefficients))
    return Tables.materializer(table)(_to_table(result, header))
end

function apply_append(
    A::AbstractArray{<:Real, N}, LC::LinearCombination; append_dim, kwargs...
)::AbstractArray{<:Real, N} where N
    # A was reduced along the append_dim so we must reshape the result setting that dim to 1
    new_size = collect(size(A))
    setindex!(new_size, 1, dim(A, append_dim))
    return cat(A, reshape(apply(A, LC; kwargs...), new_size...); dims=append_dim)
end

function _sum_terms(terms, coeffs)
    # Need this check because map will work even if there are more/less terms than coeffs
    if length(terms) != length(coeffs)
        throw(DimensionMismatch(
            "Number of terms $(length(terms)) does not match "*
            "number of coefficients $(length(coeffs))."
        ))
    end
   return sum(map(*, terms, coeffs))
end
