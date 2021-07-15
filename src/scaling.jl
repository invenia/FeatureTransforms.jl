"""
    AbstractScaling <: Transform

Linearly scale the data according to some statistics.
"""
abstract type AbstractScaling <: Transform end
cardinality(::AbstractScaling) = OneToOne()

"""
    IdentityScaling <: AbstractScaling

Represents the no-op scaling which simply returns the `data` it is applied on.
"""
struct IdentityScaling <: AbstractScaling end
IdentityScaling(args...) = IdentityScaling()

@inline _apply(x, ::IdentityScaling; kwargs...) = x

"""
    MeanStdScaling(μ, σ) <: AbstractScaling

Linearly scale the data by the statistical mean `μ` and standard deviation `σ`.
This is also known as standardization, or the Z score transform.

# Keyword arguments to `apply`
* `inverse=true`: inverts the scaling (e.g. to reconstruct the unscaled data).
* `eps=1e-3`: used in place of all 0 values in `σ` before scaling (if `inverse=false`).
"""
struct MeanStdScaling <: AbstractScaling
    μ::Real
    σ::Real

    """
        MeanStdScaling(A::AbstractArray; dims=:, inds=:) -> MeanStdScaling
        MeanStdScaling(table, [cols]) -> MeanStdScaling

    Construct a [`MeanStdScaling`](@ref) transform from the statistics of the given data.
    By default _all the data_ is considered when computing the mean and standard deviation.
    This can be restricted to certain slices via the keyword arguments (see below).

    Since `MeanStdScaling` is a stateful transform, i.e. the parameters depend on the data
    it's given, you should define it independently before applying it so you can keep the
    information for later use. For instance, if you want to invert the transform or apply it
    to a test set.

    # `AbstractArray` keyword arguments
    * `dims=:`: the dimension along which to take the `inds` slices. Default uses all dims.
    * `inds=:`: the indices to use in computing the statistics. Default uses all indices.

    # `Table` keyword arguments
    * `cols`: the columns to use in computing the statistics. Default uses all columns.

    !!! note
        If you want the `MeanStdScaling` to transform your data consistently you should use
        the same `inds`, `dims`, or `cols` keywords when calling `apply`. Otherwise, `apply`
        might rescale the wrong data or throw an error.
    """
    function MeanStdScaling(A::AbstractArray; dims=:, inds=:)
        dims == Colon() && return new(compute_stats(A)...)
        return new(compute_stats(selectdim(A, dims, inds))...)
    end

    function MeanStdScaling(table; cols=_get_cols(table))
        Tables.istable(table) || throw(MethodError(MeanStdScaling, table))
        columntable = Tables.columns(table)
        data = reduce(vcat, [getproperty(columntable, c) for c in _to_vec(cols)])
        return new(compute_stats(data)...)
    end
end

compute_stats(x) = (mean(x), std(x))

function _apply(A::AbstractArray, scaling::MeanStdScaling; inverse=false, eps=1e-3, kwargs...)
    inverse && return scaling.μ .+ scaling.σ .* A
    # Avoid division by 0
    # If std is 0 then data was uniform, so the scaled value would end up ≈ 0
    # Therefore the particular `eps` value should not matter much.
    σ_safe = max(scaling.σ, eps)
    return (A .- scaling.μ) ./ σ_safe
end
