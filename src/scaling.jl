"""
    Scaling <: Transform

Linearly scale the data as `ax + b`, according to some statistics `a` and `b`.
"""
abstract type Scaling <: Transform end

"""
    MeanStdScaling(mean, std) <: Scaling

Linearly scale the data by a statistical `mean` and standard deviation `std`.
This is also known as standardization, or the Z score transform.
Once computed, the statistics of a `MeanStdScaling` are immutable.

Can take a precomputed `mean` and `std` as arguments, or compute them from data.

# Arguments
* `mean::NamedTuple`: tuple of mean values, named by the scope of values it applies to.
  `(all=μ, )` will apply to all data; `(1=μ1, 2=μ2)` for `AbstractArray` data will apply μ1
  to the first slice and μ2 to the second slice; `(a=μ1, b=μ2)` for `Table` data will apply
  μ1 to column `a` and μ2 to column `b`.
* `std::NamedTuple`: similar to `mean` but for standard deviation values.

# Keyword arguments to `apply`
* `inverse=true`: inverts the scaling (e.g. to reconstruct the unscaled data)
* `eps=1e-3`: replaces all 0 values in `std` before scaling (if `inverse=false`)
"""
struct MeanStdScaling <: Scaling
    mean::NamedTuple
    std::NamedTuple
end

"""
    MeanStdScaling(data; kwargs...) <: Scaling

Construct a [`MeanStdScaling`](@ref) using the mean and standard deviation of the data.

!!! note
    `dims` and `cols` keyword arguments must be specified the same way when constructing
    and applying the transform.
    Otherwise, the results will be inconsistent, or an error may occur.

# Keyword arguments
* `dims=:`: for `AbstractArray` data, the dimension(s) to compute statistics along.
* `cols=nothing`: for `Table` data, the column names to compute statistics for.
"""
function MeanStdScaling(data; kwargs...)
    μ, σ = compute_stats(data; kwargs...)
    return MeanStdScaling(μ, σ)
end

function compute_stats(A::AbstractArray; dims=:)
    if dims == Colon()
        μ = (all = mean(A), )
        σ = (all = std(A), )
    else
        μ_pairs = [(Symbol(i), x) for (i, x) in enumerate(mean(A; dims=dims))]
        σ_pairs = [(Symbol(i), x) for (i, x) in enumerate(std(A; dims=dims))]

        μ = (; μ_pairs...)
        σ = (; σ_pairs...)
    end

    return μ, σ
end

function compute_stats(table; cols=nothing)
    columntable = Tables.columns(table)
    cnames = cols === nothing ? propertynames(columntable) : cols

    μ_pairs = [(cname, mean(getproperty(columntable, cname))) for cname in cnames]
    σ_pairs = [(cname, std(getproperty(columntable, cname))) for cname in cnames]

    return (; μ_pairs...), (; σ_pairs...)
end

function _apply(
    A::AbstractArray, scaling::MeanStdScaling;
    name=nothing, inverse=false, eps=1e-3, kwargs...
)
    name = name === nothing ? :all : name
    μ = scaling.mean[name]
    σ = scaling.std[name]
    if inverse
        return μ .+ σ .* A
    else
        # Avoid division by 0
        # If std is 0 then data was uniform, so the scaled value would end up ≈ 0
        # Therefore the particular `eps` value should not matter much.
        σ_safe = σ == 0 ? eps : σ
        return (A .- μ) ./ σ_safe
    end
end
