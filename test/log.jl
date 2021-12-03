@testset "log" begin

    V1 = [1; 2; 3; 4; 0; 6]
    V2 = [1; 2; -3; 4; 0; 6]
    M = [1 1 0.5; 0.0 1.0 2.0]

    @testset "LogTransform" begin
 
        logV1 = [log(2); log(3); log(4); log(5); log(1); log(7)]
        logV2 = [log(2); log(3); -log(4); log(5); log(1); log(7)]
        logM = [log(2) log(2) log(1.5); log(1) log(2) log(3)]

        @testset "simple" for x in (V1, V2, M)
            transform = LogTransform()
            @test cardinality(transform) == OneToOne()
            @test transform isa Transform
        end

        @testset "Apply" for (x, y) in ((V1, logV1), (V2, logV2), (M, logM))
            f = LogTransform()
            transformed = FeatureTransforms.apply(x, f)
            @test transformed ≈ y atol=1e-5
            @test FeatureTransforms.apply(transformed, f; inverse=true) ≈ x atol=1e-5
        end
    end

    @testset "InverseHyperbolicSine" begin
 
        logV1 = asinh.(V1)
        logV2 = asinh.(V2)
        logM = asinh.(M)

        @testset "simple" for x in (V1, V2, M)
            transform = InverseHyperbolicSine()
            @test cardinality(transform) == OneToOne()
            @test transform isa Transform
        end

        @testset "Apply" for (x, y) in ((V1, logV1), (V2, logV2), (M, logM))
            f = InverseHyperbolicSine()
            transformed = FeatureTransforms.apply(x, f)
            @test transformed ≈ y atol=1e-5
            @test FeatureTransforms.apply(transformed, f; inverse=true) ≈ x atol=1e-5
        end
    end
end