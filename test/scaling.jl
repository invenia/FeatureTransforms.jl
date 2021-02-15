@testset "scaling" begin
    @testset "MeanStdScaling" begin
        @test MeanStdScaling([1., 2., 3.]) isa Transform

        @testset "Vector" begin
            x = [1., 2., 3.]
            expected = [-1., 0., 1.]

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(x)
                @test Transforms.apply(x, scaling) ≈ expected atol=1e-5
                @test scaling(x) ≈ expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(x, expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(x)
                _x = copy(x)
                Transforms.apply!(_x, scaling)
                @test _x ≈ expected atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(x)
                Transforms.apply(x, scaling)

                # Expect scaling parameters to be fixed to the first data applied to
                x2 = [-0.5, 0.5, 0.0]
                expected2 = [-2.5, -1.5, -2.0]
                @test Transforms.apply(x2, scaling) ≈ expected2 atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(x)
                transformed = Transforms.apply(x, scaling)
                inverted = Transforms.apply(transformed, scaling; inverse=true)

                @test transformed ≈ expected atol=1e-5
                @test inverted ≈ x atol=1e-5
            end
        end

        @testset "Matrix" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(M)
                @test Transforms.apply(M, scaling) ≈ M_expected atol=1e-5
                @test scaling(M) ≈ M_expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(M, M_expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(M)
                _M = copy(M)
                Transforms.apply!(_M, scaling)
                @test _M ≈ M_expected atol=1e-5
            end

            @testset "dims = :" begin
                scaling = MeanStdScaling(M; dims=:)
                @test Transforms.apply(M, scaling; dims=:) ≈ M_expected atol=1e-5
            end

            @testset "dims = 1" begin
                scaling = MeanStdScaling(M; dims=1)
                M_1_expected = [0.0 -1.0 1.0; -1.0 0.0 1.0]
                @test Transforms.apply(M, scaling; dims=1) ≈ M_1_expected atol=1e-5
            end

            @testset "dims = 2" begin
                scaling = MeanStdScaling(M; dims=2)
                M_2_expected = [0.0 -0.707107 -0.707107; 0.0 0.707107 0.707107]
                @test Transforms.apply(M, scaling; dims=2) ≈ M_2_expected atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(M; dims=1)
                Transforms.apply(M, scaling; dims=1)

                # Expect scaling parameters to be fixed to the first data applied to
                M2 = [1.0 -2.0 -1.0; 0.5 0.0 0.5]
                M2_expected = [2.0 -4.0 -2.0; -0.5 -1.0 -0.5]

                @test Transforms.apply(M2, scaling; dims=1) ≈ M2_expected atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(M)
                transformed = Transforms.apply(M, scaling)
                inverted = Transforms.apply(transformed, scaling; inverse=true)

                @test transformed ≈ M_expected atol=1e-5
                @test inverted ≈ M atol=1e-5
            end
        end

        @testset "AxisArray" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A = AxisArray(M; foo=["a", "b"], bar=["x", "y", "z"])
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]
            A_expected = AxisArray(M_expected; foo=["a", "b"], bar=["x", "y", "z"])

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(A)
                @test Transforms.apply(A, scaling) ≈ A_expected atol=1e-5
                @test scaling(A) ≈ A_expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(A, A_expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(A)
                _A = copy(A)
                Transforms.apply!(_A, scaling)
                @test _A isa AxisArray
                @test _A ≈ A_expected atol=1e-5
            end

            @testset "dims = :" begin
                scaling = MeanStdScaling(A)
                @test Transforms.apply(A, scaling; dims=:) ≈ A_expected atol=1e-5
            end

            @testset "dims = 1" begin
                scaling = MeanStdScaling(A; dims=1)
                A_1_expected = [0.0 -1.0 1.0; -1.0 0.0 1.0]
                @test Transforms.apply(A, scaling; dims=1) ≈ A_1_expected atol=1e-5
            end

            @testset "dims = 2" begin
                scaling = MeanStdScaling(A; dims=2)
                A_2_expected = [0.0 -0.707107 -0.707107; 0.0 0.707107 0.707107]
                @test Transforms.apply(A, scaling; dims=2) ≈ A_2_expected atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(A; dims=1)
                Transforms.apply(A, scaling; dims=1)

                # Expect scaling parameters to be fixed to the first data applied to
                A2 = [1.0 -2.0 -1.0; 0.5 0.0 0.5]
                A2_expected = [2.0 -4.0 -2.0; -0.5 -1.0 -0.5]

                @test Transforms.apply(A2, scaling; dims=1) ≈ A2_expected atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(A)
                transformed = Transforms.apply(A, scaling)
                inverted = Transforms.apply(transformed, scaling; inverse=true)

                @test transformed ≈ A_expected atol=1e-5
                @test inverted ≈ A atol=1e-5
            end
        end

        @testset "AxisKey" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A = KeyedArray(M; foo=["a", "b"], bar=["x", "y", "z"])
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]
            A_expected = KeyedArray(M_expected; foo=["a", "b"], bar=["x", "y", "z"])

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(A)
                @test Transforms.apply(A, scaling) ≈ A_expected atol=1e-5
                @test scaling(A) ≈ A_expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(A, A_expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(A)
                _A = copy(A)
                Transforms.apply!(_A, scaling)
                @test _A isa KeyedArray
                @test _A ≈ A_expected atol=1e-5
            end

            @testset "dims = :" begin
                scaling = MeanStdScaling(A)
                @test Transforms.apply(A, scaling; dims=:) ≈ A_expected atol=1e-5
            end

            @testset "dims = 1" begin
                scaling = MeanStdScaling(A; dims=1)
                A_1_expected = [0.0 -1.0 1.0; -1.0 0.0 1.0]
                @test Transforms.apply(A, scaling; dims=1) ≈ A_1_expected atol=1e-5
            end

            @testset "dims = 2" begin
                scaling = MeanStdScaling(A; dims=2)
                A_2_expected = [0.0 -0.707107 -0.707107; 0.0 0.707107 0.707107]
                @test Transforms.apply(A, scaling; dims=2) ≈ A_2_expected atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(A; dims=1)
                Transforms.apply(A, scaling; dims=1)

                # Expect scaling parameters to be fixed to the first data applied to
                A2 = [1.0 -2.0 -1.0; 0.5 0.0 0.5]
                A2_expected = [2.0 -4.0 -2.0; -0.5 -1.0 -0.5]

                @test Transforms.apply(A2, scaling; dims=1) ≈ A2_expected atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(A)
                transformed = Transforms.apply(A, scaling)
                inverted = Transforms.apply(transformed, scaling; inverse=true)

                @test transformed ≈ A_expected atol=1e-5
                @test inverted ≈ A atol=1e-5
            end
        end

        @testset "NamedTuple" begin
            nt = (a = [0.0, -0.5, 0.5], b = [1.0, 0.0, 2.0])
            nt_expected = (a = [0.0, -1.0, 1.0], b = [0.0, -1.0, 1.0])

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(nt)
                transformed = Transforms.apply(nt, scaling)
                @test transformed ≈ [nt_expected.a, nt_expected.b] atol=1e-5
                @test scaling(nt) ≈ [nt_expected.a, nt_expected.b] atol=1e-5
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(nt)
                _nt = deepcopy(nt)
                Transforms.apply!(_nt, scaling)
                @test _nt isa NamedTuple{(:a, :b)}
                @test collect(_nt) ≈ collect(nt_expected) atol=1e-5
            end

            @testset "cols = $c" for c in (:a, :b)
                scaling = MeanStdScaling(nt; cols=[c])
                nt_mutated = NamedTuple{(Symbol("$c"), )}((nt_expected[c], ))
                nt_expected_ = merge(nt, nt_mutated)

                transformed = Transforms.apply(nt, scaling; cols=[c])
                @test transformed ≈ [collect(nt_expected_[c])] atol=1e-14
                @test scaling(nt; cols=[c]) ≈ [collect(nt_expected_[c])] atol=1e-14

                _nt = deepcopy(nt)
                Transforms.apply!(_nt, scaling; cols=[c])
                @test _nt isa NamedTuple{(:a, :b)}  # before applying `collect`
                @test collect(_nt) ≈ collect(nt_expected_) atol=1e-14
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(nt)
                Transforms.apply(nt, scaling)

                # Expect scaling parameters to be fixed to the first data applied to
                nt2 = (a = [-1.0, 0.5, 0.0], b = [2.0, 2.0, 1.0])
                nt_expected2 = (a = [-2.0, 1.0, 0.0], b = [1.0, 1.0, 0.0])
                @test ≈(
                    Transforms.apply(nt2, scaling),
                    [nt_expected2.a, nt_expected2.b],
                    atol=1e-5
                )
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(nt)
                transformed = Transforms.apply(nt, scaling)
                transformed = (a = transformed[1], b = transformed[2])
                inverted = Transforms.apply(transformed, scaling; inverse=true)

                @test collect(transformed) ≈ collect(nt_expected) atol=1e-5
                @test inverted ≈ [nt.a, nt.b] atol=1e-5
            end
        end

        @testset "DataFrame" begin
            df = DataFrame(:a => [0.0, -0.5, 0.5], :b => [1.0, 0.0, 2.0])
            df_expected = DataFrame(:a => [0.0, -1.0, 1.0], :b => [0.0, -1.0, 1.0])

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(df)
                transformed = Transforms.apply(df, scaling)
                @test transformed ≈ [df_expected.a, df_expected.b] atol=1e-5
                @test scaling(df) ≈ [df_expected.a, df_expected.b] atol=1e-5
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(df)
                _df = deepcopy(df)
                Transforms.apply!(_df, scaling)
                @test _df isa DataFrame
                @test _df ≈ df_expected atol=1e-5
            end

            @testset "cols = $c" for c in (:a, :b)
                scaling = MeanStdScaling(df; cols=[c])

                transformed = Transforms.apply(df, scaling; cols=[c])
                @test transformed ≈ [df_expected[!, c]] atol=1e-5

                _df = deepcopy(df)
                _df_expected = deepcopy(df)
                _df_expected[!, c] = df_expected[!, c]
                Transforms.apply!(_df, scaling; cols=[c])
                @test _df isa DataFrame
                @test _df ≈ _df_expected atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(df)
                Transforms.apply(df, scaling)

                # Expect scaling parameters to be fixed to the first data applied to
                df2 = DataFrame(:a => [-1.0, 0.5, 0.0], :b => [2.0, 2.0, 1.0])
                df_expected2 = DataFrame(:a => [-2.0, 1.0, 0.0], :b => [1.0, 1.0, 0.0])
                @test ≈(
                    Transforms.apply(df2, scaling),
                    [df_expected2.a, df_expected2.b],
                    atol=1e-5
                )
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(df)
                transformed = Transforms.apply(df, scaling)
                transformed = DataFrame(:a => transformed[1], :b => transformed[2])
                inverted = Transforms.apply(transformed, scaling; inverse=true)

                @test transformed ≈ df_expected atol=1e-5
                @test inverted ≈ [df.a, df.b] atol=1e-5
            end
        end
    end
end
