# [Examples](@id examples)

In the following example, we will imagine we are training a model to predict the temperature and humidity in a city for each hour.

```@meta
DocTestSetup = quote
    using CSV
    using FeatureTransforms

    df = DataFrame(CSV.File(joinpath(dirname(pathof(FeatureTransforms)), "../docs/src/assets/weather.csv")))
```

First we load some hourly weather data:

```julia-repl
julia> using CSV, FeatureTransforms

julia> df = DataFrame(CSV.File(joinpath(dirname(pathof(FeatureTransforms)), "../docs/src/assets/weather.csv")))
24×3 DataFrame
│ Row │ time                │ temperature │ humidity │
│     │ DateTime            │ Float64     │ Float64  │
├─────┼─────────────────────┼─────────────┼──────────┤
│ 1   │ 2018-09-10T00:00:00 │ 10.55       │ 93.7506  │
│ 2   │ 2018-09-10T01:00:00 │ 9.45001     │ 96.1146  │
│ 3   │ 2018-09-10T02:00:00 │ 8.85        │ 94.7647  │
│ 4   │ 2018-09-10T03:00:00 │ 8.85        │ 92.3957  │
│ 5   │ 2018-09-10T04:00:00 │ 8.35        │ 92.656   │
│ 6   │ 2018-09-10T05:00:00 │ 8.35        │ 97.2668  │
│ 7   │ 2018-09-10T06:00:00 │ 7.74999     │ 100.241  │
│ 8   │ 2018-09-10T07:00:00 │ 8.85        │ 96.1578  │
│ 9   │ 2018-09-10T08:00:00 │ 11.65       │ 89.1578  │
│ 10  │ 2018-09-10T09:00:00 │ 13.85       │ 83.241   │
│ 11  │ 2018-09-10T10:00:00 │ 16.15       │ 77.3999  │
│ 12  │ 2018-09-10T11:00:00 │ 17.75       │ 69.7129  │
│ 13  │ 2018-09-10T12:00:00 │ 18.85       │ 65.0906  │
│ 14  │ 2018-09-10T13:00:00 │ 19.95       │ 59.1535  │
│ 15  │ 2018-09-10T14:00:00 │ 21.15       │ 55.1354  │
│ 16  │ 2018-09-10T15:00:00 │ 21.65       │ 54.9058  │
│ 17  │ 2018-09-10T16:00:00 │ 21.65       │ 54.5112  │
│ 18  │ 2018-09-10T17:00:00 │ 21.15       │ 56.8442  │
│ 19  │ 2018-09-10T18:00:00 │ 19.95       │ 60.2864  │
│ 20  │ 2018-09-10T19:00:00 │ 18.35       │ 64.7786  │
│ 21  │ 2018-09-10T20:00:00 │ 16.65       │ 70.7941  │
│ 22  │ 2018-09-10T21:00:00 │ 14.95       │ 77.3468  │
│ 23  │ 2018-09-10T22:00:00 │ 13.85       │ 83.0855  │
│ 24  │ 2018-09-10T23:00:00 │ 12.75       │ 86.9574  │
```

We want to create some data features based on the time of day. One way to do this is with the `Periodic` transform, specifying a period of 1 day:

