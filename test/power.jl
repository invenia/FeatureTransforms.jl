@testset "power" begin

    p = Power(3)
    @test p isa Transformation

    @testset "vector of integers" begin
        x = [1, 2, 3, 4, 5]
        expected = [1, 8, 27, 64, 125]

        @test transform(x, p) == expected
        @test p(x) == expected

        _x = copy(x)
        transform!(_x, p)
        @test _x == expected
    end

    @testset "matrix of integers" begin
        M = [1 2 3; 4 5 6]
        expected = [1 8 27; 64 125 216]

        @testset "dims = $d" for d in (Colon(), 1, 2)

            @test transform(M, p; dims=d) == expected
            @test p(M; dims=d) == expected

            _M = copy(M)
            transform!(_M, p; dims=d)
            @test _M == expected
        end
    end

    @testset "NamedTuple of integers" begin
        nt = (a = [1, 2, 3], b = [4, 5, 6])
        expected = (a = [1, 8, 27], b = [64, 125, 216])

        @testset "all cols" begin
            @test transform(nt, p) == expected
            @test p(nt) == expected

            _nt = deepcopy(nt)
            transform!(_nt, p)
            @test _nt == expected
        end

        @testset "cols = $c" for c in (:a, :b)
            nt_mutated = NamedTuple{(Symbol("$c"), )}((expected[c], ))
            nt_expected = merge(nt, nt_mutated)

            @test transform(nt, p; cols=[c]) == nt_expected
            @test p(nt; cols=[c]) == nt_expected

            _nt = deepcopy(nt)
            transform!(_nt, p; cols=[c])
            @test _nt == nt_expected
        end
    end

end
