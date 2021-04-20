@testset "power" begin

    p = Power(3)
    @test p isa Transform
    @test cardinality(p) == OneToOne()

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

        @testset "apply_append" begin
            @test FeatureTransforms.apply_append(M, p, append_dim=1) == cat(M, expected, dims=1)
            @test FeatureTransforms.apply_append(M, p, append_dim=2) == cat(M, expected, dims=2)
            @test FeatureTransforms.apply_append(M, p, append_dim=3) == cat(M, expected, dims=3)
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

        @testset "apply_append" begin
            @test FeatureTransforms.apply_append(A, p, append_dim=1) == cat(A, expected, dims=1)
            @test FeatureTransforms.apply_append(A, p, append_dim=2) == cat(A, expected, dims=2)
            @test FeatureTransforms.apply_append(A, p, append_dim=3) == cat(A, expected, dims=3)
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

        @testset "apply_append" begin
            expected1 = KeyedArray(
                vcat(A, expected), foo=["a", "b", "a", "b"], bar=["x", "y", "z"]
            )
            @test FeatureTransforms.apply_append(A, p, append_dim=:foo) == expected1
            expected2 = KeyedArray(
                hcat(A, expected), foo=["a", "b"], bar=["x", "y", "z", "x", "y", "z"]
            )
            @test FeatureTransforms.apply_append(A, p, append_dim=:bar) == expected2
            expected3 = KeyedArray(
                cat(A, expected, dims=3), foo=["a", "b"], bar=["x", "y", "z"], baz=Base.OneTo(2),
            )
            @test FeatureTransforms.apply_append(A, p, append_dim=:baz) == expected3
        end
    end
end
