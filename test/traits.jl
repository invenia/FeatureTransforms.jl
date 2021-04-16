@testset "traits.jl" begin
    for t in (OneToOne(), OneToMany(), ManyToOne(), ManyToMany())
        @test t isa FeatureTransforms.Cardinality
    end
end
