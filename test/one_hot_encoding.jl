@testset "one hot encoding" begin

    categories = ["foo", "bar", "baz"]
    ohe = OneHotEncoding(categories)
    @test ohe isa Transform

    @testset "Vector" begin
        x = ["foo", "bar", "baz"]
        expected = [1 0 0; 0 1 0; 0 0 1]

        transformed = FeatureTransforms.apply(x, ohe)
        @test transformed == expected
        @test transformed isa AbstractMatrix{Bool}
        @test ohe(x) == expected

        # Test specifying return type
        transformed = FeatureTransforms.apply(x, OneHotEncoding{AbstractFloat}(categories))
        @test transformed == expected
        @test transformed isa AbstractMatrix{AbstractFloat}

        # Test duplicate values
        x = ["foo", "baz", "bar", "baz"]
        expected = [1 0 0; 0 0 1; 0 1 0; 0 0 1]
        @test FeatureTransforms.apply(x, ohe) == expected

        # Test cannot pass duplicate values as the categories
        @test_throws ArgumentError OneHotEncoding(x)

        # Test a value does not exist as a category
        x = ["foo", "baz", "bar", "dne"]
        @test_throws KeyError FeatureTransforms.apply(x, ohe)

        @testset "inds" begin
             x = ["foo", "baz", "bar", "baz"]
            @test FeatureTransforms.apply(x, ohe; inds=2:4) == [0 0 1; 0 1 0; 0 0 1]
            @test FeatureTransforms.apply(x, ohe; dims=:) == expected

            @test FeatureTransforms.apply(x, ohe; dims=1) == expected
            @test FeatureTransforms.apply(x, ohe; dims=1, inds=[2, 4]) == [0 0 1; 0 0 1]

            @test_throws BoundsError FeatureTransforms.apply(x, ohe; dims=2)
        end
    end

    categories = ["foo", "bar", "baz", "foo2", "bar2"]
    ohe = OneHotEncoding(categories)

    @testset "Matrix" begin
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
        nt = (a = ["foo" "bar"], b = ["foo2" "bar2"])
        expected_nt = (a = [1 0 0 0 0; 0 1 0 0 0], b = [0 0 0 1 0; 0 0 0 0 1])
        expected = [expected_nt.a, expected_nt.b]

        @testset "all cols" begin
            @test FeatureTransforms.apply(nt, ohe) == expected
            @test ohe(nt) == expected
        end

        @testset "cols = $c" for c in (:a, :b)
            @test FeatureTransforms.apply(nt, ohe; cols=[c]) == [expected_nt[c]]
            @test FeatureTransforms.apply(nt, ohe; cols=c) == expected_nt[c]
            @test ohe(nt; cols=[c]) == [expected_nt[c]]
        end
    end

    @testset "DataFrame" begin
        df = DataFrame(:a => ["foo", "bar"], :b => ["foo2", "bar2"])
        expected = [[1 0 0 0 0; 0 1 0 0 0], [0 0 0 1 0; 0 0 0 0 1]]

        @test FeatureTransforms.apply(df, ohe) == expected

        @test FeatureTransforms.apply(df, ohe; cols=[:a]) == [[1 0 0 0 0; 0 1 0 0 0]]
        @test FeatureTransforms.apply(df, ohe; cols=:a) == [1 0 0 0 0; 0 1 0 0 0]
        @test FeatureTransforms.apply(df, ohe; cols=[:b]) ==[[0 0 0 1 0; 0 0 0 0 1]]
    end
end