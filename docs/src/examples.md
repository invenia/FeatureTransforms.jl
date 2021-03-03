# [Examples](@id examples)

In the following example, we will imagine we are training a model to predict the temperature and humidity in a city for each hour.

First we load some hourly weather data:

```jldoctest example
julia> using DataFrames, Dates, FeatureTransforms

julia> df = DataFrame(
            :time => DateTime(2018, 9, 10):Hour(1):DateTime(2018, 9, 10, 23),
            :temperature => [10.6, 9.5, 8.9, 8.9, 8.4, 8.4, 7.7, 8.9, 11.7, 13.9, 16.2, 17.7, 18.9, 20.0, 21.2, 21.7, 21.7, 21.2, 20.0, 18.4, 16.7, 15.0, 13.9, 12.7],
            :humidity => [93.8, 96.1, 94.8, 92.4, 92.7, 97.3, 100.2, 96.2, 89.2, 83.2, 77.4, 69.7, 65.1, 59.2, 55.1, 54.9, 54.5, 56.8, 60.3, 64.8, 70.8, 77.3, 83.1, 87.0],
        )
24×3 DataFrame
 Row │ time                 temperature  humidity
     │ DateTime             Float64      Float64
─────┼────────────────────────────────────────────
   1 │ 2018-09-10T00:00:00         10.6      93.8
   2 │ 2018-09-10T01:00:00          9.5      96.1
   3 │ 2018-09-10T02:00:00          8.9      94.8
   4 │ 2018-09-10T03:00:00          8.9      92.4
   5 │ 2018-09-10T04:00:00          8.4      92.7
   6 │ 2018-09-10T05:00:00          8.4      97.3
   7 │ 2018-09-10T06:00:00          7.7     100.2
   8 │ 2018-09-10T07:00:00          8.9      96.2
  ⋮  │          ⋮                ⋮          ⋮
  18 │ 2018-09-10T17:00:00         21.2      56.8
  19 │ 2018-09-10T18:00:00         20.0      60.3
  20 │ 2018-09-10T19:00:00         18.4      64.8
  21 │ 2018-09-10T20:00:00         16.7      70.8
  22 │ 2018-09-10T21:00:00         15.0      77.3
  23 │ 2018-09-10T22:00:00         13.9      83.1
  24 │ 2018-09-10T23:00:00         12.7      87.0
                                    9 rows omitted
```

We want to create some data features based on the time of day.
One way to do this is with the `Periodic` transform, specifying a period of 1 day:

```jldoctest example
julia> df.hour_of_day_sin = FeatureTransforms.apply(df, Periodic(sin, Day(1)); cols=:time);

julia> feature_df = df
24×4 DataFrame
 Row │ time                 temperature  humidity  hour_of_day_sin
     │ DateTime             Float64      Float64   Float64
─────┼─────────────────────────────────────────────────────────────
   1 │ 2018-09-10T00:00:00         10.6      93.8         0.0
   2 │ 2018-09-10T01:00:00          9.5      96.1         0.258819
   3 │ 2018-09-10T02:00:00          8.9      94.8         0.5
   4 │ 2018-09-10T03:00:00          8.9      92.4         0.707107
   5 │ 2018-09-10T04:00:00          8.4      92.7         0.866025
   6 │ 2018-09-10T05:00:00          8.4      97.3         0.965926
   7 │ 2018-09-10T06:00:00          7.7     100.2         1.0
   8 │ 2018-09-10T07:00:00          8.9      96.2         0.965926
  ⋮  │          ⋮                ⋮          ⋮             ⋮
  18 │ 2018-09-10T17:00:00         21.2      56.8        -0.965926
  19 │ 2018-09-10T18:00:00         20.0      60.3        -1.0
  20 │ 2018-09-10T19:00:00         18.4      64.8        -0.965926
  21 │ 2018-09-10T20:00:00         16.7      70.8        -0.866025
  22 │ 2018-09-10T21:00:00         15.0      77.3        -0.707107
  23 │ 2018-09-10T22:00:00         13.9      83.1        -0.5
  24 │ 2018-09-10T23:00:00         12.7      87.0        -0.258819
                                                     9 rows omitted
```

