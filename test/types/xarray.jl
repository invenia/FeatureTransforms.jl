@testset "$ArrayType" for ArrayType in (AxisArray, KeyedArray, NamedDimsArray)

    x = ArrayType([1 2 3; 4 5 6], foo=["a", "b"], bar=[:x, :y, :z])

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
        @test_broken FeatureTransforms.apply!(copy(x), T; inds=[1, 2])
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

    if ArrayType != AxisArray
        @testset "indexing with dims" begin

            T = FakeOneToOneTransform()

            # apply
            @test FeatureTransforms.apply(x, T; dims=:foo) == ones(2, 3)
            @test FeatureTransforms.apply(x, T; dims=:bar) == ones(2, 3)

            # apply to certain dims/inds
            @test FeatureTransforms.apply(x, T; dims=:bar, inds=Key([:x, :z])) == ones(2, 2)

            # apply_append
            @test isequal(
                FeatureTransforms.apply_append(x, T; dims=:foo, append_dim=:foo),
                cat(x, ones(2, 3); dims=:foo)
            )
        end
    end

end
