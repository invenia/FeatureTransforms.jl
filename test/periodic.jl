@testset "periodic" begin
    period = 5
    phase_shift = 2

    @testset for periodic_function in [cos, sin]
        p = Periodic(periodic_function, period, phase_shift)

        @test p isa Transform

        @testset "Vector" begin
            x = [1., 2., 3., 4., 5.]
            expected = periodic_function.((2π / period) .* x .+ phase_shift)

            @test Transforms.apply(x, p) == expected
            @test p(x) == expected

            _x = copy(x)
            Transforms.apply!(_x, p)
            @test _x == expected
        end
    end

end
