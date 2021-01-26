@testset "power" begin

    p = Power(3)
    @test p isa Transformation

    @testset "vector of reals" begin
        x = [1, 2, 3, 4, 5]
        expected = [1, 8, 27, 64, 125]

        @test transform(x, p) == expected
        @test p(x) == expected

        _x = copy(x)
        transform!(_x, p)
        @test _x == expected
    end

    @testset "matrix of reals" begin
        M = [1 2 3; 4 5 6]
        expected = [1 8 27; 64 125 216]

        @test transform(M, p) == expected
        @test p(M) == expected

        _M = copy(M)
        transform!(_M, p)
        @test _M == expected
    end

    @testset "NamedTuple of reals" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = (a = [1, 8, 27], b = [64, 125, 216])

        @test transform(nt, p) == expected
        @test p(nt) == expected

        _nt = deepcopy(nt)
        transform!(_nt, p)
        @test _nt == expected
    end

end
