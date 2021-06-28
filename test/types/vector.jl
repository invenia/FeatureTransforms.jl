@testset "vector" begin

    x = [1, 2, 3]

    @test is_transformable(x)

    @testset "apply" begin

        @testset "OneToOne" begin
            T = FakeOneToOneTransform()
            @test FeatureTransforms.apply(x, T) == ones(3)
            @test FeatureTransforms.apply(x, T; inds=[2, 3]) == ones(2)
        end

        @testset "OneToMany" begin
            T = FakeOneToManyTransform()
            @test FeatureTransforms.apply(x, T) == [ones(3) ones(3)]
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == [ones(2) ones(2)]
        end

        @testset "ManyToOne" begin
            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == fill(1.0)
            @test FeatureTransforms.apply(x, T; dims=1, inds=[1, 2]) == fill(1.0)
            @test_throws BoundsError FeatureTransforms.apply(x, T; dims=2)
        end

        @testset "ManyToMany" begin
            T = FakeManyToManyTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == [ones(3) ones(3)]
            @test FeatureTransforms.apply(x, T; dims=1, inds=[1, 3]) == [ones(2) ones(2)]
            @test_throws BoundsError FeatureTransforms.apply(x, T; dims=2)
        end

    end

    @testset "apply!" begin
        T = FakeOneToOneTransform()

        _x = copy(x)
        FeatureTransforms.apply!(_x, T)
        @test _x == ones(3)

        # https://github.com/invenia/FeatureTransforms.jl/issues/68
        _x = copy(x)
        @test_broken FeatureTransforms.apply!(_x, T; inds=[1, 2])
        @test_broken _x == [1, 1, 3]
    end

    @testset "apply_append" begin

        @testset "OneToOne" begin
            T = FakeOneToOneTransform()
            @test FeatureTransforms.apply_append(x, T; append_dim=1) == [1, 2, 3, 1, 1, 1]
            @test FeatureTransforms.apply_append(x, T; append_dim=2) == [x ones(3)]
            @test FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=1) == [1, 2, 3, 1, 1]
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2)
        end

        @testset "OneToMany" begin
            T = FakeOneToManyTransform()
            @test FeatureTransforms.apply_append(x, T; append_dim=2) == [x ones(3) ones(3)]
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2)
        end

        @testset "ManyToOne" begin
            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply_append(x, T; dims=1, append_dim=1) == [1, 2, 3, 1]
            @test_throws BoundsError FeatureTransforms.apply_append(x, T; dims=1, append_dim=2)
            @test_throws BoundsError FeatureTransforms.apply_append(x, T; dims=2, append_dim=1)
            @test_throws BoundsError FeatureTransforms.apply_append(x, T; dims=2, append_dim=2)
        end

        @testset "ManyToMany" begin
            T = FakeManyToManyTransform()
            @test FeatureTransforms.apply_append(x, T; append_dim=2) == [x ones(3) ones(3)]
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2)
        end

    end

end
