@testset "vector" begin

    @testset "is_transformable" begin
        x = [1 2 3; 4 5 6]
        @test is_transformable(x)
    end

    @testset "apply" begin

        @testset "OneToOne" begin
            x = [1 2 3; 4 5 6]
            T = FakeOneToOneTransform()
            @test FeatureTransforms.apply(x, T) == ones(2, 3)
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == ones(2)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[2, 3]) == ones(2, 2)
        end

        @testset "OneToMany" begin
            x = [1 2 3; 4 5 6]
            T = FakeOneToManyTransform()
            @test FeatureTransforms.apply(x, T) == ones(2, 6)
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == ones(2, 2)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[2, 3]) == ones(2, 4)
        end

        @testset "ManyToOne" begin
            x = [1 2 3; 4 5 6]
            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == ones(3)
            @test FeatureTransforms.apply(x, T; dims=1, inds=[1, 2]) == ones(3)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[1, 2]) == ones(2)
        end

        @testset "ManyToMany" begin
            x = [1 2 3; 4 5 6]
            T = FakeManyToManyTransform()
            @test FeatureTransforms.apply(x, T; dims=1) == ones(2, 6)
            @test FeatureTransforms.apply(x, T; inds=[1, 2]) == ones(2, 2)
            @test FeatureTransforms.apply(x, T; dims=2, inds=[2, 3]) == ones(2, 4)
        end

    end

    @testset "apply!" begin
        T = FakeOneToOneTransform()

        x = [1 2 3; 4 5 6]
        FeatureTransforms.apply!(x, T)
        @test x == ones(2, 3)

        # https://github.com/invenia/FeatureTransforms.jl/issues/68
        x = [1 2 3; 4 5 6]
        @test_broken FeatureTransforms.apply!(x, T; inds=[1, 2])
    end

    @testset "apply_append" begin

        @testset "OneToOne" begin
            x = [1 2 3; 4 5 6]
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
            x = [1 2 3; 4 5 6]
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
            x = [1 2 3; 4 5 6]
            T = FakeManyToOneTransform()
            @test FeatureTransforms.apply_append(x, T; dims=1, append_dim=1) == vcat(x, ones(1, 3))
            @test FeatureTransforms.apply_append(x, T; dims=2, append_dim=2) == hcat(x, ones(2))
        end

        @testset "ManyToMany" begin
            x = [1 2 3; 4 5 6]
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
