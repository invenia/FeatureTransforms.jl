@testset "power" begin

    p = Power(3)
    @test p isa Transform
    @test cardinality(p) == OneToOne()

    @test FeatureTransforms.apply([1, 2, 3], p) == [1, 8, 27]

end
