@testset "scaling" begin
    @testset "MeanStdScaling" begin
        scaling = MeanStdScaling()

        @test scaling isa Transform

        @testset "Vector" begin
            x = [1., 2., 3.]
            expected = [-1., 0., 1.]

            @testset "Non-mutating" begin
                scaling = MeanStdScaling()
                @test Transforms.apply(x, scaling) ≈ expected atol=1e-5
                @test scaling(x) ≈ expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(x, expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling()
                _x = copy(x)
                Transforms.apply!(_x, scaling)
                @test _x ≈ expected atol=1e-5
            end
        end

        @testset "Matrix" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]

            @testset "Non-mutating" begin
                scaling = MeanStdScaling()
                @test Transforms.apply(M, scaling) ≈ M_expected atol=1e-5
                @test scaling(M) ≈ M_expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(M, M_expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling()
                _M = copy(M)
                Transforms.apply!(_M, scaling)
                @test _M ≈ M_expected atol=1e-5
            end

            @testset "dims = :" begin
                scaling = MeanStdScaling()
                @test Transforms.apply(M, scaling; dims=:) ≈ M_expected atol=1e-5
            end

            @testset "dims = 1" begin
                scaling = MeanStdScaling()
                M_1_expected = [0.0 -1.0 1.0; -1.0 0.0 1.0]
                @test Transforms.apply(M, scaling; dims=1) ≈ M_1_expected atol=1e-5
            end

            @testset "dims = 2" begin
                scaling = MeanStdScaling()
                M_2_expected = [0.0 -0.707107 -0.707107; 0.0 0.707107 0.707107]
                @test Transforms.apply(M, scaling; dims=2) ≈ M_2_expected atol=1e-5
            end
        end

        @testset "DataFrame" begin
            scaling = MeanStdScaling()
            df = DataFrame(:a => [0.0, -0.5, 0.5], :b => [1.0, 0.0, 2.0])
            df_expected = DataFrame(:a => [0.0, -1.0, 1.0], :b => [0.0, -1.0, 1.0])

            @testset "Non-mutating" begin
                @test ≈(
                    Transforms.apply(df, scaling),
                    [df_expected.a, df_expected.b],
                    atol=1e-5
                )
            end

            @testset "Mutating" begin
                _df = deepcopy(df)
                Transforms.apply!(_df, scaling)
                @test _df isa DataFrame
                @test _df ≈ df_expected atol=1e-5
            end

            @testset "cols = :a" begin
                scaling = MeanStdScaling()

                @test Transforms.apply(df, scaling; cols=[:a]) ≈ [df_expected.a] atol=1e-5

                _df = deepcopy(df)
                _df_expected = DataFrame(:a => df_expected.a, :b => df.b)
                Transforms.apply!(_df, scaling; cols=[:a])
                @test _df isa DataFrame
                @test _df ≈ _df_expected atol=1e-5
            end

            @testset "cols = :b" begin
                scaling = MeanStdScaling()

                @test Transforms.apply(df, scaling; cols=[:b]) ≈ [df_expected.b] atol=1e-5

                _df = deepcopy(df)
                _df_expected = DataFrame(:a => df.a, :b => df_expected.b)
                Transforms.apply!(_df, scaling; cols=[:b])
                @test _df isa DataFrame
                @test _df ≈ _df_expected atol=1e-5
            end
        end
    end
end
