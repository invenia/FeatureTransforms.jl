@testset "temporal" begin

    hod = HoD()
    @test hod isa Transform
    @test cardinality(hod) == OneToOne()

    @testset "Basic" begin
        x = collect(DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0))
        # Expected result is an hour a day starting and ending on the 9th hour inclusive,
        # with 126 full days in the middle
        expected = [9:23..., repeat(0:23, 126)..., 0:9...]

        @test FeatureTransforms.apply(x, hod) == expected
        @test hod(x) == expected

        @testset "StepRange" begin
            x = DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0)
            @test FeatureTransforms.apply(x, hod) == expected
            @test hod(x) == expected
        end

        @testset "DST" begin
            x = ZonedDateTime(2020, 3, 7, 9, 0, tz"America/New_York"):Hour(1):ZonedDateTime(2020, 3, 8, 9, 0, tz"America/New_York")

            # expected result skips the DST transition hour of 2
            expected_dst = [9:23..., 0, 1, 3:9...]

            @test FeatureTransforms.apply(x, hod) == expected_dst
            @test hod(x) == expected_dst
        end
    end
end
