using FeatureTransforms.TestUtils

@testset "test_utils.jl" begin

    @testset "FakeOneToOneTransform" begin
        t = FakeOneToOneTransform()
        @test cardinality(t) == OneToOne()

        x = [1, 2, 3]
        @test FeatureTransforms.apply(x, t) == ones(3)

        M = reshape(1:9, 3, 3)
        @test FeatureTransforms.apply(M, t) == ones(3, 3)
    end

    @testset "FakeOneToManyTransform" begin
        t = FakeOneToManyTransform()
        @test cardinality(t) == OneToMany()

        x = [1, 2, 3]
        @test FeatureTransforms.apply(x, t) == ones(3, 2)

        M = reshape(1:9, 3, 3)
        @test FeatureTransforms.apply(M, t) == ones(3, 6)
    end

    @testset "FakeManyToOneTransform" begin
        t = FakeManyToOneTransform()
        @test cardinality(t) == ManyToOne()

        x = [1, 2, 3]
        @test FeatureTransforms.apply(x, t; dims=1) == fill(1)

        M = reshape(1:9, 3, 3)
        @test FeatureTransforms.apply(M, t; dims=1) == ones(3)
    end

    @testset "FakeManyToManyTransform" begin
        t = FakeManyToManyTransform()
        @test cardinality(t) == ManyToMany()

        x = [1, 2, 3]
        @test FeatureTransforms.apply(x, t) == ones(3, 2)

        M = reshape(1:9, 3, 3)
        @test FeatureTransforms.apply(M, t) == ones(3, 6)
    end
end
