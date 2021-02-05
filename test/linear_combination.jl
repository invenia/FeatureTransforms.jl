@testset "linear combination" begin

    lc = LinearCombination([1, -1])
    @test lc isa Transform

    @testset "Vector" begin
        x = [1, 2]
        expected = [-1]

        @testset "all inds" begin
            @test Transforms.apply(x, lc) == expected
            @test lc(x) == expected
        end

        @testset "dims not supported" begin
            @test_throws  MethodError Transforms.apply(x, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            x = [1, 2, 3]
            @test_throws DimensionMismatch Transforms.apply(x, lc)
        end

        @testset "specified inds" begin
            x = [1, 2, 3]
            inds = [2, 3]
            expected = [-1]

            @test Transforms.apply(x, lc; inds=inds) == expected
            @test lc(x; inds=inds) == expected
        end
    end

    @testset "Matrix" begin
        M = [1 1; 2 2; 3 5]
        expected = [0, 0, -2]

        @testset "all inds" begin
            @test Transforms.apply(M, lc) == expected
            @test lc(M) == expected
        end

        # TODO: Colon() is not supported by eachslice(A, dims=:), do we care?
        @testset "dims" begin
            @testset "dims = 1" begin
                @test Transforms.apply(M, lc; dims=1) == expected
                @test lc(M; dims=1) == expected
            end

            @testset "dims = 2" begin
                # There are 3 rows so trying to apply along dim 2 without specifying inds
                # won't work
                @test_throws DimensionMismatch Transforms.apply(M, lc; dims=2)

                @test Transforms.apply(M, lc; dims=2, inds=[2, 3]) == [-1, -3]
                @test lc(M; dims=2, inds=[1, 3]) == [-2, -4]
            end
        end

        @testset "dimension mismatch" begin
            M = [1 1 1; 2 2 2]
            @test_throws DimensionMismatch Transforms.apply(M, lc)
        end

        @testset "specified inds" begin
            M = [1 1 5; 2 2 4]
            inds = [2, 3]
            expected = [-4, -2]

            @test Transforms.apply(M, lc; inds=inds) == expected
            @test lc(M; inds=inds) == expected
        end
    end

    @testset "AxisArray" begin
        A = AxisArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        expected = [-1, -1]

        @testset "all inds" begin
            @test Transforms.apply(A, lc) == expected
            @test lc(A) == expected
        end

        @testset "dims" begin
            @testset "dims = 1" begin
                @test Transforms.apply(A, lc; dims=1) == expected
                @test lc(A; dims=1) == expected
            end

            @testset "dims = 2" begin
                @test Transforms.apply(A, lc; dims=2) == [-3, -3]
                @test lc(A; dims=2) == [-3, -3]
            end
        end

        @testset "dimension mismatch" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch Transforms.apply(A, lc)
        end

        @testset "specified inds" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            inds = [1, 2]
            expected = [-1, -1]

            @test Transforms.apply(A, lc; inds=inds) == expected
            @test lc(A; inds=inds) == expected
        end
    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        expected = [-1, -1]

        @testset "all inds" begin
            @test Transforms.apply(A, lc) == expected
            @test lc(A) == expected
        end

        @testset "dims" begin
            @testset "dims = 1" begin
                @test Transforms.apply(A, lc; dims=1) == expected
                @test lc(A; dims=1) == expected
            end

            @testset "dims = 2" begin
                @test Transforms.apply(A, lc; dims=2) == [-3, -3]
                @test lc(A; dims=2) == [-3, -3]
            end
        end

        @testset "dimension mismatch" begin
            A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch Transforms.apply(A, lc)
        end

        @testset "specified inds" begin
            A = KeyedArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            inds = [1, 2]
            expected = [-1, -1]

            @test Transforms.apply(A, lc; inds=inds) == expected
            @test lc(A; inds=inds) == expected
        end
    end

    @testset "NamedTuple" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = [-3, -3, -3]

        @testset "all cols" begin
            @test Transforms.apply(nt, lc) == expected
            @test lc(nt) == expected
        end

        @testset "dims not supported" begin
            @test_throws MethodError Transforms.apply(nt, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            @test_throws DimensionMismatch Transforms.apply(nt, lc)
        end

        @testset "specified cols" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            inds = [:a, :b]
            expected = [-3, -3, -3]

            @test Transforms.apply(nt, lc; inds=inds) == expected
            @test lc(nt; inds=inds) == expected
        end
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
        expected = [-3, -3, -3]

        @testset "all cols" begin
            @test Transforms.apply(df, lc) == expected
            @test lc(df) == expected
        end

        @testset "dims not supported" begin
            @test_throws MethodError Transforms.apply(df, lc; dims=1)
        end

        @testset "dimension mismatch" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            @test_throws DimensionMismatch Transforms.apply(df, lc)
        end

        @testset "specified cols" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            inds = [:b, :c]
            expected = [3, 4, 5]

            @test Transforms.apply(df, lc; inds=inds) == expected
            @test lc(df; inds=inds) == expected
        end
    end
end
