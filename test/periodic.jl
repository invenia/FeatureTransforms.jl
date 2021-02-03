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

        @testset "Matrix" begin
            x = collect(0.:11.)
            M = reshape(x, (6, 2))
            expected = f.(2π .* (x .- 2) ./ 5)
            expected = reshape(expected, (6, 2))

            @testset "dims = $d" for d in (Colon(), 1, 2)
                @test Transforms.apply(M, p; dims=d) ≈ expected atol=1e-15
                @test p(M; dims=d) ≈ expected atol=1e-15

                _M = copy(M)
                Transforms.apply!(_M, p; dims=d)
                @test _M ≈ expected atol=1e-15
            end
        end

        @testset "NamedTuple" begin
            nt = (a = collect(0.:5.), b = collect(6.:11.))
            expected = (a = f.(2π .* (nt.a .- 2) ./ 5), b = f.(2π .* (nt.b .- 2) ./ 5))

            @testset "all cols" begin
                transformed = Transforms.apply(nt, p)
                @test transformed isa NamedTuple{(:a, :b)}
                @test transformed == expected
                @test p(nt) == expected

                _nt = deepcopy(nt)
                Transforms.apply!(_nt, p)
                @test _nt == expected
            end

            @testset "cols = $c" for c in (:a, :b)
                nt_mutated = NamedTuple{(Symbol("$c"), )}((expected[c], ))
                nt_expected = merge(nt, nt_mutated)

                @test Transforms.apply(nt, p; cols=[c]) == nt_expected
                @test p(nt; cols=[c]) == nt_expected

                _nt = deepcopy(nt)
                Transforms.apply!(_nt, p; cols=[c])
                @test _nt == nt_expected
            end
        end

        @testset "AxisArray" begin
            x = collect(0.:11.)
            A = AxisArray(
                reshape(x, (6, 2)),
                foo=["a", "b", "c", "d", "e", "f"],
                bar=["x", "y"]
            )

            expected = f.(2π .* (x .- 2) ./ 5)
            expected = AxisArray(
                reshape(expected, (6, 2)),
                foo=["a", "b", "c", "d", "e", "f"],
                bar=["x", "y"]
            )

            @testset "dims = $d" for d in (Colon(), 1, 2)
                transformed = Transforms.apply(A, p; dims=d)
                @test transformed isa AxisArray
                @test transformed == expected
            end
        end

        @testset "AxisKey" begin
            x = collect(0.:11.)
            A = KeyedArray(
                reshape(x, (6, 2)),
                foo=["a", "b", "c", "d", "e", "f"],
                bar=["x", "y"]
            )

            expected = f.(2π .* (x .- 2) ./ 5)
            expected = KeyedArray(
                reshape(expected, (6, 2)),
                foo=["a", "b", "c", "d", "e", "f"],
                bar=["x", "y"]
            )

            @testset "dims = $d" for d in (Colon(), :foo, :bar)
                transformed = Transforms.apply(A, p; dims=d)
                @test transformed isa KeyedArray
                @test transformed == expected
            end

            _A = copy(A)
            Transforms.apply!(_A, p)
            @test _A == expected
        end

        @testset "DataFrame" begin
            df = DataFrame(:a => collect(0.:5.), :b => collect(6.:11.))
            expected = DataFrame(
                :a => f.(2π .* (df.a .- 2) ./ 5),
                :b => f.(2π .* (df.b .- 2) ./ 5)
            )

            transformed = Transforms.apply(df, p)
            @test transformed isa DataFrame
            @test transformed == expected

            @test Transforms.apply(df, p; cols=[:a]) == DataFrame(
                :a => f.(2π .* (df.a .- 2) ./ 5),
                :b => collect(6.:11.)
            )
            @test Transforms.apply(df, p; cols=[:b]) == DataFrame(
                :a => collect(0.:5.),
                :b => f.(2π .* (df.b .- 2) ./ 5)
            )

            _df = deepcopy(df)
            Transforms.apply!(_df, p)
            @test _df == expected
        end
    end
end
