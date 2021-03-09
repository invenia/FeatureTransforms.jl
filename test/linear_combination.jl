@testset "linear combination" begin

    @test LinearCombination([1, -1]) isa Transform

    @testset "Vector" begin

        @testset "all inds" begin
            x = [1, 2]
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(x, lc) == fill(-1)
            @test lc(x) == fill(-1)
        end

        @testset "dims behaviour" begin
            x = [1, 2]
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(x, lc; dims=1) == fill(-1)
            @test_throws DimensionMismatch FeatureTransforms.apply(x, lc; dims=2)
        end

        @testset "dimension mismatch" begin
            x = [1, 2, 3]
            lc = LinearCombination([1, -1])
            @test_throws DimensionMismatch FeatureTransforms.apply(x, lc)
        end

        @testset "specified inds" begin
            x = [1, 2, 3]
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(x, lc; inds=[2, 3]) == fill(-1)
            @test lc(x; inds=[2, 3]) == fill(-1)
        end
    end

    @testset "Matrix" begin

        @testset "default reduces over columns" begin
            M = [1 1; 2 2; 3 5]
            lc = LinearCombination([1, -1, 1])
            @test FeatureTransforms.apply(M, lc) == [2, 4]
            @test lc(M) == [2, 4]
        end

        @testset "dims" begin
            @testset "dims = :" begin
                M = [1 1; 2 2; 3 5]
                lc = LinearCombination([1, -1, 1])
                @test_throws ArgumentError FeatureTransforms.apply(M, lc; dims=:)
            end

            @testset "dims = 1" begin
                M = [1 1; 2 2; 3 5]
                lc = LinearCombination([1, -1, 1])
                @test FeatureTransforms.apply(M, lc; dims=1) == [2, 4]
                @test lc(M; dims=1) == [2, 4]
            end

            @testset "dims = 2" begin
                M = [1 1; 2 2; 3 5]
                lc = LinearCombination([1, -1])
                @test FeatureTransforms.apply(M, lc; dims=2) == [0, 0, -2]
            end
        end

        @testset "dimension mismatch" begin
            M = [1 1 1; 2 2 2]
            lc = LinearCombination([1, -1, 1])  # there are only 2 rows
            @test_throws DimensionMismatch FeatureTransforms.apply(M, lc)
        end

        @testset "specified inds" begin
            M = [1 1; 5 2; 2 4]
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(M, lc; inds=[2, 3]) == [3, -2]
            @test lc(M; inds=[2, 3]) == [3, -2]
        end
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
                @test_throws ArgumentError FeatureTransforms.apply(A, lc; dims=:)
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
                @test_throws ArgumentError FeatureTransforms.apply(A, lc; dims=:)
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
            A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch FeatureTransforms.apply(A, lc; dims=2)
        end

        @testset "specified inds" begin
            A = KeyedArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            @test FeatureTransforms.apply(A, lc; inds=[1, 2]) == [-3, -3, -2]
            @test lc(A; inds=[1, 2]) == [-3, -3, -2]
        end
    end

    @testset "NamedTuple" begin
        @testset "all cols" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6])
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(nt, lc) == [-3, -3, -3]
            @test lc(nt) == [-3, -3, -3]
        end

        @testset "dims not supported" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6])
            lc = LinearCombination([1, -1])
            @test_throws MethodError FeatureTransforms.apply(nt, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            lc = LinearCombination([1, -1])
            @test_throws DimensionMismatch FeatureTransforms.apply(nt, lc)
        end

        @testset "specified cols" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(nt, lc; cols=[:a, :b]) == [-3, -3, -3]
            @test lc(nt; cols=[:a, :b]) == [-3, -3, -3]
        end

        @testset "single col" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6])
            lc_single = LinearCombination([-1])
            @test FeatureTransforms.apply(nt, lc_single; cols=:a) == [-1, -2, -3]
            @test FeatureTransforms.apply(nt, lc_single; cols=[:a]) == [-1, -2, -3]
            @test lc_single(nt; cols=:a) == [-1, -2, -3]
        end
    end

    @testset "DataFrame" begin

        @testset "all cols" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(df, lc) == [-3, -3, -3]
            @test lc(df) == [-3, -3, -3]
        end

        @testset "dims not supported" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
            lc = LinearCombination([1, -1])
            @test_throws MethodError FeatureTransforms.apply(df, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            lc = LinearCombination([1, -1])
            @test_throws DimensionMismatch FeatureTransforms.apply(df, lc)
        end

        @testset "specified cols" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            lc = LinearCombination([1, -1])
            @test FeatureTransforms.apply(df, lc; cols=[:b, :c]) == [3, 4, 5]
            @test lc(df; cols=[:b, :c]) == [3, 4, 5]
        end

        @testset "single col" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
            lc_single = LinearCombination([-1])
            @test FeatureTransforms.apply(df, lc_single; cols=:a) == [-1, -2, -3]
            @test FeatureTransforms.apply(df, lc_single; cols=[:a]) == [-1, -2, -3]
            @test lc_single(df; cols=:a) == [-1, -2, -3]
        end
    end
end
