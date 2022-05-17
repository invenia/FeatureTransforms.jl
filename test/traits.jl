@testset "traits.jl" begin
    for t in (OneToOne(), OneToMany(), ManyToOne(), ManyToMany())
        @test t isa FeatureTransforms.Cardinality
    end

    @testset "composite" begin
        @test OneToOne() == OneToOne() ∘ OneToOne()
        @test OneToMany() == OneToMany() ∘ OneToOne()
        @test_throws ArgumentError ManyToOne() ∘ OneToOne()
        @test_throws ArgumentError ManyToMany() ∘ OneToOne()

        @test ManyToOne() == OneToOne() ∘ ManyToOne()
        @test ManyToMany() == OneToMany() ∘ ManyToOne()
        @test_throws ArgumentError ManyToOne() ∘ ManyToOne()
        @test_throws ArgumentError ManyToMany() ∘ ManyToOne()

        @test_throws ArgumentError OneToOne() ∘ OneToMany()
        @test_throws ArgumentError OneToMany() ∘ OneToMany()
        @test OneToOne() == ManyToOne() ∘ OneToMany()
        @test OneToMany() == ManyToMany() ∘ OneToMany()

        @test_throws ArgumentError OneToOne() ∘ ManyToMany()
        @test_throws ArgumentError OneToMany() ∘ ManyToMany()
        @test ManyToOne() == ManyToOne() ∘ ManyToMany()
        @test ManyToMany() == ManyToMany() ∘ ManyToMany()
    end
end
