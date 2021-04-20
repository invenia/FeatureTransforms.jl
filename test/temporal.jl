@testset "temporal" begin

    hod = HoD()
    @test hod isa Transform
    @test cardinality(hod) == OneToOne()

    @testset "Vector" begin
        x = collect(DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0))
        # Expected result is an hour a day starting and ending on the 9th hour inclusive,
        # with 126 full days in the middle
        expected = [9:23..., repeat(0:23, 126)..., 0:9...]

        @test FeatureTransforms.apply(x, hod) == expected
        @test hod(x) == expected

        # Test the tranform was not mutating
        @test x != expected

        @testset "StepRange" begin
            x = DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0)
            @test FeatureTransforms.apply(x, hod) == expected
            @test hod(x) == expected
        end

        @testset "dims = $d" for d in (Colon(), 1)
            @test FeatureTransforms.apply(x, hod; dims=d) == expected
            @test hod(x; dims=d) == expected
        end

        @test_throws BoundsError FeatureTransforms.apply(x, hod; dims=2)

        @testset "inds" begin
            @test FeatureTransforms.apply(x, hod; inds=2:5) == expected[2:5]
            @test FeatureTransforms.apply(x, hod; dims=:) == expected
            @test FeatureTransforms.apply(x, hod; dims=1) == expected
            @test FeatureTransforms.apply(x, hod; dims=1, inds=[2, 3, 4, 5]) == expected[2:5]
        end

        @testset "DST" begin
            x = ZonedDateTime(2020, 3, 7, 9, 0, tz"America/New_York"):Hour(1):ZonedDateTime(2020, 3, 8, 9, 0, tz"America/New_York")

            # expected result skips the DST transition hour of 2
            expected_dst = [9:23..., 0, 1, 3:9...]

            @test FeatureTransforms.apply(x, hod) == expected_dst
            @test hod(x) == expected_dst
        end

        @testset "apply_append" begin
            x = collect(DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0))
            expected = [9:23..., repeat(0:23, 126)..., 0:9...]
            @test FeatureTransforms.apply_append(x, hod, append_dim=1) == vcat(x, expected)
        end
    end

    @testset "Matrix" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 3, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 11, 0)
        ]
        M = reshape(x, 3, 2)
        expected = [1 9; 2 10; 3 11]

        @test FeatureTransforms.apply(M, hod) == expected
        @test hod(M) == expected

        # Test the tranform was not mutating
        @test M != expected

        @testset "dims = $d" for d in (Colon(), 1, 2)
            @test FeatureTransforms.apply(M, hod; dims=d) == expected
            @test hod(M; dims=d) == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(M, hod; inds=[2, 3]) == [2, 3]
            @test FeatureTransforms.apply(M, hod; dims=:, inds=[2, 3]) == [2, 3]
            @test FeatureTransforms.apply(M, hod; dims=1, inds=[2]) == [2 10]
            @test FeatureTransforms.apply(M, hod; dims=2, inds=[2]) == reshape([9; 10; 11], 3, 1)
        end

        @testset "apply_append" begin
            @test FeatureTransforms.apply_append(M, hod, append_dim=1) == vcat(M, expected)
            @test FeatureTransforms.apply_append(M, hod, append_dim=2) == hcat(M, expected)
            @test FeatureTransforms.apply_append(M, hod, append_dim=3) == cat(M, expected, dims=3)
        end
    end

    @testset "AxisArray" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 2, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 10, 0);
            DateTime(2020, 1, 1, 11, 0):Hour(1):DateTime(2020, 1, 1, 12, 0)
        ]
        M = reshape(x, 2, 3)
        A = AxisArray(M, foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 9 11; 2 10 12]

        @test FeatureTransforms.apply(A, hod) == expected
        @test hod(A) == expected

        @testset "dims = $d" for d in (Colon(), 1, 2)
            transformed = FeatureTransforms.apply(A, hod; dims=d)
            # AxisArray doesn't preserve the type it operates on
            @test transformed isa AbstractArray
            @test transformed == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(A, hod; inds=[2, 3]) == [2, 9]
            @test FeatureTransforms.apply(A, hod; dims=:, inds=[2, 3]) == [2, 9]
            @test FeatureTransforms.apply(A, hod; dims=1, inds=[2]) == [2 10 12]
            @test FeatureTransforms.apply(A, hod; dims=2, inds=[2]) == reshape([9, 10], 2, 1)
        end

        @testset "apply_append" begin
            @test FeatureTransforms.apply_append(A, hod, append_dim=1) == vcat(A, expected)
            @test FeatureTransforms.apply_append(A, hod, append_dim=2) == hcat(A, expected)
            @test FeatureTransforms.apply_append(A, hod, append_dim=3) == cat(M, expected, dims=3)
        end
    end

    @testset "AxisKey" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 2, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 10, 0);
            DateTime(2020, 1, 1, 11, 0):Hour(1):DateTime(2020, 1, 1, 12, 0)
        ]
        M = reshape(x, 2, 3)
        A = KeyedArray(M, foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 9 11; 2 10 12]

        @test FeatureTransforms.apply(A, hod) == expected
        @test hod(A) == expected

        @testset "dims = $d" for d in (Colon(), 1, 2, :foo, :bar)
            transformed = FeatureTransforms.apply(A, hod; dims=d)
            @test transformed isa KeyedArray
            @test transformed == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(A, hod; inds=[2, 3]) == [2, 9]
            @test FeatureTransforms.apply(A, hod; dims=:, inds=[2, 3]) == [2, 9]
            @test FeatureTransforms.apply(A, hod; dims=1, inds=[2]) == [2 10 12]
            @test FeatureTransforms.apply(A, hod; dims=2, inds=[2]) == reshape([9, 10], 2, 1)
            @test FeatureTransforms.apply(A, hod; dims=:foo, inds=[2]) == [2 10 12]
            @test FeatureTransforms.apply(A, hod; dims=:bar, inds=[2]) == reshape([9, 10], 2, 1)
        end

        @testset "apply_append" begin
            expected1 = KeyedArray(
                vcat(M, expected), foo=["a", "b", "a", "b"], bar=["x", "y", "z"]
            )
            @test FeatureTransforms.apply_append(A, hod, append_dim=:foo) == expected1

            expected2 = KeyedArray(
                hcat(M, expected), foo=["a", "b"], bar=["x", "y", "z", "x", "y", "z"]
            )
            @test FeatureTransforms.apply_append(A, hod, append_dim=:bar) == expected2

            expected3 = KeyedArray(
                cat(M, expected, dims=3), foo=["a", "b"], bar=["x", "y", "z"], baz=Base.OneTo(2)
            )
            @test FeatureTransforms.apply_append(A, hod, append_dim=:baz) == expected3
        end
    end
end
