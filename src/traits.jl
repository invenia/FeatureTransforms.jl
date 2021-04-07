"""
    type Cardinality

A trait describing the cardinality of a [`Transform`]. Available cardinalities are:
[`OneToOne`](@ref), [`ManyToOne`](@ref), [`OneToMany`](@ref), and [`ManyToMany`](@ref).
"""
abstract type Cardinality end

"""
    OneToOne <: Cardinality

Transforms that map each input to exactly one output: `x → y`.
Examples: [`Power`](@ref), [`Periodic`](@ref).
"""
struct OneToOne <: Cardinality end

"""
    ManyToOne <: Cardinality

Transforms that map many inputs to one output: `(x_1, x_2, ..., x_n) → y`.
These are typically reduction operations.
Examples: [`LinearCombination`](@ref).
"""
struct ManyToOne <: Cardinality end

"""
    OneToMany <: Cardinality

Transforms that map one input to many outputs: `x → (y_1, y_2, ..., y_n)`.
Examples: [`OneHotEncoding`](@ref).
"""
struct OneToMany <: Cardinality end

"""
    ManyToMany <: Cardinality

Transforms that map many inputs to many outputs: `(x_1, x_2, ..., x_m) → (y_1, y_2, ..., y_n)`.
Examples: Principle Component Analysis (not implemented).
"""
struct ManyToMany <: Cardinality end


"""
    cardinality(transform) -> Cardinality

Returns the [`Cardinality`](@ref) of the `transform`.
"""
function cardinality end
