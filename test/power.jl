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
        axisarray_expected = AxisArray([1 8 27; 64 125 216], foo=["a", "b"], bar=["x", "y", "z"])

        @testset "dims = $d" for d in (Colon(), 1, 2)
            @test Transforms.apply(A, p; dims=d) == expected
        end

        _A = copy(A)
        Transforms.apply!(_A, p)
        @test _A == axisarray_expected
        @test _A isa AxisArray
    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 8 27; 64 125 216]
        axiskey_expected = KeyedArray([1 8 27; 64 125 216], foo=["a", "b"], bar=["x", "y", "z"])

        @testset "dims = $d" for d in (Colon(), :foo, :bar)
            @test Transforms.apply(A, p; dims=d) == expected
        end

        _A = copy(A)
        Transforms.apply!(_A, p)
        @test _A == axiskey_expected
        @test _A isa KeyedArray
    end

    @testset "NamedTuple" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = [[1, 8, 27], [64, 125, 216]]
        nt_expected = (a = [1, 8, 27], b = [64, 125, 216])

        @testset "all cols" begin
            @test Transforms.apply(nt, p) == expected
            @test p(nt) == expected

            _nt = deepcopy(nt)
            Transforms.apply!(_nt, p)
            @test _nt == nt_expected
            @test _nt isa NamedTuple
        end

        @testset "cols = $c" for c in (:a, :b)
            nt_mutated = NamedTuple{(Symbol("$c"), )}((nt_expected[c], ))
            nt_expected_col = merge(nt, nt_mutated)

            expected = [nt_expected[c]]
            @test Transforms.apply(nt, p; cols=[c]) == expected
            @test p(nt; cols=[c]) == expected

            _nt = deepcopy(nt)
            Transforms.apply!(_nt, p; cols=[c])
            @test _nt == nt_expected_col
            @test _nt isa NamedTuple
        end
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])
        expected = [[1, 8, 27], [64, 125, 216]]
        df_expected = DataFrame(:a => [1, 8, 27], :b => [64, 125, 216])

        @test Transforms.apply(df, p) == expected

        @test Transforms.apply(df, p; cols=[:a]) == [[1, 8, 27]]
        @test Transforms.apply(df, p; cols=[:b]) == [[64, 125, 216]]

        _df = deepcopy(df)
        Transforms.apply!(_df, p)
        @test _df == df_expected
        @test _df isa DataFrame
    end
end
