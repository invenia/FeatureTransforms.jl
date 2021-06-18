@testset "linear combination" begin

    lc = LinearCombination([1, -1])
    @test lc isa Transform
    @test cardinality(lc) == ManyToOne()

    @testset "default reduces over columns" begin
        M = [1 1; 2 2; 3 5]
        lc = LinearCombination([1, -1, 1])
        @test FeatureTransforms.apply(M, lc) == [2, 4]
        @test lc(M) == [2, 4]
    end

    @testset "dims = :" begin
        M = [1 1; 2 2; 3 5]
        lc = LinearCombination([1, -1, 1])
        @test_deprecated FeatureTransforms.apply(M, lc; dims=:)
    end

    @testset "dimension mismatch" begin
        M = [1 1 1; 2 2 2]
        lc = LinearCombination([1, -1, 1])  # there are only 2 rows
        @test_throws DimensionMismatch FeatureTransforms.apply(M, lc)
    end

    @testset "N-dim Array" begin
        A = reshape(1:27, 3, 3, 3)
        lc = LinearCombination([1, -1, 1])
        @test FeatureTransforms.apply(A, lc) == [2 11 20; 5 14 23; 8 17 26]
        @test lc(A) == [2 11 20; 5 14 23; 8 17 26]
    end

    @testset "AxisArray" begin
        A = AxisArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        lc = LinearCombination([1, -1])

        @testset "all inds" begin
            @test FeatureTransforms.apply(A, lc) == [-3, -3]
            @test lc(A) == [-3, -3]
        end

        @testset "dims" begin
            @testset "dims = :" begin
                @test_deprecated FeatureTransforms.apply(A, lc; dims=:)
            end

            @testset "dims = 1" begin
                @test FeatureTransforms.apply(A, lc; dims=1) == [-3, -3]
                @test lc(A; dims=1) == [-3, -3]
            end

            @testset "dims = 2" begin
                @test FeatureTransforms.apply(A, lc; dims=2) == [-1, -1]
                @test lc(A; dims=2) == [-1, -1]
            end
        end

        @testset "dimension mismatch" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch FeatureTransforms.apply(A, lc; dims=2)
        end

        @testset "specified inds" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            @test FeatureTransforms.apply(A, lc; inds=[1, 2]) == [-3, -3, -2]
            @test lc(A; inds=[1, 2]) == [-3, -3, -2]
        end

        @testset "apply_append" begin
            A = AxisArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])

            expected1 = [1 2; 4 5; -3 -3]
            @test FeatureTransforms.apply_append(A, lc; dims=1, append_dim=1) == expected1

            expected2 = [1 2 -1; 4 5 -1]
            @test FeatureTransforms.apply_append(A, lc; dims=2, append_dim=2) == expected2
        end
    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        lc = LinearCombination([1, -1])

        @testset "all inds" begin
            @test FeatureTransforms.apply(A, lc) == [-3, -3]
            @test lc(A) == [-3, -3]
        end

        @testset "dims" begin
            @testset "dims = :" begin
                @test_deprecated FeatureTransforms.apply(A, lc; dims=:)
            end

            @testset "dims = 1" begin
                @test FeatureTransforms.apply(A, lc; dims=1) == [-3, -3]
                @test FeatureTransforms.apply(A, lc; dims=:foo) == [-3, -3]
                @test lc(A; dims=1) == [-3, -3]
            end

            @testset "dims = 2" begin
                @test FeatureTransforms.apply(A, lc; dims=2) == [-1, -1]
                @test FeatureTransforms.apply(A, lc; dims=:bar) == [-1, -1]
                @test lc(A; dims=2) == [-1, -1]
            end
        end

        @testset "dimension mismatch" begin
            A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch FeatureTransforms.apply(A, lc; dims=2)
        end

        @testset "specified inds" begin
            A = KeyedArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            @test FeatureTransforms.apply(A, lc; inds=[1, 2]) == [-3, -3, -2]
            @test lc(A; inds=[1, 2]) == [-3, -3, -2]
        end

        @testset "apply_append" begin
            A = KeyedArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])

            expected1 = [1 2; 4 5; -3 -3]
            @test FeatureTransforms.apply_append(A, lc; dims=:foo, append_dim=:foo) == expected1

            expected2 = [1 2 -1; 4 5 -1]
            @test FeatureTransforms.apply_append(A, lc; dims=:bar, append_dim=:bar) == expected2
        end
    end
end