Now suppose we want to use the first 22 hours as training data and the last 2 hours as test data.
Our input features are the temperature, humidity, and periodic encodings for the current hour, and the outputs to predict are the temperature and humidity for the next hour. 

```jldoctest example
julia> train_df = feature_df[1:end-2, :];

julia> test_df = feature_df[end-1:end, :];

julia> input_cols = [:hour_of_day_sin, :temperature, :humidity];

julia> output_cols = [:temperature, :humidity];
```

For many models it is helpful to normalize the training data.
We can use `MeanStdScaling` for that purpose.
Note that the order of columns to normalise does not matter.

```jldoctest example
julia> scaling = MeanStdScaling(train_df; cols=input_cols);

julia> FeatureTransforms.apply!(train_df, scaling; cols=input_cols)
22×4 DataFrame
 Row │ time                 temperature  humidity     hour_of_day_sin
     │ DateTime             Float64      Float64      Float64
─────┼────────────────────────────────────────────────────────────────
   1 │ 2018-09-10T00:00:00   -0.807635    0.98858          -0.0462951
   2 │ 2018-09-10T01:00:00   -1.01916     1.12684           0.301093
   3 │ 2018-09-10T02:00:00   -1.13454     1.04869           0.624808
   4 │ 2018-09-10T03:00:00   -1.13454     0.904422          0.902788
   5 │ 2018-09-10T04:00:00   -1.23068     0.922456          1.11609
   6 │ 2018-09-10T05:00:00   -1.23068     1.19897           1.25018
   7 │ 2018-09-10T06:00:00   -1.36529     1.3733            1.29591
   8 │ 2018-09-10T07:00:00   -1.13454     1.13285           1.25018
  ⋮  │          ⋮                ⋮            ⋮              ⋮
  16 │ 2018-09-10T15:00:00    1.32683    -1.3498           -0.995378
  17 │ 2018-09-10T16:00:00    1.32683    -1.37385          -1.20868
  18 │ 2018-09-10T17:00:00    1.23068    -1.23559          -1.34277
  19 │ 2018-09-10T18:00:00    0.99993    -1.02519          -1.3885
  20 │ 2018-09-10T19:00:00    0.692259   -0.754687         -1.34277
  21 │ 2018-09-10T20:00:00    0.365359   -0.394011         -1.20868
  22 │ 2018-09-10T21:00:00    0.0384588  -0.00327887       -0.995378
                                                        7 rows omitted
```

We can use the same `scaling` transform to normalize the test data:

```jldoctest example
julia> FeatureTransforms.apply!(test_df, scaling; cols=input_cols)
2×4 DataFrame
 Row │ time                 temperature  humidity  hour_of_day_sin 
     │ DateTime             Float64      Float64   Float64         
─────┼─────────────────────────────────────────────────────────────
   1 │ 2018-09-10T22:00:00    -0.173065  0.345374        -0.717398
   2 │ 2018-09-10T23:00:00    -0.403818  0.579814        -0.393684
```

Suppose we then train our model, and get a prediction for the test points as a matrix: `[-0.36 0.61; -0.45 0.68]`.
We can scale this back to the original units of temperature and humidity by converting to a `Table` type (to label the columns) and using inverse scaling:

```jldoctest example
julia> predictions = DataFrame([-0.36 0.61; -0.45 0.68], output_cols);

julia> FeatureTransforms.apply!(predictions, scaling; cols=output_cols, inverse=true)
2×2 DataFrame
 Row │ temperature  humidity 
     │ Float64      Float64  
─────┼───────────────────────
   1 │     12.9279   87.5022
   2 │     12.4598   88.6666
```
