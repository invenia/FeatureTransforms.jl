# FeatureTransforms

FeatureTransforms.jl provides utilities for performing feature engineering in machine learning pipelines with support for `AbstractArray`s and [`Table`](https://github.com/JuliaData/Tables.jl)s.

## Why does this package exist?

FeatureTransforms.jl aims to provide common feature engineering transforms that are composable, reusable, and performant.

FeatureTransforms.jl is conceptually different from other widely-known packages that provide similar utilities for manipulating data, such as [DataFramesMeta.jl](https://github.com/JuliaData/DataFramesMeta.jl), [DataKnots.jl](https://github.com/rbt-lang/DataKnots.jl), and [Query.jl](https://github.com/queryverse/Query.jl). 
These packages provide methods for composing relational operations to filter, join, or combine structured data. 
However, a query-based syntax or an API that only supports one type are not the most suitable for composing the kinds of mathematical operations, such as one-hot-encoding, that underpin most (non-trivial) feature engineering pipelines. 

The composability of transforms reflects the practice of piping the output of one operation to the input of another, as well as combining the pipelines of multiple features. 
Reusability is achieved by having native support for the `Tables` and `AbstractArray` types, which includes [DataFrames](https://github.com/JuliaData/DataFrames.jl/), [TypedTables](https://github.com/JuliaData/TypedTables.jl), [LibPQ.Result](https://github.com/invenia/LibPQ.jl), etc, as well as [AxisArrays](https://github.com/JuliaArrays/AxisArrays.jl), [KeyedArrays](https://github.com/mcabbott/AxisKeys.jl), and [NamedDimsArrays](https://github.com/invenia/NamedDims.jl). 
This flexible design allows for performant code that should satisfy the needs of most users while not being restricted to (or by) any one data type.
