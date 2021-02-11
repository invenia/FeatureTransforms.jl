@testset "temporal" begin

    hod = HoD()
    @test hod isa Transform

    @testset "Vector" begin
        x = collect(DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0))
        # Expected result is an hour a day starting and ending on the 9th hour inclusive,
        # with 126 full days in the middle
        expected = [9:23..., repeat(0:23, 126)..., 0:9...]

        @test Transforms.apply(x, hod) == expected
        @test hod(x) == expected

        # Test the tranform was not mutating
        @test x != expected

        @testset "StepRange" begin
            x = DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0)
            @test Transforms.apply(x, hod) == expected
            @test hod(x) == expected
        end

        @testset "dims = $d" for d in (Colon(), 1)
            @test Transforms.apply(x, hod; dims=d) == expected
            @test hod(x; dims=d) == expected
        end

        @test_throws BoundsError Transforms.apply(x, hod; dims=2)

        @testset "inds" begin
            @test Transforms.apply(x, hod; inds=2:5) == expected[2:5]
            @test Transforms.apply(x, hod; dims=:) == expected
            @test Transforms.apply(x, hod; dims=1) == expected
            @test Transforms.apply(x, hod; dims=1, inds=[2, 3, 4, 5]) == expected[2:5]
        end

        @testset "DST" begin
            x = ZonedDateTime(2020, 3, 7, 9, 0, tz"America/New_York"):Hour(1):ZonedDateTime(2020, 3, 8, 9, 0, tz"America/New_York")

            # expected result skips the DST transition hour of 2
            expected_dst = [9:23..., 0, 1, 3:9...]

            @test Transforms.apply(x, hod) == expected_dst
            @test hod(x) == expected_dst
        end
    end

    @testset "Matrix" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 3, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 11, 0)
        ]
        M = reshape(x, 3, 2)
        expected = [1 9; 2 10; 3 11]

        @test Transforms.apply(M, hod) == expected
        @test hod(M) == expected

        # Test the tranform was not mutating
        @test M != expected

        @testset "dims = $d" for d in (Colon(), 1, 2)
            @test Transforms.apply(M, hod; dims=d) == expected
            @test hod(M; dims=d) == expected
        end

        @testset "inds" begin
            @test Transforms.apply(M, hod; inds=[2, 3]) == expected[[2, 3]]
            @test Transforms.apply(M, hod; dims=:, inds=[2, 3]) == expected[[2, 3]]
            @test Transforms.apply(M, hod; dims=1, inds=[2]) == reshape(expected[[2, 5]], 1, 2)
            @test Transforms.apply(M, hod; dims=2, inds=[2]) == reshape(expected[[4, 5, 6]], 3, 1)
        end
    end

    @testset "AxisArray" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 2, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 10, 0);
            DateTime(2020, 1, 1, 10, 0):Hour(1):DateTime(2020, 1, 1, 11, 0)
        ]
        M = reshape(x, 2, 3)
        A = AxisArray(M, foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 9 10; 2 10 11]

        @test Transforms.apply(A, hod) == expected
        @test hod(A) == expected

        @testset "dims = $d" for d in (Colon(), 1, 2)
            transformed = Transforms.apply(A, hod; dims=d)
            # AxisArray doesn't preserve the type it operates on
            @test transformed isa AbstractArray
            @test transformed == expected
        end

        @testset "inds" begin
            @test Transforms.apply(A, hod; inds=[2, 3]) == expected[[2, 3]]
            @test Transforms.apply(A, hod; dims=:, inds=[2, 3]) == expected[[2, 3]]
            @test Transforms.apply(A, hod; dims=1, inds=[2]) == reshape(expected[[2, 4, 6]], 1, 3)
            @test Transforms.apply(A, hod; dims=2, inds=[2]) == reshape(expected[[3, 5]], 2, 1)
        end
    end

    @testset "AxisKey" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 2, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 10, 0);
            DateTime(2020, 1, 1, 10, 0):Hour(1):DateTime(2020, 1, 1, 11, 0)
        ]
        M = reshape(x, 2, 3)
        A = KeyedArray(M, foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 9 10; 2 10 11]

        @test Transforms.apply(A, hod) == expected
        @test hod(A) == expected

        @testset "dims = $d" for d in (Colon(), 1, 2)
            transformed = Transforms.apply(A, hod; dims=d)
            @test transformed isa KeyedArray
            @test transformed == expected
        end

        @testset "inds" begin
            @test Transforms.apply(A, hod; inds=[2, 3]) == expected[[2, 3]]
            @test Transforms.apply(A, hod; dims=:, inds=[2, 3]) == expected[[2, 3]]
            @test Transforms.apply(A, hod; dims=1, inds=[2]) == reshape(expected[[2, 4, 6]], 1, 3)
            @test Transforms.apply(A, hod; dims=2, inds=[2]) == reshape(expected[[3, 5]], 2, 1)
        end
    end

    @testset "NamedTuple" begin
        nt = (
            a = DateTime(2020, 1, 1, 0, 0):Hour(1):DateTime(2020, 1, 1, 2, 0),
            b = DateTime(2020, 1, 1, 3, 0):Hour(1):DateTime(2020, 1, 1, 5, 0)
        )
        expected_nt = (a = [0, 1, 2], b = [3, 4, 5])
        expected = [[0, 1, 2], [3, 4, 5]]

        @testset "all cols" begin
            @test Transforms.apply(nt, hod) == expected
            @test hod(nt) == expected

            # Test the tranform was not mutating
            @test nt != expected
        end

        @testset "cols = $c" for c in (:a, :b)
            @test Transforms.apply(nt, hod; cols=[c]) == [expected_nt[c]]
            @test hod(nt; cols=[c]) == [expected_nt[c]]
        end
    end


    @testset "DataFrame" begin
        df = DataFrame(
            :a => DateTime(2020, 1, 1, 0, 0):Hour(1):DateTime(2020, 1, 1, 2, 0),
            :b => DateTime(2020, 1, 1, 3, 0):Hour(1):DateTime(2020, 1, 1, 5, 0)
        )
        expected_df = DataFrame(:a => [0, 1, 2], :b => [3, 4, 5])
        expected = [expected_df.a, expected_df.b]

        @testset "all cols" begin
            @test Transforms.apply(df, hod) == expected
            @test hod(df) == expected

            # Test the tranform was not mutating
            @test df != expected
        end

        @test Transforms.apply(df, hod; cols=[:a]) == [expected_df.a]
        @test Transforms.apply(df, hod; cols=[:b]) ==[expected_df.b]
    end
end
