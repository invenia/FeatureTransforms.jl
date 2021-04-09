# This is how we might test a new data type that we want to support.
# For illustrative purposes this is testing DataFrames.

using DataFrames
using FeatureTransforms
using FeatureTransforms.TestUtils
using Test

@testset "example apply tests" begin

    @testset "OneToOne" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [7, 8, 9])
        t = FakeOneToOneTransform()

        @test isequal(
            FeatureTransforms.apply(df, t),
            DataFrame(ones(3, 3), [:Column1, :Column2, :Column3]),
        )

        @test isequal(
                FeatureTransforms.apply(df, t; header=[:a, :b, :c]),
                DataFrame(ones(3, 3), [:a, :b, :c]),
        )

        @test FeatureTransforms.apply(df, t; cols=:a) == DataFrame(:Column1 => ones(3))
    end

    @testset "OneToMany" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [7, 8, 9])
        t = FakeOneToManyTransform()

        @test isequal(
            FeatureTransforms.apply(df, t),
            DataFrame(ones(3, 6), [:Column1, :Column2, :Column3, :Column4, :Column5, :Column6]),
        )

        @test isequal(
            FeatureTransforms.apply(df, t; header=[:a, :b, :c, :d, :e, :f]),
            DataFrame(ones(3, 6), [:a, :b, :c, :d, :e, :f]),
        )

        @test isequal(
            FeatureTransforms.apply(df, t, cols=:a),
            DataFrame(ones(3, 2), [:Column1, :Column2]),
        )
    end

    @testset "ManyToOne" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [7, 8, 9])
        t = FakeManyToOneTransform()

        @test isequal(FeatureTransforms.apply(df, t), DataFrame(:Column1 => ones(3)))
        @test isequal(FeatureTransforms.apply(df, t; header=[:a]), DataFrame(:a => ones(3)))
        @test isequal(FeatureTransforms.apply(df, t; cols=:a), DataFrame(:Column1 => ones(3)))
    end

    @testset "ManyToMany" begin
        df = DataFrame(:a => [1, 2, 3], :b => [4, 5, 6], :c => [7, 8, 9])
        t = FakeManyToManyTransform()

        @test isequal(
            FeatureTransforms.apply(df, t),
            DataFrame(ones(3, 6), [:Column1, :Column2, :Column3, :Column4, :Column5, :Column6]),
        )

        @test isequal(
            FeatureTransforms.apply(df, t; header=[:a, :b, :c, :d, :e, :f]),
            DataFrame(ones(3, 6), [:a, :b, :c, :d, :e, :f]),
        )

        @test isequal(
            FeatureTransforms.apply(df, t, cols=:a),
            DataFrame(ones(3, 2), [:Column1, :Column2]),
        )
    end

end
