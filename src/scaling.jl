"""
    Scaling <: Transform

Linearly scale the data as `ax + b`, according to some statistics `a` and `b`.
"""
abstract type Scaling <: Transform end

"""
    IdentityScaling

Represents the no-op scaling which simply returns the data it is applied on.
"""
struct IdentityScaling <: Scaling end
# Convenience method
IdentityScaling(args...; kwargs...) = IdentityScaling()

apply!(x, ::IdentityScaling; kwargs...) = x

"""
    MeanStdScaling(mean, std) <: Scaling

Linearly scale the data by a statistical `mean` and standard deviation `std`.
The first `mean` and `std` calculated on some data will remain fixed.
"""
struct MeanStdScaling <: Scaling
    # Dict keeps track of slices to protect against changes e.g. Table column order
    # Is this going too far to generalise between Arrays and Tables? Should we use
    # separate/parameterised structs?
    mean::Dict{Symbol, AbstractFloat}
    std::Dict{Symbol, AbstractFloat}

    """
        MeanStdScaling() <: Scaling

    Construct a `MeanStdScaling` transform which will populate its `mean` and `std`
    parameters from the first data it is applied to.
    """
    MeanStdScaling() = new(Dict(), Dict())
end

"""
    MeanStdScaling(data; kwargs...) <: Scaling

Construct a [`MeanStdScaling`](@ref) using the mean and standard deviation of the data.

# Keyword arguments
*
"""
function MeanStdScaling(data; kwargs...)
    scaling = MeanStdScaling()
    populate_stats!(scaling, data; kwargs...)
    return scaling
end

function populate_stats!(scaling::MeanStdScaling, A::AbstractArray; dims=:)
    if dims == Colon()
        scaling.mean[:all] = mean(A)
        scaling.std[:all] = std(A)
    else
        for (i, x) in enumerate(eachslice(A; dims=dims))
            scaling.mean[Symbol(i)] = mean(x)
            scaling.std[Symbol(i)] = std(x)
        end
    end

    return scaling
end

function populate_stats!(scaling::MeanStdScaling, table; cols=nothing)
    columntable = Tables.columns(table)
    cnames = cols === nothing ? propertynames(columntable) : cols
    for cname in cnames
        x = getproperty(columntable, cname)
        scaling.mean[cname] = mean(x)
        scaling.std[cname] = std(x)
    end
end

"""
    apply!(A::AbstractArray, ::Transform; dims=:, kwargs...)

Applies [`MeanStdScaling`](@ref) to each element of `A`.
Optionally specify the `dims` to apply [`MeanStdScaling`](@ref) along certain dimensions,
and `inverse=true` to reconstruct the originally scaled data from `A`.
For `inverse=false`, all 0 std values get replaced by the value `eps` before scaling.
"""
function apply!(
    A::AbstractArray, scaling::MeanStdScaling;
    dims=:, inverse=false, eps=1e-3, kwargs...
)
    if isempty(scaling.mean) || isempty(scaling.std)
        # Populate with mean and std of this data, once and for all
        populate_stats!(scaling, A; dims=dims)
    end

    dims == Colon() && return _apply!(A, scaling; inverse=inverse, eps=eps, kwargs...)

    for (i, x) in enumerate(eachslice(A; dims=dims))
        _apply!(x, scaling; name=Symbol(i), inverse=inverse, eps=eps, kwargs...)
    end

    return A
end

"""
    _apply!(
        A::AbstractArray, t::MeanStdScaling;
        dims=:, inverse=false, kwargs...
    )

Applies [`MeanStdScaling`](@ref) to each element of `A`.
Optionally specify the `dims` to apply [`MeanStdScaling`](@ref) along certain dimensions,
and `inverse=true` to reconstruct the originally scaled data from `A`.
For `inverse=false`, all 0 std values get replaced by the value `eps` before scaling.
"""
function _apply!(
    A::AbstractArray, scaling::MeanStdScaling;
    name=nothing, inverse=false, eps=1e-3, kwargs...
)
    name = name === nothing ? :all : name
    μ = scaling.mean[name]
    σ = scaling.std[name]
    if inverse
        A[:] = μ .+ σ .* A
    else
        # Avoid division by 0
        # If std is 0 then data was uniform, so the scaled value would end up ≈0
        # Therefore the particular `eps` value should not matter much.
        σ_safe = σ == 0 ? eps : σ
        A[:] = (A .- μ) ./ σ_safe
    end
    return A
end

function apply(A::AbstractArray, scaling::MeanStdScaling; kwargs...)
    return apply!(_try_copy(A), scaling; kwargs...)
end

"""
    apply!(table::T, scaling::MeanStdScaling; cols=nothing, kwargs...)::T where T

Applies the [`MeanStdScaling`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`MeanStdScaling`](@ref) is applied to all columns.
Optionally specify `inverse=true` to reconstruct the originally scaled data.
For `inverse=false`, all 0 std values get replaced by the value `eps` before scaling.
"""
function apply!(table::T, scaling::MeanStdScaling; cols=nothing, kwargs...)::T where T
    # TODO: We could probably handle iterators of tables here
    Tables.istable(table) || throw(MethodError(apply!, (table, scaling)))

    if isempty(scaling.mean) || isempty(scaling.std)
        # Populate with mean and std of this data, once and for all
        populate_stats!(scaling, table; cols=cols)
    end

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)

    cnames = cols === nothing ? propertynames(columntable) : cols
    for cname in cnames
        apply!(getproperty(columntable, cname), scaling; name=cname, kwargs...)
    end

    return table
end

"""
    apply(table, scaling::MeanStdScaling; cols=nothing, kwargs...)

Applies the [`MeanStdScaling`](@ref) to each of the specified columns in the `table`.
If no `cols` are specified, then the [`MeanStdScaling`](@ref) is applied to all columns.
Optionally specify `inverse=true` to reconstruct the originally scaled data.
For `inverse=false`, all 0 std values get replaced by the value `eps` before scaling.
"""
function apply(table, scaling::MeanStdScaling; cols=nothing, kwargs...)
    # TODO: We could probably handle iterators of tables here
    Tables.istable(table) || throw(MethodError(apply!, (table, scaling)))

    if isempty(scaling.mean) || isempty(scaling.std)
        # Populate with mean and std of this data, once and for all
        populate_stats!(scaling, table; cols=cols)
    end

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)

    cnames = cols === nothing ? propertynames(columntable) : cols

    return [apply(getproperty(columntable, cname), scaling; name=cname, kwargs...) for cname in cnames]
end
