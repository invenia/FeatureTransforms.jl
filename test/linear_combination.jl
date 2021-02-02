@testset "linear combination" begin

    lc = LinearCombination([1, -1])
    @test lc isa Transform

    @testset "Vector" begin
        x = [1, 2]
        expected = [-1]

        @test Transforms.apply(x, lc) == expected
        @test lc(x) == expected

        @testset "dimension mismatch" begin
            x = [1, 2, 3]
            @test_throws DimensionMismatch Transforms.apply(x, lc)
        end

        @testset "specified cols" begin
            x = [1, 2, 3]
            cols = [2, 3]
            expected = [-1]

            @test Transforms.apply(x, lc; cols=cols) == expected
            @test lc(x; cols=cols) == expected
        end
    end

    @testset "Matrix" begin
        M = [1 1; 2 2; 3 5]
        expected = [0, 0, -2]

        @test Transforms.apply(M, lc) == expected
        @test lc(M) == expected

        # Does this just test dims is ignored?
        # @testset "dims = $d" for d in (Colon(), 1, 2)
        #     @test Transforms.apply(M, lc; dims=d) == expected
        #     @test lc(M; dims=d) == expected
        # end

        @testset "dimension mismatch" begin
            M = [1 1 1; 2 2 2]
            @test_throws DimensionMismatch Transforms.apply(M, lc)
        end

        @testset "specified cols" begin
            M = [1 1 5; 2 2 4]
            cols = [2, 3]
            expected = [-4, -2]

            @test Transforms.apply(M, lc; cols=cols) == expected
            @test lc(M; cols=cols) == expected
        end
    end

    @testset "NamedTuple" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = [-3, -3, -3]

        @testset "all cols" begin
            transformed = Transforms.apply(nt, lc)
            @test transformed == expected
            @test lc(nt) == expected
        end

        @testset "dimension mismatch" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            @test_throws DimensionMismatch Transforms.apply(nt, lc)
        end

        @testset "specified cols" begin
            nt = (a = [1, 2, 3], b = [4, 5, 6], c = [1, 1, 1])
            cols = [:a, :b]
            expected = [-3, -3, -3]

            @test Transforms.apply(nt, lc; cols=cols) == expected
            @test lc(nt; cols=cols) == expected
        end
    end

    @testset "AxisArray" begin
        A = AxisArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        expected = [-1, -1]

        # @testset "dims = $d" for d in (Colon(), 1, 2)
        #     transformed = Transforms.apply(A, lc; dims=d)
        #     @test transformed == expected
        # end

        @testset "dimension mismatch" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch Transforms.apply(A, lc)
        end

        @testset "specified cols" begin
            A = AxisArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            cols = [1, 2]
            expected = [-1, -1]

            @test Transforms.apply(A, lc; cols=cols) == expected
            @test lc(A; cols=cols) == expected
        end
    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2; 4 5], foo=["a", "b"], bar=["x", "y"])
        expected = [-1, -1]

        # @testset "dims = $d" for d in (Colon(), :foo, :bar)
        #     transformed = Transforms.apply(A, lc; dims=d)
        #     @test transformed == expected
        # end

        @testset "dimension mismatch" begin
            A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
            @test_throws DimensionMismatch Transforms.apply(A, lc)
        end

        @testset "specified cols" begin
            A = KeyedArray([1 2 3; 4 5 5], foo=["a", "b"], bar=["x", "y", "z"])
            cols = [1, 2]
            expected = [-1, -1]

            @test Transforms.apply(A, lc; cols=cols) == expected
            @test lc(A; cols=cols) == expected
        end
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
        expected = [-3, -3, -3]

        transformed = Transforms.apply(df, lc)
        @test transformed == expected

        @testset "dimension mismatch" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            @test_throws DimensionMismatch Transforms.apply(df, lc)
        end

        @testset "specified cols" begin
            df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [1, 1, 1])
            cols = [:b, :c]
            expected = [3, 4, 5]

            @test Transforms.apply(df, lc; cols=cols) == expected
            @test lc(df; cols=cols) == expected
        end
    end
end
