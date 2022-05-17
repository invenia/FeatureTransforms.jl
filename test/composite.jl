@testset "composite.jl" begin
    @testset "constructor" begin
        id = IdentityScaling()
        power = Power(3.0)
        logt = LogTransform()
        @test id ∘ id == Composite((id, id))
        @test id ∘ id ∘ power == Composite((power, id, id))
        @test power ∘ id ∘ power == Composite((power, id, power))

        @test power ∘ (id ∘ logt) == Composite((logt, id, power))
        @test (power ∘ id) ∘ logt == Composite((logt, id, power))
        @test (power ∘ id) ∘ (logt ∘ id) == Composite((id, logt, id, power))

        @test_throws ArgumentError id ∘ LinearCombination([1, 2, 3])
        @test_throws ArgumentError OneHotEncoding([1, 2]) ∘ id
    end

    @testset "apply" begin
        p = Power(4.0)
        c = Power(2.0) ∘ Power(2.0) ∘ IdentityScaling()
        x = [1, 2, 3]
        @test FeatureTransforms.apply(x, p) == FeatureTransforms.apply(x, c)
        @test p(x) == c(x)
    end

    @testset "fit!" begin
        s = StandardScaling()
        c = StandardScaling() ∘ IdentityScaling() ∘ StandardScaling()
        x = rand(10)
        x_copy = deepcopy(x)
        
        fit!(s, x)
        fit!(c, x)

        @test c(x) ≈ s(x)

        # did not change the input data
        @test x_copy == x

        # but make sure that it is fit and transformed on the already transformed data, in
        # this case leaving the second scaling redundant, i.e. centered at 0.0 and std = 1.0
        @test isapprox(0.0, c.transforms[3].μ; atol=1e-15)
        @test isapprox(1.0, c.transforms[3].σ; atol=1e-15)
    end
end
