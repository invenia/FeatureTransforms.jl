@testset "power" begin

    p = Power(3)
    @test p isa Transform

    # TODO: all of these should be part of some test utils
    @testset "Vector" begin
        x = [1, 2, 3, 4, 5]
        expected = [1, 8, 27, 64, 125]

        @test transform(x, p) == expected
        @test p(x) == expected

        _x = copy(x)
        transform!(_x, p)
        @test _x == expected
    end

    @testset "Matrix" begin
        M = [1 2 3; 4 5 6]
        expected = [1 8 27; 64 125 216]

        @testset "dims = $d" for d in (Colon(), 1, 2)
            @test transform(M, p; dims=d) == expected
            @test p(M; dims=d) == expected

            _M = copy(M)
            transform!(_M, p; dims=d)
            @test _M == expected
        end
    end

    @testset "NamedTuple" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = (a = [1, 8, 27], b = [64, 125, 216])

        @testset "all cols" begin
            @test transform(nt, p) == expected
            @test p(nt) == expected

            _nt = deepcopy(nt)
            transform!(_nt, p)
            @test _nt == expected
        end

        @testset "cols = $c" for c in (:a, :b)
            nt_mutated = NamedTuple{(Symbol("$c"), )}((expected[c], ))
            nt_expected = merge(nt, nt_mutated)

            @test transform(nt, p; cols=[c]) == nt_expected
            @test p(nt; cols=[c]) == nt_expected

            _nt = deepcopy(nt)
            transform!(_nt, p; cols=[c])
            @test _nt == nt_expected
        end
    end

    @testset "AxisArray" begin
        A = AxisArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
        expected = AxisArray([1 8 27; 64 125 216], foo=["a", "b"], bar=["x", "y", "z"])

        @testset "dims = $d" for d in (Colon(), 1, 2)
            @test transform(A, p; dims=d) == expected
        end

    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
        expected = AxisArray([1 8 27; 64 125 216], foo=["a", "b"], bar=["x", "y", "z"])

        @testset "dims = $d" for d in (Colon(), :foo, :bar)
            @test transform(A, p; dims=d) == expected
        end

        _A = copy(A)
        transform!(_A, p)
        @test _A == expected
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
        expected = DataFrame(:a => [1, 8, 27], :b => [64, 125, 216])

        @test transform(df, p) == expected
        @test transform(df, p; cols=[:a]) == DataFrame(:a => [1, 8, 27], :b => [4, 5, 6])
        @test transform(df, p; cols=[:b]) == DataFrame(:a => [1, 2, 3], :b => [64, 125, 216])

        _df = deepcopy(df)
        transform!(_df, p)
        @test _df == expected
    end

end
