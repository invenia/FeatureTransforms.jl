@testset "one hot encoding" begin

    categories = ["foo", "bar", "baz"]
    ohe = OneHotEncoding(categories)
    @test ohe isa Transform
    @test cardinality(ohe) == OneToMany()

    @testset "Basic" begin

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

        @testset "apply_append" begin
            M = ["foo" "bar"; "foo2" "bar2"]
            @test_throws DimensionMismatch FeatureTransforms.apply_append(M, ohe; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(M, ohe; append_dim=2)
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

        @testset "apply_append" begin
            M = ["foo" "bar"; "foo2" "bar2"]
            A = AxisArray(M, foo=["a", "b"], bar=["x", "y"])
            @test_throws DimensionMismatch FeatureTransforms.apply_append(A, ohe; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(A, ohe; append_dim=2)
        end
    end

    @testset "AxisKey" begin
        categories = ["foo", "bar", "baz", "foo2", "bar2"]
        ohe = OneHotEncoding(categories)

        M = ["foo" "bar"; "foo2" "bar2"]
        A = KeyedArray(M, foo=["a", "b"], bar=["x", "y"])
        expected = [1 0 0 0 0; 0 0 0 1 0; 0 1 0 0 0; 0 0 0 0 1]

        @testset "dims = $d" for d in (1, 2, Colon(), :foo, :bar)
            transformed = FeatureTransforms.apply(A, ohe; dims=d)
            # This transform doesn't preserve the type it operates on
            @test transformed isa AbstractArray
            @test transformed == expected
        end

        @testset "inds" begin
            @test FeatureTransforms.apply(A, ohe; inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
            @test FeatureTransforms.apply(A, ohe; dims=:, inds=[2, 3]) == [0 0 0 1 0; 0 1 0 0 0]
        end

        @testset "apply_append" begin
            M = ["foo" "bar"; "foo2" "bar2"]
            A = KeyedArray(M, foo=["a", "b"], bar=["x", "y"])
            @test_throws DimensionMismatch FeatureTransforms.apply_append(A, ohe; append_dim=:foo)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(A, ohe; append_dim=:bar)
        end
    end
end
