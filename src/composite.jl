"""
   Composite <: Transform

A `Composite` transform is a composition of `Transform`s, currently limited to `OneToOne()`
cardinality. It can be fit and applied in a single step.

The transforms in `Composite([t1, t2, t3])` are applied in `t1`, `t2`, `t3` order, where
the output of `t1` is the input to `t2` etc. When using `∘` to create transforms, the order
is `t3 ∘ t2 ∘ t1`, as in function composition.

```jldoctest composite
julia> id = IdentityScaling();

julia> power = Power(2.0);

julia> id ∘ power == Composite([power, id])
true
```
"""
struct Composite <: Transform
    transforms::Tuple{Vararg{Transform}}

    function Composite(transforms::Tuple{Vararg{Transform}})
        all(==(OneToOne()), map(cardinality, transforms)) && return new(transforms)
        throw(ArgumentError("Only OneToOne() transforms are supported."))
    end
end

cardinality(c::Composite) = ∘(map(cardinality, c.transforms)...)

function fit!(c::Composite, data; kwargs...)
    for t in c.transforms
        fit!(t, data; kwargs...)
        data = t(data)
    end
    return c
end

function _apply(x, c::Composite; kwargs...)
    data = deepcopy(x)
    for t in c.transforms
        data = _apply(data, t; kwargs...)
    end
    return data
end

# creating composite transforms: reverse the order so that c.transforms[1] is the first
# transforms that gets applied
Base.:(∘)(f::Transform, g::Transform) = Composite((g, f))
Base.:(∘)(c::Composite, t::Transform) = Composite((t, c.transforms...))
Base.:(∘)(t::Transform, c::Composite) = Composite((c.transforms..., t))
Base.:(∘)(c::Composite, c2::Composite) = Composite((c2.transforms..., c.transforms...))

Base.:(==)(c::Composite, d::Composite) = return all(map(==, c.transforms, d.transforms))
