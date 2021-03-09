@testset "linear combination" begin

    lc = LinearCombination([1, -1])
    @test lc isa Transform

    @testset "Vector" begin
        x = [1, 2]
        expected = [-1]

        @testset "all inds" begin
            @test FeatureTransforms.apply(x, lc) == expected
            @test lc(x) == expected
        end

        @testset "dims not supported" begin
            @test_throws  MethodError FeatureTransforms.apply(x, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            x = [1, 2, 3]
            @test_throws DimensionMismatch FeatureTransforms.apply(x, lc)
        end

        @testset "specified inds" begin
            x = [1, 2, 3]
            inds = [2, 3]
            expected = [-1]

            @test FeatureTransforms.apply(x, lc; inds=inds) == expected
            @test lc(x; inds=inds) == expected
        end
    end

    @testset "Matrix" begin
        M = [1 1; 2 2; 3 5]

        @testset "default reduces over columns" begin
            lc = LinearCombination([1, -1, 1])
            @test FeatureTransforms.apply(M, lc) == [2, 4]
            @test lc(M) == [2, 4]
        end

        @testset "dims" begin
            @testset "dims = :" begin
                d = Colon()
                lc = LinearCombination([1, -1, 1])
                @test_throws ArgumentError FeatureTransforms.apply(M, lc; dims=d)
            end

            @testset "dims = 1" begin
                d = 1
                lc = LinearCombination([1, -1, 1])
                @test FeatureTransforms.apply(M, lc; dims=d) == [2, 4]
                @test lc(M; dims=d) == [2, 4]
            end

            @testset "dims = 2" begin
                d = 2
                lc = LinearCombination([1, -1])
                @test FeatureTransforms.apply(M, lc; dims=d) == [0, 0, -2]
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
            inds = [2, 3]

            @test FeatureTransforms.apply(M, lc; inds=inds) == [3, -2]
            @test lc(M; inds=inds) == [3, -2]
        end
    end

    @testset "AxisArray" begin
        A = AxisArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        expected = [-3, -3]

        @testset "all inds" begin
            @test FeatureTransforms.apply(A, lc) == expected
            @test lc(A) == expected
        end

        @testset "dims" begin
            @testset "dims = :" begin
                d = Colon()
                @test_throws ArgumentError FeatureTransforms.apply(A, lc; dims=d)
            end

            @testset "dims = 1" begin
                d = 1
                @test FeatureTransforms.apply(A, lc; dims=d) == expected
                @test lc(A; dims=d) == expected
            end

            @testset "dims = 2" begin
                d = 2
                @test FeatureTransforms.apply(A, lc; dims=d) == [-1, -1]
                @test lc(A; dims=d) == [-1, -1]
            end
        end

        @testset "dimension mismatch" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch FeatureTransforms.apply(A, lc; dims=2)
        end

        @testset "specified inds" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            inds = [1, 2]
            expected = [-3, -3, -2]

            @test FeatureTransforms.apply(A, lc; inds=inds) == expected
            @test lc(A; inds=inds) == expected
        end
    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        expected = [-3, -3]

        @testset "all inds" begin
            @test FeatureTransforms.apply(A, lc) == expected
            @test lc(A) == expected
        end

        @testset "dims" begin
            @testset "dims = :" begin
                d = Colon()
                @test_throws ArgumentError FeatureTransforms.apply(A, lc; dims=d)
            end

            @testset "dims = 1" begin
                d = 1
                @test FeatureTransforms.apply(A, lc; dims=d) == expected
                @test lc(A; dims=d) == expected
            end

            @testset "dims = 2" begin
                d = 2
                @test FeatureTransforms.apply(A, lc; dims=d) == [-1, -1]
                @test lc(A; dims=d) == [-1, -1]
            end
        end

        @testset "dimension mismatch" begin
            A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch FeatureTransforms.apply(A, lc; dims=2)
        end

        @testset "specified inds" begin
            A = KeyedArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            inds = [1, 2]
            expected = [-3, -3, -2]

            @test FeatureTransforms.apply(A, lc; inds=inds) == expected
            @test lc(A; inds=inds) == expected
        end
    end

    @testset "NamedTuple" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = [-3, -3, -3]

        @testset "all cols" begin
            @test FeatureTransforms.apply(nt, lc) == expected
            @test lc(nt) == expected
        end

        @testset "dims not supported" begin
            @test_throws MethodError FeatureTransforms.apply(nt, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            @test_throws DimensionMismatch FeatureTransforms.apply(nt, lc)
        end

        @testset "specified cols" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            cols = [:a, :b]
            expected = [-3, -3, -3]

            @test FeatureTransforms.apply(nt, lc; cols=cols) == expected
            @test lc(nt; cols=cols) == expected
        end

        @testset "single col" begin
            lc_single = LinearCombination([-1])

            @test FeatureTransforms.apply(nt, lc_single; cols=:a) == [-1, -2, -3]
            @test FeatureTransforms.apply(nt, lc_single; cols=[:a]) == [-1, -2, -3]
            @test lc_single(nt; cols=:a) == [-1, -2, -3]
        end
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
        expected = [-3, -3, -3]

        @testset "all cols" begin
            @test FeatureTransforms.apply(df, lc) == expected
            @test lc(df) == expected
        end

        @testset "dims not supported" begin
            @test_throws MethodError FeatureTransforms.apply(df, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            @test_throws DimensionMismatch FeatureTransforms.apply(df, lc)
        end

        @testset "specified cols" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            cols = [:b, :c]
            expected = [3, 4, 5]

            @test FeatureTransforms.apply(df, lc; cols=cols) == expected
            @test lc(df; cols=cols) == expected
        end

        @testset "single col" begin
            lc_single = LinearCombination([-1])

            @test FeatureTransforms.apply(df, lc_single; cols=:a) == [-1, -2, -3]
            @test FeatureTransforms.apply(df, lc_single; cols=[:a]) == [-1, -2, -3]
            @test lc_single(df; cols=:a) == [-1, -2, -3]
        end
    end
end
