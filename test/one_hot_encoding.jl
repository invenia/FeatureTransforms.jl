@testset "one hot encoding" begin

    categories = ["foo", "bar", "baz"]
    ohe = OneHotEncoding(categories)
    @test ohe isa Transform

    @testset "Vector" begin

        @testset "simple" begin
            x = ["foo", "bar", "baz"]
            expected = [1 0 0; 0 1 0; 0 0 1]

            transformed = FeatureTransforms.apply(x, ohe)
            @test transformed == expected
            @test transformed isa AbstractMatrix{Bool}
            @test ohe(x) == expected
        end

        @testset "specify return type" begin
            x = ["foo", "bar", "baz"]
            expected = [1 0 0; 0 1 0; 0 0 1]
            transformed = FeatureTransforms.apply(x, OneHotEncoding{AbstractFloat}(categories))
            @test transformed == expected
            @test transformed isa AbstractMatrix{AbstractFloat}
        end

        @testset "duplicate values" begin
            x = ["foo", "baz", "bar", "baz"]
            expected = [1 0 0; 0 0 1; 0 1 0; 0 0 1]
            @test FeatureTransforms.apply(x, ohe) == expected

            # Cannot pass duplicate values as the categories for the OHE constructor
            @test_throws ArgumentError OneHotEncoding(x)
        end

        @testset "value does not exist as a category" begin
            x = ["foo", "baz", "bar", "dne"]
            @test_throws KeyError FeatureTransforms.apply(x, ohe)
        end

        @testset "inds" begin
            x = ["foo", "baz", "bar", "baz"]
            expected = [1 0 0; 0 0 1; 0 1 0; 0 0 1]

            @test FeatureTransforms.apply(x, ohe; inds=2:4) == [0 0 1; 0 1 0; 0 0 1]
            @test FeatureTransforms.apply(x, ohe; dims=:) == expected

            @test FeatureTransforms.apply(x, ohe; dims=1) == expected
            @test FeatureTransforms.apply(x, ohe; dims=1, inds=[2, 4]) == [0 0 1; 0 0 1]

            @test_throws BoundsError FeatureTransforms.apply(x, ohe; dims=2)
        end
    end


    @testset "Matrix" begin
        categories = ["foo", "bar", "baz", "foo2", "bar2"]
        ohe = OneHotEncoding(categories)

        M = ["foo" "bar"; "foo2" "bar2"]
        expected = [1 0 0 0 0; 0 0 0 1 0; 0 1 0 0 0; 0 0 0 0 1]

        @test FeatureTransforms.apply(M, ohe) == expected

        @testset "dims=:$d" for d in (1, 2, Colon())
            @test FeatureTransforms.apply(M, ohe; dims=d) == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(M, ohe; inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
            @test FeatureTransforms.apply(M, ohe; dims=:, inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
        end
    end

    @testset "AxisArray" begin
        categories = ["foo", "bar", "baz", "foo2", "bar2"]
        ohe = OneHotEncoding(categories)

        M = ["foo" "bar"; "foo2" "bar2"]
        A = AxisArray(M, foo=["a", "b"], bar=["x", "y"])
        expected = [1 0 0 0 0; 0 0 0 1 0; 0 1 0 0 0; 0 0 0 0 1]

        @testset "dims = $d" for d in (1, 2, Colon())
            transformed = FeatureTransforms.apply(A, ohe; dims=d)
            # AxisArray doesn't preserve the type it operates on
            @test transformed isa AbstractArray
            @test transformed == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(A, ohe; inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
            @test FeatureTransforms.apply(A, ohe; dims=:, inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
        end
    end

    @testset "AxisKey" begin
        categories = ["foo", "bar", "baz", "foo2", "bar2"]
        ohe = OneHotEncoding(categories)

        M = ["foo" "bar"; "foo2" "bar2"]
        A = KeyedArray(M, foo=["a", "b"], bar=["x", "y"])
        expected = [1 0 0 0 0; 0 0 0 1 0; 0 1 0 0 0; 0 0 0 0 1]

        @testset "dims = $d" for d in (1, 2, Colon())
            transformed = FeatureTransforms.apply(A, ohe; dims=d)
            # This transform doesn't preserve the type it operates on
            @test transformed isa AbstractArray
            @test transformed == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(A, ohe; inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
            @test FeatureTransforms.apply(A, ohe; dims=:, inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
        end
    end

    @testset "NamedTuple" begin
        categories = ["foo", "bar", "baz", "foo2", "bar2"]
        ohe = OneHotEncoding(categories)
        nt = (a = ["foo" "bar"], b = ["foo2" "bar2"])

        @testset "all cols" begin
            expected = NamedTuple{Tuple(Symbol.(:Column, x) for x in 1:10)}(
               ([1, 0], [0, 1], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 0], [0, 1])
            )
            @test FeatureTransforms.apply(nt, ohe) == expected
            @test ohe(nt) == expected
        end

        @testset "cols = :a" begin
            expected = NamedTuple{Tuple(Symbol.(:Column, x) for x in 1:5)}(
                ([1, 0], [0, 1], [0, 0], [0, 0], [0, 0])
            )
            @test FeatureTransforms.apply(nt, ohe; cols=[:a]) == expected
            @test FeatureTransforms.apply(nt, ohe; cols=:a) == expected
            @test ohe(nt; cols=:a) == expected
        end
    end

    @testset "DataFrame" begin
        categories = ["foo", "bar", "baz", "foo2", "bar2"]
        ohe = OneHotEncoding(categories)

        df = DataFrame(:a => ["foo", "bar"], :b => ["foo2", "bar2"])
        expected = DataFrame(
            [[1, 0], [0, 1], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [1, 0], [0, 1]],
            [Symbol.(:Column, x) for x in 1:10],
        )

        @test FeatureTransforms.apply(df, ohe) == expected

        @test FeatureTransforms.apply(df, ohe; cols=[:a]) == expected[:, 1:5]
        @test FeatureTransforms.apply(df, ohe; cols=:a) == expected[:, 1:5]

        expected = DataFrame(
            [[0, 0], [0, 0], [0, 0], [1, 0], [0, 1]],
            [Symbol.(:Column, x) for x in 1:5],
        )
        @test FeatureTransforms.apply(df, ohe; cols=[:b]) == expected
    end
end
