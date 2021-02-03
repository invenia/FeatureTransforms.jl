@testset "periodic" begin
    # Constructors
    @test Periodic(sin, 5) == Periodic(sin, 5, 0)

    @testset "_periodic" begin
        @testset "$f" for f in (sin, cos)
            # A typical 24-hour day
            for h in 0:24
                result = _periodic(
                    f,
                    ZonedDateTime(2015, 6, 1, tz"America/Winnipeg") + Hour(h),
                    Day(1),
                )
                expected = f(2π / 24 * h)
                @test result ≈ expected atol=1e-15
            end

            # A spring daylight-saving time change where the day has 23-hours
            for h in 0:23
                result = _periodic(
                    f,
                    ZonedDateTime(2015, 3, 8, tz"America/Winnipeg") + Hour(h),
                    Day(1),
                )
                expected = f(2π / 23 * h)
                @test result ≈ expected atol=1e-15
            end

            # A fall daylight-saving time change where the day has 25-hours
            for h in 0:25
                result = _periodic(
                    f,
                    ZonedDateTime(2015, 11, 1, tz"America/Winnipeg") + Hour(h),
                    Day(1),
                )
                expected = f(2π / 25 * h)
                @test result ≈ expected atol=1e-15
            end
        end

        @testset "negative period" begin
            @test ==(
                _periodic(sin, DateTime(2000, 1, 1, 3), Day(-1)),
                -_periodic(sin, DateTime(2000, 1, 1, 3), Day(1)),
            )

            @test ==(
                _periodic(cos, DateTime(2000, 1, 1, 3), Day(-1)),
                _periodic(cos, DateTime(2000, 1, 1, 3), Day(1)),
            )
        end

        @testset "phase shift" begin
            @test _periodic(sin, DateTime(1), Week(1)) == 0
            @test _periodic(sin, DateTime(1), Week(1), Day(7)) == 0
            @test _periodic(sin, DateTime(1), Week(1), Day(-7)) == 0

            # Using the phase shift we can make a Thursday the beginning of the week.
            # Note: that these calculations can change depending on the period type given.
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
        @testset "$f" for f in (sin, cos)
            p = Periodic(f, 5, 2)

            @test p isa Transform

            @testset "Vector" begin
                x = collect(0.:11.)
                expected = f.(2π .* (x .- 2) ./ 5)

                @test Transforms.apply(x, p) ≈ expected atol=1e-15
                @test p(x) ≈ expected atol=1e-15

                _x = copy(x)
                Transforms.apply!(_x, p)
                @test _x ≈ expected atol=1e-15
            end

            @testset "Matrix" begin
                x = collect(0.:11.)
                M = reshape(x, (6, 2))
                expected = f.(2π .* (x .- 2) ./ 5)
                expected = reshape(expected, (6, 2))

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    @test Transforms.apply(M, p; dims=d) ≈ expected atol=1e-15
                    @test p(M; dims=d) ≈ expected atol=1e-15

                    _M = copy(M)
                    Transforms.apply!(_M, p; dims=d)
                    @test _M ≈ expected atol=1e-15
                end
            end

            @testset "AxisArray" begin
                x = collect(0.:11.)
                A = AxisArray(
                    reshape(x, (6, 2)),
                    foo=["a", "b", "c", "d", "e", "f"],
                    bar=["x", "y"]
                )

                expected = f.(2π .* (x .- 2) ./ 5)
                expected = AxisArray(
                    reshape(expected, (6, 2)),
                    foo=["a", "b", "c", "d", "e", "f"],
                    bar=["x", "y"]
                )

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    transformed = Transforms.apply(A, p; dims=d)
                    @test transformed isa AxisArray
                    @test transformed ≈ expected atol=1e-15
                end
            end

            @testset "AxisKey" begin
                x = collect(0.:11.)
                A = KeyedArray(
                    reshape(x, (6, 2)),
                    foo=["a", "b", "c", "d", "e", "f"],
                    bar=["x", "y"]
                )

                expected = f.(2π .* (x .- 2) ./ 5)
                expected = KeyedArray(
                    reshape(expected, (6, 2)),
                    foo=["a", "b", "c", "d", "e", "f"],
                    bar=["x", "y"]
                )

                @testset "dims = $d" for d in (Colon(), :foo, :bar)
                    transformed = Transforms.apply(A, p; dims=d)
                    @test transformed isa KeyedArray
                    @test transformed ≈ expected atol=1e-15
                end

                _A = copy(A)
                Transforms.apply!(_A, p)
                @test _A ≈ expected atol=1e-15
            end

            @testset "NamedTuple" begin
                nt = (a = collect(0.:5.), b = collect(6.:11.))
                expected = (a = f.(2π .* (nt.a .- 2) ./ 5), b = f.(2π .* (nt.b .- 2) ./ 5))

                @testset "all cols" begin
                    transformed = Transforms.apply(nt, p)
                    @test transformed isa NamedTuple{(:a, :b)}
                    @test transformed == expected
                    @test p(nt) == expected

                    _nt = deepcopy(nt)
                    Transforms.apply!(_nt, p)
                    @test _nt == expected
                end

                @testset "cols = $c" for c in (:a, :b)
                    nt_mutated = NamedTuple{(Symbol("$c"), )}((expected[c], ))
                    nt_expected = merge(nt, nt_mutated)

                    @test Transforms.apply(nt, p; cols=[c]) == nt_expected
                    @test p(nt; cols=[c]) == nt_expected

                    _nt = deepcopy(nt)
                    Transforms.apply!(_nt, p; cols=[c])
                    @test _nt == nt_expected
                end
            end

            @testset "DataFrame" begin
                df = DataFrame(:a => collect(0.:5.), :b => collect(6.:11.))
                expected = DataFrame(
                    :a => f.(2π .* (df.a .- 2) ./ 5),
                    :b => f.(2π .* (df.b .- 2) ./ 5)
                )

                transformed = Transforms.apply(df, p)
                @test transformed isa DataFrame
                @test transformed == expected

                @test Transforms.apply(df, p; cols=[:a]) == DataFrame(
                    :a => f.(2π .* (df.a .- 2) ./ 5),
                    :b => collect(6.:11.)
                )
                @test Transforms.apply(df, p; cols=[:b]) == DataFrame(
                    :a => collect(0.:5.),
                    :b => f.(2π .* (df.b .- 2) ./ 5)
                )

                _df = deepcopy(df)
                Transforms.apply!(_df, p)
                @test _df == expected
            end
        end
    end

    @testset "TimeType input" begin
        @testset "$f" for f in (sin, cos)
            p = Periodic(f, Day(5), Day(2))

            @test p isa Transform

            @testset "Vector" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                expected = _periodic.(f, x, Day(5), Day(2))

                @test Transforms.apply(x, p) ≈ expected atol=1e-15
                @test p(x) ≈ expected atol=1e-15
            end

            @testset "Matrix" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                M = reshape(x, (3, 2))
                expected = _periodic.(f, x, Day(5), Day(2))
                expected = reshape(expected, (3, 2))

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    @test Transforms.apply(M, p; dims=d) ≈ expected atol=1e-15
                    @test p(M; dims=d) ≈ expected atol=1e-15
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
                    @test transformed isa AxisArray
                    @test transformed ≈ expected atol=1e-15
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

                @testset "dims = $d" for d in (Colon(), 1, 2)
                    transformed = Transforms.apply(A, p; dims=d)
                    @test transformed isa KeyedArray
                    @test transformed ≈ expected atol=1e-15
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
                    @test transformed == expected
                    @test p(nt) == expected
                end

                nt_expected = (a = expected[1], b = expected[2])
                @testset "cols = $c" for c in (:a, :b)
                    @test Transforms.apply(nt, p; cols=[c]) == [nt_expected[c]]
                    @test p(nt; cols=[c]) == [nt_expected[c]]
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
                @test transformed == expected

                nt_expected = (a = expected[1], b = expected[2])
                @testset "cols = $c" for c in (:a, :b)
                    @test Transforms.apply(df, p; cols=[c]) == [nt_expected[c]]
                    @test p(df; cols=[c]) == [nt_expected[c]]
                end
            end
        end
    end

    @testset "Type mismatch" begin
        p = Periodic(sin, Day(5), Day(2))
        x = 0.:11.
        @test_throws ArgumentError Transforms.apply(x, p)
    end
end
