@testset "scaling" begin
    @testset "MeanStdScaling" begin
        scaling = MeanStdScaling()

        @test scaling isa Transform

        @testset "Vector" begin
            x = [1., 2., 3.]
            expected = [-1., 0., 1.]

            @test Transforms.apply(x, scaling) ≈ expected atol=1e-6
            @test scaling(x) ≈ expected atol=1e-6

            # Test the transform was not mutating
            @test !isapprox(x, expected; atol=1e-6)
        end
    end
end
