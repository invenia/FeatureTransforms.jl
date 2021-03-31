# [Transform Interface](@id transform-interface)

The "transform interface” is a mechanism that allows sequences of `Transform`s to be combined (with other steps) into end-to-end feature engineering pipelines.

This is supported by the return of a `Transform`s having the same type as the input.
This type consistency helps to make `Transform`s _composable_, i.e., the output of one is always a valid input to another, which allows users to "stack" sequences of `Transform`s together with minimal glue code needed to keep it working.

Morever, the end-to-end pipelines themselves should obey the same principle: you should be able to add or remove `Transform`s (or another pipeline) to the output without breaking your code.
That is, the output should also be a valid "transformable" type: either an `AbstractArray`, a `Table`, or other type for which the user has extended [`FeatureTransforms.apply`](@ref) to support.
Valid types can be checked by calling `is_transformable`, which is the first part of the transform interface.

The second part is the `transform` method stub, which users should overload when they want to "encapsulate" an end-to-end pipeline.
The exact method for doing so is an implementation detail for the user but refer to the example below.
The only requirement of the transform API is that the return of the implemented `transform` method is itself "transformable", i.e. satisfies `is_transformable`.
