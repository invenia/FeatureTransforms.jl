# Want to test that certain subtypes of arrays are compatible
_make_matrix(::Type{Matrix}) = [1 2 3; 4 5 6]
_make_matrix(::Type{SubArray}) = view([1 2 3; 4 5 6], :, :)
_make_matrix(::Type{ReshapedArray}) = reshape([1 2 3; 4 5 6], 2, 3)

@testset "$MatrixType" for MatrixType in (Matrix, SubArray, ReshapedArray)

    x = _make_matrix(MatrixType)

    @test is_transformable(x)

    @testset "apply" begin

        @testset "OneToOne" begin
            T = FakeOneToOneTransform()
            @test FeatureTransforms.apply(x, T) == ones(2, 3)
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == ones(2)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[2, 3]) == ones(2, 2)
        end

        @testset "OneToMany" begin
            T = FakeOneToManyTransform()
            @test FeatureTransforms.apply(x, T) == ones(2, 6)
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == ones(2, 2)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[2, 3]) == ones(2, 4)
        end

        @testset "ManyToOne" begin
            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == ones(3)
            @test FeatureTransforms.apply(x, T; dims=1, inds=[1, 2]) == ones(3)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[1, 2]) == ones(2)
        end

        @testset "ManyToMany" begin
            T = FakeManyToManyTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == ones(2, 6)
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == ones(2, 2)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[2, 3]) == ones(2, 4)
        end

    end

    @testset "apply!" begin
        T = FakeOneToOneTransform()

        _x = copy(x)
        FeatureTransforms.apply!(_x, T)
        @test _x == ones(2, 3)

        # https://github.com/invenia/FeatureTransforms.jl/issues/68
        _x = copy(x)
        @test_broken FeatureTransforms.apply!(_x, T; dims=2, inds=[1, 2])
        @test_broken _x == [1 1 3; 1 1 6]
    end

    @testset "apply_append" begin

        @testset "OneToOne" begin

            T = FakeOneToOneTransform()

            @test FeatureTransforms.apply_append(x, T; append_dim=1) == vcat(x, ones(2, 3))
            @test FeatureTransforms.apply_append(x, T; append_dim=2) == hcat(x, ones(2, 3))
            @test FeatureTransforms.apply_append(x, T; append_dim=3) == cat(x, ones(2, 3), dims=3)

            @test isequal(
                FeatureTransforms.apply_append(x, T; dims=1, inds=[1], append_dim=1),
                vcat(x, ones(1, 3))
            )

            @test isequal(
                FeatureTransforms.apply_append(x, T; dims=2, inds=[1, 2], append_dim=2),
                hcat(x, ones(2, 2))
            )
        end

        @testset "OneToMany" begin

            T = FakeOneToManyTransform()

            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=3)

            @test isequal(
                FeatureTransforms.apply_append(x, T; append_dim=2),
                hcat(x, ones(2, 6))
            )

            @test isequal(
                FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2),
                hcat(x, ones(2, 2))
            )
        end

        @testset "ManyToOne" begin

            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply_append(x, T; dims=1, append_dim=1) == vcat(x, ones(1, 3))
            @test FeatureTransforms.apply_append(x, T; dims=2, append_dim=2) == hcat(x, ones(2))
        end

        @testset "ManyToMany" begin

            T = FakeManyToManyTransform()

            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=3)

            @test isequal(
                FeatureTransforms.apply_append(x, T; append_dim=2),
                hcat(x, ones(2, 6))
            )

            @test isequal(
                FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2),
                hcat(x, ones(2, 2))
            )
        end

    end

end
