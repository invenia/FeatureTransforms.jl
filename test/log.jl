@testset "log" begin

    V1 = [1; 2; 3; 4; 5; 6]
    V2 = [1; 2; -3; 4; 5; 6]
    M = [1 1 0.5; 0.0 1.0 2.0]

    @testset "LogTransform" begin
 
        logV1 = [0.693147; 1.098612; 1.386294; 1.609437; 1.791759; 1.945910]
        logV2 = [0.693147; 1.098612; -1.386294; 1.609437; 1.791759; 1.945910]
        logM = [0.693147  0.693147  0.405465; 0.0 0.693147 1.09861]

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