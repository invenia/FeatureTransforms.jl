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

            @testset "Non-positive period" for period in (0, -1)
                @test_throws DomainError Periodic(sin, period, 1)
                @test_throws DomainError Periodic(sin, period)
            end

            @testset "Different field subtypes" begin
                p = Periodic(sin, 4.0, 2)
                x = [2.0, 3.0, 5.0]

                @test FeatureTransforms.apply(x, p) ≈ [0.0, 1.0, -1.0] atol=1e-14
                @test p(x) ≈ [0.0, 1.0, -1.0] atol=1e-14
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
                @test cardinality(p) == OneToOne()
            end

            @testset "No phase_shift" begin
                p = Periodic(sin, Day(5))
                @test p isa Transform
                @test p.period == Day(5)
                @test p.phase_shift == Day(0)
            end

            @testset "Non-positive period" for period in (Day(0), Day(-1))
                @test_throws DomainError Periodic(sin, period, Day(1))
                @test_throws DomainError Periodic(sin, period)
            end

            @testset "Different field subtypes" begin
                p = Periodic(sin, Week(1), Day(5))

                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                # Use _periodic to get expected outputs because we test it elsewhere
                expected = _periodic.(sin, x, Week(1), Day(5))

                @test FeatureTransforms.apply(x, p) ≈ expected atol=1e-14
                @test p(x) ≈ expected atol=1e-14
            end
        end

        @testset "$f" for f in (sin, cos)
            p = Periodic(f, Day(5), Day(2))

            @testset "Basic" begin
                x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
                # Use _periodic to get expected outputs because we test it elsewhere
                expected = _periodic.(f, x, Day(5), Day(2))

                @test FeatureTransforms.apply(x, p) ≈ expected atol=1e-14
                @test p(x) ≈ expected atol=1e-14
            end
        end
    end

    @testset "Type mismatch" begin
        @testset "Real data, Period transform" begin
            p = Periodic(sin, Day(5), Day(2))
            x = 0.:11.
            @test_throws MethodError FeatureTransforms.apply(x, p)
        end

        @testset "TimeType data, Real transform" begin
            p = Periodic(sin, 5, 2)
            x = ZonedDateTime(2020, 1, 1, tz"EST") .+ (Day(0):Day(1):Day(5))
            @test_throws MethodError FeatureTransforms.apply(x, p)
        end

        @test_throws ArgumentError Periodic(sin, 1, Day(3))
        @test_throws ArgumentError Periodic(sin, Day(1), 3)
    end
end
