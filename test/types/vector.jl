@testset "vector" begin

    @testset "is_transformable" begin
        x = [1, 2, 3]
        @test is_transformable(x)
    end

    @testset "apply" begin

        @testset "OneToOne" begin
            x = [1, 2, 3]
            T = FakeOneToOneTransform()
            @test FeatureTransforms.apply(x, T) == ones(3)
            @test FeatureTransforms.apply(x, T; inds=[2, 3]) == ones(2)
        end

        @testset "OneToMany" begin
            x = [1, 2, 3]
            T = FakeOneToManyTransform()
            @test FeatureTransforms.apply(x, T) == [ones(3) ones(3)]
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == [ones(2) ones(2)]
        end

        @testset "ManyToOne" begin
            x = [1, 2, 3]
            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == fill(1.0)
            @test FeatureTransforms.apply(x, T; dims=1, inds=[1, 2]) == fill(1.0)
            @test_throws BoundsError FeatureTransforms.apply(x, T; dims=2)
        end

        @testset "ManyToMany" begin
            x = [1, 2, 3]
            T = FakeManyToManyTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == [ones(3) ones(3)]
            @test FeatureTransforms.apply(x, T; dims=1, inds=[1, 3]) == [ones(2) ones(2)]
            @test_throws BoundsError FeatureTransforms.apply(x, T; dims=2)
        end

    end

    @testset "apply!" begin
        T = FakeOneToOneTransform()

        x = [1, 2, 3]
        FeatureTransforms.apply!(x, T)
        @test x == ones(3)

        # https://github.com/invenia/FeatureTransforms.jl/issues/68
        x = [1, 2, 3]
        @test_broken FeatureTransforms.apply!(x, T; inds=[1, 2])
    end

    @testset "apply_append" begin

        @testset "OneToOne" begin
            x = [1, 2, 3]
            T = FakeOneToOneTransform()
            @test FeatureTransforms.apply_append(x, T; append_dim=1) == [1, 2, 3, 1, 1, 1]
            @test FeatureTransforms.apply_append(x, T; append_dim=2) == [x ones(3)]
            @test FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=1) == [1, 2, 3, 1, 1]
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2)
        end

        @testset "OneToMany" begin
            x = [1, 2, 3]
            T = FakeOneToManyTransform()
            @test FeatureTransforms.apply_append(x, T; append_dim=2) == [x ones(3) ones(3)]
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2)
        end

        @testset "ManyToOne" begin
            x = [1, 2, 3]
            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply_append(x, T; dims=1, append_dim=1) == [1, 2, 3, 1]
            @test_throws BoundsError FeatureTransforms.apply_append(x, T; dims=1, append_dim=2)
            @test_throws BoundsError FeatureTransforms.apply_append(x, T; dims=2, append_dim=1)
            @test_throws BoundsError FeatureTransforms.apply_append(x, T; dims=2, append_dim=2)
        end

        @testset "ManyToMany" begin
            x = [1, 2, 3]
            T = FakeManyToManyTransform()
            @test FeatureTransforms.apply_append(x, T; append_dim=2) == [x ones(3) ones(3)]
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=1)
            @test_throws DimensionMismatch FeatureTransforms.apply_append(x, T; inds=[1, 2], append_dim=2)
        end

    end

end
