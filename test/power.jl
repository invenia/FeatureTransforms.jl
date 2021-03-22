@testset "power" begin

    p = Power(3)
    @test p isa Transform

    # TODO: all of these should be part of some test utils
    @testset "Vector" begin
        x = [1, 2, 3, 4, 5]
        expected = [1, 8, 27, 64, 125]

        @test FeatureTransforms.apply(x, p) == expected
        @test p(x) == expected

        _x = copy(x)
        FeatureTransforms.apply!(_x, p)
        @test _x == expected

        @testset "inds" begin
            @test FeatureTransforms.apply(x, p; inds=2:5) ==  expected[2:5]
            @test FeatureTransforms.apply(x, p; dims=:) == expected
            @test FeatureTransforms.apply(x, p; dims=1) == expected
            @test FeatureTransforms.apply(x, p; dims=1, inds=[2, 3, 4, 5]) == expected[2:5]

            @test_throws BoundsError FeatureTransforms.apply(x, p; dims=2)
        end
    end

    @testset "Matrix" begin
        M = [1 2 3; 4 5 6]
        expected = [1 8 27; 64 125 216]

        @testset "dims = $d" for d in (Colon(), 1, 2)
            @test FeatureTransforms.apply(M, p; dims=d) == expected
            @test p(M; dims=d) == expected

            _M = copy(M)
            FeatureTransforms.apply!(_M, p; dims=d)
            @test _M == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(M, p; inds=[2, 3]) == expected[[2, 3]]
            @test FeatureTransforms.apply(M, p; dims=:, inds=[2, 3]) == expected[[2, 3]]
            @test FeatureTransforms.apply(M, p; dims=1, inds=[2]) == [64 125 216]
            @test FeatureTransforms.apply(M, p; dims=2, inds=[2]) == reshape([8, 125], 2, 1)
        end
    end

    @testset "AxisArray" begin
        A = AxisArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 8 27; 64 125 216]

        @testset "dims = $d" for d in (Colon(), 1, 2)
            transformed = FeatureTransforms.apply(A, p; dims=d)
            # AxisArray doesn't preserve the type it operates on
            @test transformed isa AbstractArray
            @test transformed == expected
        end

        _A = copy(A)
        FeatureTransforms.apply!(_A, p)
        @test _A isa AxisArray
        @test _A == expected

        @testset "inds" begin
            @test FeatureTransforms.apply(A, p; inds=[2, 3]) == expected[[2, 3]]
            @test FeatureTransforms.apply(A, p; dims=:, inds=[2, 3]) == expected[[2, 3]]
            @test FeatureTransforms.apply(A, p; dims=1, inds=[2]) == [64 125 216]
            @test FeatureTransforms.apply(A, p; dims=2, inds=[2]) == reshape([8, 125], 2, 1)
        end
    end

    @testset "AxisKey" begin
        A = KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"])
        expected = KeyedArray([1 8 27; 64 125 216], foo=["a", "b"], bar=["x", "y", "z"])

        @testset "dims = $d" for d in (Colon(), :foo, :bar, 1, 2)
            transformed = FeatureTransforms.apply(A, p; dims=d)
            @test transformed isa KeyedArray
            @test transformed == expected
        end

        _A = copy(A)
        FeatureTransforms.apply!(_A, p)
        @test _A isa KeyedArray
        @test _A == expected

        @testset "inds" begin
            @test FeatureTransforms.apply(A, p; inds=[2, 3]) == [64, 8]
            @test FeatureTransforms.apply(A, p; dims=:, inds=[2, 3]) == [64, 8]
            @test FeatureTransforms.apply(A, p; dims=1, inds=[2]) == [64 125 216]
            @test FeatureTransforms.apply(A, p; dims=2, inds=[2]) == reshape([8, 125], 2, 1)
        end
    end

    @testset "NamedTuple" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])

        @testset "all cols" begin

            expected_nt = (Column1 = [1, 8, 27], Column2 = [64, 125, 216])
            @test FeatureTransforms.apply(nt, p) == expected_nt
            @test p(nt) == expected_nt

            _nt = deepcopy(nt)
            FeatureTransforms.apply!(_nt, p)
            @test _nt isa NamedTuple{(:a, :b)}
            @test _nt == (a = [1, 8, 27], b = [64, 125, 216])
        end

        @testset "cols = $c" for c in (:a, :b)
            expected = getproperty(nt, c) .^3

            @test FeatureTransforms.apply(nt, p; cols=c) == (Column1 = expected, )
            @test p(nt; cols=c) == (Column1 = expected, )

            @testset "mutating" for _c in (c, [c])
                _nt = deepcopy(nt)
                FeatureTransforms.apply!(_nt, p; cols=_c)
                @test _nt == merge(nt, NamedTuple{(c,)}((expected,)))
                @test _nt isa NamedTuple
            end
        end
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6])

        @testset "all cols" begin
            expected_df = DataFrame(:Column1 => [1, 8, 27], :Column2 => [64, 125, 216])
            @test FeatureTransforms.apply(df, p) == expected_df
            @test p(df) == expected_df

            _df = deepcopy(df)
            FeatureTransforms.apply!(_df, p)
            @test _df isa DataFrame
            @test _df == DataFrame(:a => [1, 8, 27], :b => [64, 125, 216])
        end

        @testset "cols = $c" for c in (:a, :b)
            expected = getproperty(df, c) .^ 3
            @test FeatureTransforms.apply(df, p; cols=[c]) == DataFrame(:Column1=>expected)
            @test FeatureTransforms.apply(df, p; cols=c) == DataFrame(:Column1=>expected)
            @test p(df; cols=[c]) == DataFrame(:Column1=>expected)
        end
    end
end
