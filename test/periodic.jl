@testset "periodic" begin
    # Constructors
    @test Periodic(sin, 5) == Periodic(sin, 5, 0)

    @testset "$f" for f in (sin, cos)
        p = Periodic(f, 5, 2)

        @test p isa Transform

        @testset "Vector" begin
            x = collect(0.:11.)
            expected = f.(2π .* (x .- 2) ./ 5)

            @test Transforms.apply(x, p) ≈ expected atol=1e-15
            @test p(x) ≈ expected atol=1e-15

            _x = copy(x)
            Transforms.apply!(_x, p)
            @test _x ≈ expected atol=1e-15
        end
    end
end
