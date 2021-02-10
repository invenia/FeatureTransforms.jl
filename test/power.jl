@testset "power" begin

    p = Power(3)
    @test p isa Transform

    # TODO: all of these should be part of some test utils
    @testset "Vector" begin
        x = [1, 2, 3, 4, 5]
        expected = [1, 8, 27, 64, 125]

        @test Transforms.apply(x, p) == expected
        @test p(x) == expected

        _x = copy(x)
        Transforms.apply!(_x, p)
        @test _x == expected
    end

    @testset "Matrix" begin
        M = [1 2 3; 4 5 6]
        expected = [1 8 27; 64 125 216]

        @testset "dims = $d" for d in (Colon(), 1, 2)
            @test Transforms.apply(M, p; dims=d) == expected
            @test p(M; dims=d) == expected

            _M = copy(M)
            Transforms.apply!(_M, p; dims=d)
            @test _M == expected
        end
    end

    @testset "AxisArray" begin
        A = AxisArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 8 27; 64 125 216]

        @testset "dims = $d" for d in (Colon(), 1, 2)
            transformed = Transforms.apply(A, p; dims=d)
            # AxisArray doesn't preserve the type it operates on
            @test transformed isa AbstractArray
            @test transformed == expected
        end

        _A = copy(A)
        Transforms.apply!(_A, p)
        @test _A isa AxisArray
        @test _A == expected
    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
        expected = KeyedArray([1 8 27; 64 125 216], foo=["a", "b"], bar=["x", "y", "z"])

        @testset "dims = $d" for d in (Colon(), :foo, :bar)
            transformed = Transforms.apply(A, p; dims=d)
            @test transformed isa KeyedArray
            @test transformed == expected
        end

        _A = copy(A)
        Transforms.apply!(_A, p)
        @test _A isa KeyedArray
        @test _A == expected
    end

    @testset "NamedTuple" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = [[1, 8, 27], [64, 125, 216]]
        expected_nt = (a = [1, 8, 27], b = [64, 125, 216])

        @testset "all cols" begin
            @test Transforms.apply(nt, p) == expected
            @test p(nt) == expected

            _nt = deepcopy(nt)
            Transforms.apply!(_nt, p)
            @test _nt isa NamedTuple{(:a, :b)}
            @test _nt == expected_nt
        end

        @testset "cols = $c" for c in (:a, :b)
            nt_mutated = NamedTuple{(Symbol("$c"), )}((expected_nt[c], ))
            expected_nt_mutated = merge(nt, nt_mutated)

            @test Transforms.apply(nt, p; cols=[c]) == [expected_nt[c]]
            @test p(nt; cols=[c]) == [expected_nt[c]]

            _nt = deepcopy(nt)
            Transforms.apply!(_nt, p; cols=[c])
            @test _nt == expected_nt_mutated
            @test _nt isa NamedTuple
        end
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
        expected_df = DataFrame(:a => [1, 8, 27], :b => [64, 125, 216])
        expected = [expected_df.a, expected_df.b]

        @test Transforms.apply(df, p) == expected

        @test Transforms.apply(df, p; cols=[:a]) == [expected_df.a]
        @test Transforms.apply(df, p; cols=[:b]) ==[expected_df.b]

        _df = deepcopy(df)
        Transforms.apply!(_df, p)
        @test _df isa DataFrame
        @test _df == expected_df
    end
end
