# [Transform Interface](@id transform-interface)

The "transform interface” is a mechanism that allows sequences of `Transform`s to be combined (with other steps) into end-to-end feature engineering pipelines.

This is supported by the return of a `Transform`s having the same type as the input.
This type consistency helps to make `Transform`s _composable_, i.e., the output of one is always a valid input to another, which allows users to "stack" sequences of `Transform`s together with minimal glue code needed to keep it working.

Morever, the end-to-end pipelines themselves should obey the same principle: you should be able to add or remove `Transform`s (or another pipeline) to the output without breaking your code.
That is, the output should also be a valid "transformable" type: either an `AbstractArray`, a `Table`, or other type for which the user has extended [`FeatureTransforms.apply`](@ref) to support.
Valid types can be checked by calling `is_transformable`, which is the first part of the transform interface.

The second part is the `transform` method stub, which users should overload when they want to "encapsulate" an end-to-end pipeline.
The exact method for doing so is an implementation detail for the user but refer to the code below as an example.
The only requirement of the transform API is that the return of the implemented `transform` method is itself "transformable", i.e. satisfies `is_transformable`.

## Example

This is a trivial example of a feature engineering pipeline. 
In practice, there may be other steps involved, such as checking for missing data or logging, which are omitted for clarity.
An advantage of the transform API is that the output can be readily integrated into another transform pipeline downstream. 
For example, if `MyModel` were being stacked with the result of a previous model.

```julia
function FeatureTransforms.transform(::MyModel, data::DataFrame)
    # Define the Transforms we will apply
    p = Power(0.123)
    lc = LinearCombination([0.1, 0.9])
    ohe = OneHotEncoding(["Type1", "Type2", "Type"])
    
    features = deepcopy(data)
    FeatureTransforms.apply!(features, p; cols=[:a])
    features = FeatureTransforms.apply_append(features, lc; cols=[:b, :c], header=[:bc])
    features = FeatureTransforms.apply_append(features, ohe; cols=:types, header=[:type1, :type2, :type3])

    return select!(features, [:a, :bc, :type1, :type2, :type3]) 
end

# test that the output is transformable
output = transform(my_model, my_data))
is_transformable(output)
```