```jldoctest example
julia> df[:hour_of_day_sin] = FeatureTransforms.apply(df, Periodic(sin, Day(1)); cols=:time);

julia> df[:hour_of_day_cos] = FeatureTransforms.apply(df, Periodic(cos, Day(1)); cols=:time);

julia> df
24×5 DataFrame
│ Row │ time                │ temperature │ humidity │ hour_of_day_sin │ hour_of_day_cos │
│     │ DateTime            │ Float64     │ Float64  │ Float64         │ Float64         │
├─────┼─────────────────────┼─────────────┼──────────┼─────────────────┼─────────────────┤
│ 1   │ 2018-09-10T00:00:00 │ 10.55       │ 93.7506  │ 0.0             │ 1.0             │
│ 2   │ 2018-09-10T01:00:00 │ 9.45001     │ 96.1146  │ 0.258819        │ 0.965926        │
│ 3   │ 2018-09-10T02:00:00 │ 8.85        │ 94.7647  │ 0.5             │ 0.866025        │
│ 4   │ 2018-09-10T03:00:00 │ 8.85        │ 92.3957  │ 0.707107        │ 0.707107        │
│ 5   │ 2018-09-10T04:00:00 │ 8.35        │ 92.656   │ 0.866025        │ 0.5             │
│ 6   │ 2018-09-10T05:00:00 │ 8.35        │ 97.2668  │ 0.965926        │ 0.258819        │
│ 7   │ 2018-09-10T06:00:00 │ 7.74999     │ 100.241  │ 1.0             │ 6.12323e-17     │
│ 8   │ 2018-09-10T07:00:00 │ 8.85        │ 96.1578  │ 0.965926        │ -0.258819       │
│ 9   │ 2018-09-10T08:00:00 │ 11.65       │ 89.1578  │ 0.866025        │ -0.5            │
│ 10  │ 2018-09-10T09:00:00 │ 13.85       │ 83.241   │ 0.707107        │ -0.707107       │
│ 11  │ 2018-09-10T10:00:00 │ 16.15       │ 77.3999  │ 0.5             │ -0.866025       │
│ 12  │ 2018-09-10T11:00:00 │ 17.75       │ 69.7129  │ 0.258819        │ -0.965926       │
│ 13  │ 2018-09-10T12:00:00 │ 18.85       │ 65.0906  │ 1.22465e-16     │ -1.0            │
│ 14  │ 2018-09-10T13:00:00 │ 19.95       │ 59.1535  │ -0.258819       │ -0.965926       │
│ 15  │ 2018-09-10T14:00:00 │ 21.15       │ 55.1354  │ -0.5            │ -0.866025       │
│ 16  │ 2018-09-10T15:00:00 │ 21.65       │ 54.9058  │ -0.707107       │ -0.707107       │
│ 17  │ 2018-09-10T16:00:00 │ 21.65       │ 54.5112  │ -0.866025       │ -0.5            │
│ 18  │ 2018-09-10T17:00:00 │ 21.15       │ 56.8442  │ -0.965926       │ -0.258819       │
│ 19  │ 2018-09-10T18:00:00 │ 19.95       │ 60.2864  │ -1.0            │ -1.83697e-16    │
│ 20  │ 2018-09-10T19:00:00 │ 18.35       │ 64.7786  │ -0.965926       │ 0.258819        │
│ 21  │ 2018-09-10T20:00:00 │ 16.65       │ 70.7941  │ -0.866025       │ 0.5             │
│ 22  │ 2018-09-10T21:00:00 │ 14.95       │ 77.3468  │ -0.707107       │ 0.707107        │
│ 23  │ 2018-09-10T22:00:00 │ 13.85       │ 83.0855  │ -0.5            │ 0.866025        │
│ 24  │ 2018-09-10T23:00:00 │ 12.75       │ 86.9574  │ -0.258819       │ 0.965926        │
```

Now suppose we want to use the first 22 hours as training data and the last 2 hours as test data. Our input features are the temperature, humidity, and periodic encodings for the current hour, and the outputs to predict are the temperature and humidity for the next hour. 

```jldoctest example
julia> train_df = df[1:end-2, :];

julia> test_df = df[end-1:end, :];

julia> input_cols = [:hour_of_day_sin, :hour_of_day_cos, :temperature, :humidity];

julia> output_cols = [:temperature, :humidity];
```

For many models it is helpful to normalize the training data. We can use `MeanStdScaling` for that purpose. Note that the order of columns to normalise does not matter.

