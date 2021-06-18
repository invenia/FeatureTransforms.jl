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
end
