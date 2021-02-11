@testset "periodic" begin
    @testset "_periodic" begin
        @testset "$f" for f in (sin, cos)
            @testset "Typical 24-hour day" begin
                day_typical = ZonedDateTime(2015, 6, 1, tz"America/Winnipeg")
                hours_typical = day_typical .+ collect(Hour.(0:2))
                result = _periodic.(f, hours_typical, Day(1))
                expected = Dict(sin => [0., 0.2588, 0.5], cos => [1.0, 0.9659, 0.866])
                @test result ≈ expected[f] atol=1e-4
            end

            @testset "Spring daylight-saving time change (23 hours)" begin
                day_spring_dst = ZonedDateTime(2015, 3, 8, tz"America/Winnipeg")
                hours_spring_dst = day_spring_dst .+ collect(Hour.(0:2))
                result = _periodic.(f, hours_spring_dst, Day(1))
                expected = Dict(sin => [0., 0.2698, 0.5196], cos => [1., 0.9629, 0.8544])
                @test result ≈ expected[f] atol=1e-4
            end

            @testset "Fall daylight-saving time change (25 hours)" begin
                day_fall_dst = ZonedDateTime(2015, 11, 1, tz"America/Winnipeg")
                hours_fall_dst = day_fall_dst .+ collect(Hour.(0:2))
                result = _periodic.(f, hours_fall_dst, Day(1))
                expected = Dict(sin => [0., 0.2487, 0.4818], cos => [1., 0.9686, 0.8763])
                @test result ≈ expected[f] atol=1e-4
            end
        end

        @testset "phase shift" begin
            @test _periodic(sin, DateTime(2018), Week(1)) == 0
            @test _periodic(sin, DateTime(2018), Week(1), Day(7)) == 0
            @test _periodic(sin, DateTime(2018), Week(1), Day(-7)) == 0

            @test _periodic(sin, DateTime(2019), Week(1)) ≈ 0.7818 atol=1e-4
            @test _periodic(sin, DateTime(2019), Week(1), Day(7)) ≈ 0.7818 atol=1e-4
            @test _periodic(sin, DateTime(2019), Week(1), Day(5)) ≈ 0.4339 atol=1e-4

            # Using the phase shift we can make a Thursday the beginning of the week
            # (i.e. such that sin(t) == 0). The UNIX epoch 1970-01-01 fell on Thursday.
            # NOTE: these calculations can change depending on the period type given.
            @test _periodic(sin, DateTime(1970), Week(1), Day(3)) == 0
            @test _periodic(sin, DateTime(1970), Second(Week(1)), Day(5)) == 0

            # Phase shifts larger than the period should not change the result
            @test ==(
                _periodic(sin, DateTime(1970), Day(1), Day(0)),
                _periodic(sin, DateTime(1970), Day(1), Day(5)),
            )
        end
    end

    @testset "Real input" begin
        @testset "Constructors" begin
            @testset "Default" begin
                p = Periodic(sin, 5, 2)
                @test p isa Transform
                @test p.period == 5
                @test p.phase_shift == 2
            end

            @testset "No phase_shift" begin
                p = Periodic(sin, 5)
                @test p isa Transform
                @test p.period == 5
                @test p.phase_shift == 0
            end
        end

        expected_dict = Dict(
            sin => [
                -0.5877852522924732,
                -0.9510565162951535,
                0.0,
                0.9510565162951535,
                0.5877852522924732,
                -0.58778525229247
            ],
            cos => [
                -0.8090169943749473,
                0.30901699437494745,
                1.0,
                0.30901699437494745,
               -0.8090169943749473,
               -0.8090169943749475
            ]
        )

        @testset "$f" for f in (sin, cos)
            expected = expected_dict[f]
            p = Periodic(f, 5, 2)

            @testset "Vector" begin
                x = collect(0.:5.)

                @test Transforms.apply(x, p) ≈ expected atol=1e-14
                @test p(x) ≈ expected atol=1e-14

                _x = copy(x)
                Transforms.apply!(_x, p)
                @test _x ≈ expected atol=1e-14

                @testset "inds" begin
                    @test Transforms.apply(x, p; inds=2:5) ≈ expected[2:5] atol=1e-14
                    @test Transforms.apply(x, p; dims=:) ≈ expected atol=1e-14
                    @test Transforms.apply(x, p; dims=1) ≈ expected atol=1e-14
                    @test Transforms.apply(x, p; dims=1, inds=[2, 3, 4, 5]) ≈ expected[2:5] atol=1e-14

                    @test_throws BoundsError Transforms.apply(x, p; dims=2)
                end
            end

            @testset "Matrix" begin
                x = collect(0.:5.)
                M = reshape(x, (3, 2))
                M_expected = reshape(expected, (3, 2))

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    @test Transforms.apply(M, p; dims=d) ≈ M_expected atol=1e-14
                    @test p(M; dims=d) ≈ M_expected atol=1e-14

                    _M = copy(M)
                    Transforms.apply!(_M, p; dims=d)
                    @test _M ≈ M_expected atol=1e-14
                end

                @testset "inds" begin
                    @test Transforms.apply(M, p; inds=[2, 3]) ≈ M_expected[[2, 3]] atol=1e-14
                    @test Transforms.apply(M, p; dims=:, inds=[2, 3]) ≈ M_expected[[2, 3]] atol=1e-14
                    @test Transforms.apply(M, p; dims=1, inds=[2]) ≈ reshape(M_expected[[2, 5]], 1, 2) atol=1e-14
                    @test Transforms.apply(M, p; dims=2, inds=[2]) ≈ reshape(M_expected[[4, 5, 6]], 3, 1) atol=1e-14
                end
            end

            @testset "AxisArray" begin
                x = collect(0.:5.)
                A = AxisArray(reshape(x, (3, 2)), foo=["a", "b", "c"], bar=["x", "y"])

                A_expected = AxisArray(
                    reshape(expected, (3, 2)),
                    foo=["a", "b", "c"],
                    bar=["x", "y"]
                )

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    transformed = Transforms.apply(A, p; dims=d)
                    # AxisArray doesn't preserve type when operations are performed on it
                    @test transformed isa AbstractArray
                    @test transformed ≈ A_expected atol=1e-14
                end

                _A = copy(A)
                Transforms.apply!(_A, p)
                @test _A isa AxisArray
                @test _A ≈ A_expected atol=1e-14

                @testset "inds" begin
                    @test Transforms.apply(A, p; inds=[2, 3]) ≈ A_expected[[2, 3]] atol=1e-14
                    @test Transforms.apply(A, p; dims=:, inds=[2, 3]) ≈ A_expected[[2, 3]] atol=1e-14
                    @test Transforms.apply(A, p; dims=1, inds=[2]) ≈ reshape(A_expected[[2, 5]], 1, 2) atol=1e-14
                    @test Transforms.apply(A, p; dims=2, inds=[2]) ≈ reshape(A_expected[[4, 5, 6]], 3, 1) atol=1e-14
                end
            end

            @testset "AxisKey" begin
                x = collect(0.:5.)
                A = KeyedArray(reshape(x, (3, 2)), foo=["a", "b", "c"], bar=["x", "y"])

                A_expected = KeyedArray(
                    reshape(expected, (3, 2)),
                    foo=["a", "b", "c"],
                    bar=["x", "y"]
                )

                @testset "dims = $d" for d in (Colon(), :foo, :bar)
                    transformed = Transforms.apply(A, p; dims=d)
                    @test transformed isa KeyedArray
                    @test transformed ≈ A_expected atol=1e-14
                end

                _A = copy(A)
                Transforms.apply!(_A, p)
                @test _A ≈ A_expected atol=1e-14

                @testset "inds" begin
                    @test Transforms.apply(A, p; inds=[2, 3]) ≈ [A_expected[2], A_expected[3]] atol=1e-14
                    @test Transforms.apply(A, p; dims=:, inds=[2, 3]) ≈ [A_expected[2], A_expected[3]] atol=1e-14
                    @test Transforms.apply(A, p; dims=1, inds=[2]) ≈ reshape([A_expected[2], A_expected[5]], 1, 2) atol=1e-14
                    @test Transforms.apply(A, p; dims=2, inds=[2]) ≈ reshape([A_expected[4], A_expected[5], A_expected[6]], 3, 1) atol=1e-14
                end
            end

            @testset "NamedTuple" begin
                nt = (a = collect(0.:2.), b = collect(3.:5.))
                nt_expected = (a = expected[1:3], b = expected[4:6])

                @testset "all cols" begin
                    transformed = Transforms.apply(nt, p)
                    @test transformed ≈ collect(nt_expected) atol=1e-14
                    @test p(nt) ≈ collect(nt_expected) atol=1e-14

                    _nt = deepcopy(nt)
                    Transforms.apply!(_nt, p)
                    @test _nt isa NamedTuple{(:a, :b)}
                    @test collect(_nt) ≈ collect(nt_expected) atol=1e-14
                end

                @testset "cols = $c" for c in (:a, :b)
                    nt_mutated = NamedTuple{(Symbol("$c"), )}((nt_expected[c], ))
                    nt_expected_ = merge(nt, nt_mutated)

                    transformed = Transforms.apply(nt, p; cols=[c])
                    @test transformed ≈ [collect(nt_expected_[c])] atol=1e-14
                    @test p(nt; cols=[c]) ≈ [collect(nt_expected_[c])] atol=1e-14

                    _nt = deepcopy(nt)
                    Transforms.apply!(_nt, p; cols=[c])
                    @test _nt isa NamedTuple{(:a, :b)}  # before applying `collect`
                    @test collect(_nt) ≈ collect(nt_expected_) atol=1e-14
                end
            end

            @testset "DataFrame" begin
                df = DataFrame(:a => collect(0.:2.), :b => collect(3.:5.))
                df_expected = DataFrame(:a => expected[1:3], :b => expected[4:6])

                @test Transforms.apply(df, p) ≈ [df_expected.a, df_expected.b] atol=1e-14

                @testset "cols = $c" for c in (:a, :b)
                    @test ≈(
                        Transforms.apply(df, p; cols=[c]),
                        [df_expected[!, c]],
                        atol=1e-14
                    )
                end

                _df = deepcopy(df)
                Transforms.apply!(_df, p)
                @test _df isa DataFrame
                @test _df ≈ df_expected atol=1e-14
            end
        end
    end

    @testset "TimeType input" begin
        @testset "Constructors" begin
            @testset "Default" begin
                p = Periodic(sin, Day(5), Day(2))
                @test p isa Transform
                @test p.period == Day(5)
                @test p.phase_shift == Day(2)
            end

            @testset "No phase_shift" begin
                p = Periodic(sin, Day(5))
                @test p isa Transform
                @test p.period == Day(5)
                @test p.phase_shift == Day(0)
            end
        end

        @testset "$f" for f in (sin, cos)
            p = Periodic(f, Day(5), Day(2))

            @testset "Vector" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                # Use _periodic to get expected outputs because we test it elsewhere
                expected = _periodic.(f, x, Day(5), Day(2))

                @test Transforms.apply(x, p) ≈ expected atol=1e-14
                @test p(x) ≈ expected atol=1e-14
            end

            @testset "Matrix" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                M = reshape(x, (3, 2))
                expected = _periodic.(f, x, Day(5), Day(2))
                expected = reshape(expected, (3, 2))

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    @test Transforms.apply(M, p; dims=d) ≈ expected atol=1e-14
                    @test p(M; dims=d) ≈ expected atol=1e-14
                end
            end

            @testset "AxisArray" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                A = AxisArray(
                    reshape(x, (3, 2)),
                    foo=["a", "b", "c"],
                    bar=["x", "y"]
                )

                expected = _periodic.(f, x, Day(5), Day(2))
                expected = AxisArray(
                    reshape(expected, (3, 2)),
                    foo=["a", "b", "c"],
                    bar=["x", "y"]
                )

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    transformed = Transforms.apply(A, p; dims=d)
                    # AxisArray doesn't preserve type when operations are performed on it
                    @test transformed isa AbstractArray
                    @test transformed ≈ expected atol=1e-14
                end
            end

            @testset "AxisKey" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                A = KeyedArray(
                    reshape(x, (3, 2)),
                    foo=["a", "b", "c"],
                    bar=["x", "y"]
                )

                expected = _periodic.(f, x, Day(5), Day(2))
                expected = KeyedArray(
                    reshape(expected, (3, 2)),
                    foo=["a", "b", "c"],
                    bar=["x", "y"]
                )

                @testset "dims = $d" for d in (Colon(), :foo, :bar)
                    transformed = Transforms.apply(A, p; dims=d)
                    @test transformed isa KeyedArray
                    @test transformed ≈ expected atol=1e-14
                end
            end

            @testset "NamedTuple" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                nt = (a = x[1:3], b = x[4:6])
                expected = [
                    _periodic.(f, x[1:3], Day(5), Day(2)),
                    _periodic.(f, x[4:6], Day(5), Day(2))
                ]

                @testset "all cols" begin
                    transformed = Transforms.apply(nt, p)
                    @test transformed ≈ expected atol=1e-14
                    @test p(nt) ≈ expected atol=1e-14
                end

                nt_expected = (a = expected[1], b = expected[2])
                @testset "cols = $c" for c in (:a, :b)
                    @test Transforms.apply(nt, p; cols=[c]) ≈ [nt_expected[c]] atol=1e-14
                    @test p(nt; cols=[c]) ≈ [nt_expected[c]] atol=1e-14
                end
            end

            @testset "DataFrame" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                df = DataFrame(:a => x[1:3], :b => x[4:6])
                expected = [
                    _periodic.(f, x[1:3], Day(5), Day(2)),
                    _periodic.(f, x[4:6], Day(5), Day(2))
                ]

                transformed = Transforms.apply(df, p)
                @test transformed ≈ expected atol=1e-14

                nt_expected = (a = expected[1], b = expected[2])
                @testset "cols = $c" for c in (:a, :b)
                    @test Transforms.apply(df, p; cols=[c]) ≈ [nt_expected[c]] atol=1e-14
                    @test p(df; cols=[c]) ≈ [nt_expected[c]] atol=1e-14
                end
            end
        end
    end

    @testset "Non-positive period" for period in (0, -1)
        @test_throws ArgumentError Periodic(sin, period, 1)
        @test_throws ArgumentError Periodic(sin, period)
    end

    @testset "Type mismatch" begin
        @testset "Real data, Period transform" begin
            p = Periodic(sin, Day(5), Day(2))
            x = 0.:11.
            @test_throws MethodError Transforms.apply(x, p)
        end

        @testset "TimeType data, Real transform" begin
            p = Periodic(sin, 5, 2)
            x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
            @test_throws MethodError Transforms.apply(x, p)
        end

        @test_throws MethodError Periodic(sin, 1, Day(3))
        @test_throws MethodError Periodic(sin, Day(1), 3)
    end
end