```jldoctest example
julia> scaling = MeanStdScaling(train_df; cols=input_cols)
MeanStdScaling((hour_of_day_sin = 0.034491774777387345, hour_of_day_cos = -0.08327051045788672, temperature = 14.759097844904142, humidity = 77.35023484533735), (hour_of_day_sin = 0.7450420149958867, hour_of_day_cos = 0.6957161361485084, temperature = 5.196606820925868, humidity = 16.62585535548143))

julia> FeatureTransforms.apply!(train_df, scaling; cols=input_cols)
22×5 DataFrame
│ Row │ time                │ temperature │ humidity     │ hour_of_day_sin │ hour_of_day_cos │
│     │ DateTime            │ Float64     │ Float64      │ Float64         │ Float64         │
├─────┼─────────────────────┼─────────────┼──────────────┼─────────────────┼─────────────────┤
│ 1   │ 2018-09-10T00:00:00 │ -0.809968   │ 0.986439     │ -0.0462951      │ 1.55706         │
│ 2   │ 2018-09-10T01:00:00 │ -1.02165    │ 1.12862      │ 0.301093        │ 1.50808         │
│ 3   │ 2018-09-10T02:00:00 │ -1.13711    │ 1.04744      │ 0.624808        │ 1.36449         │
│ 4   │ 2018-09-10T03:00:00 │ -1.13711    │ 0.904945     │ 0.902788        │ 1.13606         │
│ 5   │ 2018-09-10T04:00:00 │ -1.23332    │ 0.920599     │ 1.11609         │ 0.838374        │
│ 6   │ 2018-09-10T05:00:00 │ -1.23332    │ 1.19793      │ 1.25018         │ 0.491709        │
│ 7   │ 2018-09-10T06:00:00 │ -1.34878    │ 1.37682      │ 1.29591         │ 0.11969         │
│ 8   │ 2018-09-10T07:00:00 │ -1.13711    │ 1.13122      │ 1.25018         │ -0.252328       │
│ 9   │ 2018-09-10T08:00:00 │ -0.59829    │ 0.710191     │ 1.11609         │ -0.598994       │
│ 10  │ 2018-09-10T09:00:00 │ -0.174941   │ 0.354312     │ 0.902788        │ -0.896682       │
│ 11  │ 2018-09-10T10:00:00 │ 0.267659    │ 0.00298691   │ 0.624808        │ -1.12511        │
│ 12  │ 2018-09-10T11:00:00 │ 0.575548    │ -0.459367    │ 0.301093        │ -1.2687         │
│ 13  │ 2018-09-10T12:00:00 │ 0.787226    │ -0.737384    │ -0.0462951      │ -1.31768        │
│ 14  │ 2018-09-10T13:00:00 │ 0.998903    │ -1.09448     │ -0.393684       │ -1.2687         │
│ 15  │ 2018-09-10T14:00:00 │ 1.22983     │ -1.33616     │ -0.717398       │ -1.12511        │
│ 16  │ 2018-09-10T15:00:00 │ 1.32604     │ -1.34997     │ -0.995378       │ -0.896682       │
│ 17  │ 2018-09-10T16:00:00 │ 1.32604     │ -1.37371     │ -1.20868        │ -0.598994       │
│ 18  │ 2018-09-10T17:00:00 │ 1.22983     │ -1.23338     │ -1.34277        │ -0.252328       │
│ 19  │ 2018-09-10T18:00:00 │ 0.998903    │ -1.02634     │ -1.3885         │ 0.11969         │
│ 20  │ 2018-09-10T19:00:00 │ 0.691009    │ -0.75615     │ -1.34277        │ 0.491709        │
│ 21  │ 2018-09-10T20:00:00 │ 0.363876    │ -0.394332    │ -1.20868        │ 0.838374        │
│ 22  │ 2018-09-10T21:00:00 │ 0.0367371   │ -0.000206509 │ -0.995378       │ 1.13606         │
```

We can use the same `scaling` transform to normalize the test data:

```jldoctest example
julia> FeatureTransforms.apply!(test_df, scaling; cols=data_cols)
2×5 DataFrame
│ Row │ time                │ temperature │ humidity │ hour_of_day_sin │ hour_of_day_cos │
│     │ DateTime            │ Float64     │ Float64  │ Float64         │ Float64         │
├─────┼─────────────────────┼─────────────┼──────────┼─────────────────┼─────────────────┤
│ 1   │ 2018-09-10T22:00:00 │ -0.174941   │ 0.344958 │ -0.717398       │ 1.36449         │
│ 2   │ 2018-09-10T23:00:00 │ -0.386618   │ 0.577845 │ -0.393684       │ 1.50808         │
```

Suppose we then train our model, and get a prediction for the test points as a matrix: `[-0.36 0.61; -0.45 0.68]`. We can scale this back to the original units of temperature and humidity by converting to a `Table` type (to label the columns) and using inverse scaling:

```jldoctest example
julia> predictions = DataFrame([-0.36 0.61; -0.45 0.68], output_cols);

julia> FeatureTransforms.apply!(predictions, scaling; cols=output_cols, inverse=true)
2×2 DataFrame
│ Row │ temperature │ humidity │
│     │ Float64     │ Float64  │
├─────┼─────────────┼──────────┤
│ 1   │ 12.8883     │ 87.492   │
│ 2   │ 12.4206     │ 88.6558  │
```

```@meta
DocTestSetup = Nothing
```
