# [Transform Interface](@id transform-interface)

The idea around a "transform interface” is to make feature transformations composable, i.e. the output of one `Transform` should be valid input to another.

Feature engineering pipelines, which comprise a sequence of multiple `Transform`s and other steps, should obey the same principle and one should be able to add/remove subsequent `Transform`s without the pipeline breaking.
So the output of an end-to-end transform pipeline should itself be "transformable".

We have enforced this in Transforms.jl by only supporting certain input types, i.e. AbstractArrays and Tables, which produce other AbstractArrays and Tables.
We also have specified this in the `transform` function API, which is expected to be overloaded for implementing pipelines (the exact method is an implementation detail for the user).
Our only requirement is that the return of the implemented `transform` is itself "transformable", i.e. an AbstractArray or Table.
This can be checked by calling `is_transformable` on the output.
