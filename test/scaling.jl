@testset "scaling" begin

    @testset "IdentityScaling" begin
        scaling = IdentityScaling()
        @test scaling isa Transform

        @testset "Vector" begin
            x = [1., 2., 3.]
            expected = [1., 2., 3.]

            @test FeatureTransforms.apply(x, scaling) == expected
            @test scaling(x) == expected

            @testset "Mutating" begin
                _x = copy(x)
                FeatureTransforms.apply!(_x, scaling)
                @test _x == expected
            end

            @testset "dims" begin
                @test FeatureTransforms.apply(x, scaling; dims=1) == expected
                @test_throws BoundsError FeatureTransforms.apply(expected, scaling; dims=2)
            end

            @testset "inds" begin
                @test FeatureTransforms.apply(x, scaling; inds=[2, 3]) == [2., 3.]
                @test FeatureTransforms.apply(x, scaling; dims=:, inds=[2, 3]) == [2., 3.]
                @test FeatureTransforms.apply(x, scaling; dims=1, inds=[2, 3]) == [2., 3.]
            end

            @testset "Inverse" begin
                @test FeatureTransforms.apply(x, scaling; inverse=true) == expected
            end
        end

        @testset "Matrix" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            M_expected = [0.0 -0.5 0.5; 0.0 1.0 2.0]

           @test FeatureTransforms.apply(M, scaling) == M_expected

            @testset "Mutating" begin
                _M = copy(M)
                FeatureTransforms.apply!(_M, scaling)
                @test _M == M_expected
            end

            @testset "dims = $d" for d in (Colon(), 1, 2)
                @test FeatureTransforms.apply(M, scaling; dims=d) == M_expected
            end

            @testset "inds" begin
                @test FeatureTransforms.apply(M, scaling; inds=[2, 3]) == [0.0, -0.5]
                @test FeatureTransforms.apply(M, scaling; dims=:, inds=[2, 3]) == [0.0, -0.5]
                @test FeatureTransforms.apply(M, scaling; dims=1, inds=[2]) == [0.0 1.0 2.0]
                @test FeatureTransforms.apply(M, scaling; dims=2, inds=[2]) == reshape([-0.5; 1.0], 2, 1)
            end

            @testset "Inverse" begin
                @test FeatureTransforms.apply(M, scaling; inverse=true) == M_expected
            end
        end

        @testset "AxisArray" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A = AxisArray(M; foo=["a", "b"], bar=["x", "y", "z"])
            M_expected = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A_expected = AxisArray(M_expected; foo=["a", "b"], bar=["x", "y", "z"])

            @test FeatureTransforms.apply(A, scaling) == A_expected

            @testset "Mutating" begin
                _A = copy(A)
                FeatureTransforms.apply!(_A, scaling)
                @test _A isa AxisArray
                @test _A == A_expected
            end

            @testset "dims = $d" for d in (Colon(), 1, 2)
                @test FeatureTransforms.apply(M, scaling; dims=d) == A_expected
            end

            @testset "inds" begin
                @test FeatureTransforms.apply(A, scaling; inds=[2, 3]) == [0.0, -0.5]
                @test FeatureTransforms.apply(A, scaling; dims=:, inds=[2, 3]) == [0.0, -0.5]
                @test FeatureTransforms.apply(A, scaling; dims=1, inds=[2]) == [0.0 1.0 2.0]
                @test FeatureTransforms.apply(A, scaling; dims=2, inds=[2]) == reshape([-0.5; 1.0], 2, 1)
            end

            @testset "Inverse" begin
                @test FeatureTransforms.apply(A, scaling; inverse=true) == A_expected
            end
        end

        @testset "AxisKey" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A = KeyedArray(M; foo=["a", "b"], bar=["x", "y", "z"])
            M_expected = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A_expected = KeyedArray(M_expected; foo=["a", "b"], bar=["x", "y", "z"])

            @test FeatureTransforms.apply(A, scaling) == A_expected

            @testset "Mutating" begin
                _A = copy(A)
                FeatureTransforms.apply!(_A, scaling)
                @test _A isa KeyedArray
                @test _A == A_expected
            end

            @testset "dims = $d" for d in (Colon(), 1, 2)
                @test FeatureTransforms.apply(M, scaling; dims=d) == A_expected
            end

            @testset "inds" begin
                @test FeatureTransforms.apply(A, scaling; inds=[2, 3]) == [0.0, -0.5]
                @test FeatureTransforms.apply(A, scaling; dims=:, inds=[2, 3]) == [0.0, -0.5]
                @test FeatureTransforms.apply(A, scaling; dims=1, inds=[2]) == [0.0 1.0 2.0]
                @test FeatureTransforms.apply(A, scaling; dims=2, inds=[2]) == reshape([-0.5; 1.0], 2, 1)
            end

            @testset "Inverse" begin
                @test FeatureTransforms.apply(A, scaling; inverse=true) == A_expected
            end
        end

        @testset "NamedTuple" begin
            nt = (a = [0.0, -0.5, 0.5], b = [1.0, 0.0, 2.0])
            expected = (Column1 = [0.0, -0.5, 0.5], Column2 = [1.0, 0.0, 2.0])

           @test FeatureTransforms.apply(nt, scaling) == expected

            @testset "Mutating" begin
                _nt = deepcopy(nt)
                FeatureTransforms.apply!(_nt, scaling)
                @test _nt isa NamedTuple{(:a, :b)}
                @test _nt == nt
            end

            @testset "cols = :a" begin
                exp = (Column1=nt.a, )
                @test FeatureTransforms.apply(nt, scaling; cols=[:a]) == exp
                @test FeatureTransforms.apply(nt, scaling; cols=:a) == exp
            end

            @testset "Inverse" begin
                @test FeatureTransforms.apply(nt, scaling; inverse=true) == expected
            end
        end

        @testset "DataFrame" begin
            df = DataFrame(:a => [0.0, -0.5, 0.5], :b => [1.0, 0.0, 2.0])
            df_expected = DataFrame(:Column1 => [0.0, -0.5, 0.5], :Column2 => [1.0, 0.0, 2.0])

            @test FeatureTransforms.apply(df, scaling) == df_expected

            @testset "Mutating" begin
                _df = deepcopy(df)
                FeatureTransforms.apply!(_df, scaling)
                @test _df isa DataFrame
                @test _df == df
            end

            @testset "cols = :a" begin
                expected = DataFrame(:Column1=>df.a)
                @test FeatureTransforms.apply(df, scaling; cols=[:a]) == expected
                @test FeatureTransforms.apply(df, scaling; cols=:a) == expected
            end

            @testset "Inverse" begin
                @test FeatureTransforms.apply(df, scaling; inverse=true) == df_expected
            end
        end
    end

    @testset "MeanStdScaling" begin
        @testset "Constructor" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            nt = (a = [0.0, -0.5, 0.5], b = [1.0, 0.0, 2.0])

            @testset "simple" for x in (M, nt)
                x_copy = deepcopy(x)
                scaling = MeanStdScaling(x)
                @test scaling isa Transform
                @test x == x_copy  # data is not mutated
                # constructor uses all data by default
                @test scaling.μ == 0.5
                @test scaling.σ ≈ 0.89443 atol=1e-5
            end

            @testset "use certain slices to compute statistics" begin
                @testset "Array" begin
                    scaling = MeanStdScaling(M; dims=1, inds=[2])
                    @test scaling.μ == 1.0
                    @test scaling.σ == 1.0
                end

                @testset "Table" begin
                    scaling = MeanStdScaling(nt; cols=:a)
                    @test scaling.μ == 0.0
                    @test scaling.σ == 0.5
                end
            end
        end

        @testset "Vector" begin
            x = [1., 2., 3.]
            expected = [-1., 0., 1.]

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(x)
                @test FeatureTransforms.apply(x, scaling) ≈ expected atol=1e-5
                @test scaling(x) ≈ expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(x, expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(x)
                _x = copy(x)
                FeatureTransforms.apply!(_x, scaling)
                @test _x ≈ expected atol=1e-5
            end

            @testset "dims" begin
                scaling = MeanStdScaling(x; dims=1)
                @test FeatureTransforms.apply(x, scaling; dims=1) == expected
                @test_throws BoundsError FeatureTransforms.apply(x, scaling; dims=2)
            end

            @testset "inds" begin
                scaling = MeanStdScaling(x)
                @test FeatureTransforms.apply(x, scaling; inds=[2, 3]) == [0., 1.]
                @test FeatureTransforms.apply(x, scaling; dims=:, inds=[2, 3]) == [0., 1.]

                scaling = MeanStdScaling(x; dims=1)
                @test FeatureTransforms.apply(x, scaling; dims=1, inds=[2, 3]) == [0., 1.]
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(x)
                FeatureTransforms.apply(x, scaling)

                # Expect scaling parameters to be fixed to the first data applied to
                @test FeatureTransforms.apply([-0.5, 0.5, 0.0], scaling) ≈ [-2.5, -1.5, -2.0] atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(x)
                transformed = FeatureTransforms.apply(x, scaling)

                @test transformed ≈ expected atol=1e-5
                @test FeatureTransforms.apply(transformed, scaling; inverse=true) ≈ x atol=1e-5
            end
        end

        @testset "Matrix" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(M)
                @test FeatureTransforms.apply(M, scaling) ≈ M_expected atol=1e-5
                @test scaling(M) ≈ M_expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(M, M_expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(M)
                _M = copy(M)
                FeatureTransforms.apply!(_M, scaling)
                @test _M ≈ M_expected atol=1e-5
            end

            @testset "dims = :" begin
                scaling = MeanStdScaling(M; dims=:)
                @test FeatureTransforms.apply(M, scaling; dims=:) ≈ M_expected atol=1e-5
            end

            @testset "dims = 1" begin
                scaling = MeanStdScaling(M; dims=1)
                @test FeatureTransforms.apply(M, scaling; dims=1) ≈ M_expected atol=1e-5
            end

            @testset "dims = 2" begin
                scaling = MeanStdScaling(M; dims=2)
                @test FeatureTransforms.apply(M, scaling; dims=2) ≈ M_expected atol=1e-5
            end

            @testset "inds" begin
                scaling = MeanStdScaling(M)
                @test FeatureTransforms.apply(M, scaling; inds=[2, 3]) ≈ [-0.559017, -1.11803] atol=1e-5
                @test FeatureTransforms.apply(M, scaling; dims=:, inds=[2, 3]) ≈ [-0.559017, -1.11803] atol=1e-5

                scaling = MeanStdScaling(M; dims=1, inds=[2])
                @test FeatureTransforms.apply(M, scaling; dims=1, inds=[2]) ≈ [-1.0 0.0 1.0] atol=1e-5

                scaling = MeanStdScaling(M; dims=2, inds=[2])
                @test FeatureTransforms.apply(M, scaling; dims=2, inds=[2]) ≈ [-0.70711 0.70711]' atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(M; dims=2)
                new_M = [1.0 -2.0 -1.0; 0.5 0.0 0.5]
                @test M !== new_M
                # Expect scaling parameters to be fixed to the first data applied to
                expected_reapply = [0.559017 -2.79508 -1.67705; 0.0 -0.55901 0.0]
                @test FeatureTransforms.apply(new_M, scaling; dims=2) ≈ expected_reapply atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(M)
                transformed = FeatureTransforms.apply(M, scaling)

                @test transformed ≈ M_expected atol=1e-5
                @test FeatureTransforms.apply(transformed, scaling; inverse=true) ≈ M atol=1e-5
            end
        end

        @testset "AxisArray" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A = AxisArray(M; foo=["a", "b"], bar=["x", "y", "z"])
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]
            A_expected = AxisArray(M_expected; foo=["a", "b"], bar=["x", "y", "z"])

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(A)
                @test FeatureTransforms.apply(A, scaling) ≈ A_expected atol=1e-5
                @test scaling(A) ≈ A_expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(A, A_expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(A)
                _A = copy(A)
                FeatureTransforms.apply!(_A, scaling)
                @test _A isa AxisArray
                @test _A ≈ A_expected atol=1e-5
            end

            @testset "dims = :" begin
                scaling = MeanStdScaling(A, dims=:)
                @test FeatureTransforms.apply(A, scaling; dims=:) ≈ A_expected atol=1e-5
            end

            @testset "dims = 1" begin
                scaling = MeanStdScaling(A; dims=1)
                @test FeatureTransforms.apply(A, scaling; dims=1) ≈ A_expected atol=1e-5
            end

            @testset "dims = 2" begin
                scaling = MeanStdScaling(A; dims=2)
                @test FeatureTransforms.apply(A, scaling; dims=2) ≈ A_expected atol=1e-5
            end

            @testset "inds" begin
                scaling = MeanStdScaling(A)
                @test FeatureTransforms.apply(A, scaling; inds=[2, 3]) ≈ [-0.559017, -1.11803] atol=1e-5
                @test FeatureTransforms.apply(A, scaling; dims=:, inds=[2, 3]) ≈ [-0.559017, -1.11803] atol=1e-5

                scaling = MeanStdScaling(A; dims=1, inds=[2])
                @test FeatureTransforms.apply(A, scaling; dims=1, inds=[2]) ≈ [-1.0 0.0 1.0] atol=1e-5

                scaling = MeanStdScaling(A; dims=2, inds=[2])
                @test FeatureTransforms.apply(A, scaling; dims=2, inds=[2]) ≈ [-0.70711 0.70711]' atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(A)
                FeatureTransforms.apply(A, scaling)

                M_new = [1.0 -2.0 -1.0; 0.5 0.0 0.5]
                A_new = AxisArray(M_new; foo=["a", "b"], bar=["x", "y", "z"])
                @test A_new != A

                # Expect scaling parameters to be fixed to the first data applied to
                expected_reapply = [0.559017 -2.79508 -1.67705; 0.0 -0.55901 0.0]
                @test FeatureTransforms.apply(A_new, scaling) ≈ expected_reapply atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(A)
                transformed = FeatureTransforms.apply(A, scaling)

                @test transformed ≈ A_expected atol=1e-5
                @test FeatureTransforms.apply(transformed, scaling; inverse=true) ≈ A atol=1e-5
            end
        end

        @testset "AxisKey" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            A = KeyedArray(M; foo=["a", "b"], bar=["x", "y", "z"])
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]
            A_expected = KeyedArray(M_expected; foo=["a", "b"], bar=["x", "y", "z"])

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(A)
                @test FeatureTransforms.apply(A, scaling) ≈ A_expected atol=1e-5
                @test scaling(A) ≈ A_expected atol=1e-5

                # Test the transform was not mutating
                @test !isapprox(A, A_expected; atol=1e-5)
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(A)
                _A = copy(A)
                FeatureTransforms.apply!(_A, scaling)
                @test _A isa KeyedArray
                @test _A ≈ A_expected atol=1e-5
            end

            @testset "dims = :" begin
                scaling = MeanStdScaling(A, dims=:)
                @test FeatureTransforms.apply(A, scaling; dims=:) ≈ A_expected atol=1e-5
            end

            @testset "dims = 1" begin
                scaling = MeanStdScaling(A; dims=1)
                @test FeatureTransforms.apply(A, scaling; dims=1) ≈ A_expected atol=1e-5
            end

            @testset "dims = 2" begin
                scaling = MeanStdScaling(A; dims=2)
                @test FeatureTransforms.apply(A, scaling; dims=2) ≈ A_expected atol=1e-5
            end

            @testset "inds" begin
                scaling = MeanStdScaling(A)
                @test FeatureTransforms.apply(A, scaling; inds=[2, 3]) ≈ [-0.559017, -1.11803] atol=1e-5
                @test FeatureTransforms.apply(A, scaling; dims=:, inds=[2, 3]) ≈ [-0.559017, -1.11803] atol=1e-5

                scaling = MeanStdScaling(A; dims=1, inds=[2])
                @test FeatureTransforms.apply(A, scaling; dims=1, inds=[2]) ≈ [-1.0 0.0 1.0] atol=1e-5

                scaling = MeanStdScaling(A; dims=2, inds=[2])
                @test FeatureTransforms.apply(A, scaling; dims=2, inds=[2]) ≈ [-0.70711 0.70711]' atol=1e-5
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(A; dims=2)
                FeatureTransforms.apply(A, scaling; dims=2)

                M_new = [1.0 -2.0 -1.0; 0.5 0.0 0.5]
                A_new = KeyedArray(M_new; foo=["a", "b"], bar=["x", "y", "z"])
                @test A_new != A

                # Expect scaling parameters to be fixed to the first data applied to
                expected_reapply = [0.559017 -2.79508 -1.67705; 0.0 -0.55901 0.0]
                @test FeatureTransforms.apply(A_new, scaling; dims=2) ≈ expected_reapply atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(A)
                transformed = FeatureTransforms.apply(A, scaling)

                @test transformed ≈ A_expected atol=1e-5
                @test FeatureTransforms.apply(transformed, scaling; inverse=true) ≈ A atol=1e-5
            end
        end

        @testset "NamedTuple" begin
            nt = (a = [0.0, -0.5, 0.5], b = [1.0, 0.0, 2.0])

            @testset "Non-mutating" begin
                expected = [[-0.55902, -1.11803, 0.0], [0.55902, -0.55902, 1.67705]]

                scaling = MeanStdScaling(nt)
                result = FeatureTransforms.apply(nt, scaling)
                @test result isa NamedTuple{(:Column1, :Column2)}
                @test collect(result) ≈ expected atol=1e-5

                result = scaling(nt)
                @test result isa NamedTuple{(:Column1, :Column2)}
                @test collect(result) ≈ expected atol=1e-5
            end

            @testset "Mutating" begin
                expected = [[-0.55902, -1.11803, 0.0], [0.55902, -0.55902, 1.67705]]
                scaling = MeanStdScaling(nt)
                _nt = deepcopy(nt)
                FeatureTransforms.apply!(_nt, scaling)
                @test _nt isa NamedTuple{(:a, :b)}
                @test collect(_nt) ≈ expected atol=1e-5
            end

            @testset "cols = :a" begin
                scaling = MeanStdScaling(nt; cols=:a)

                expected = (Column1 = [0.0, -1.0, 1.0], )
                @test FeatureTransforms.apply(nt, scaling; cols=:a) == expected
                @test FeatureTransforms.apply(nt, scaling; cols=[:a]) == expected
                @test scaling(nt; cols=:a) == expected

                _nt = deepcopy(nt)
                FeatureTransforms.apply!(_nt, scaling; cols=:a)
                @test _nt isa NamedTuple{(:a, :b)}  # before applying `collect`
                @test _nt == (a=[0.0, -1.0, 1.0], b=[1.0, 0.0, 2.0])
            end

            @testset "Re-apply" begin
                scaling = MeanStdScaling(nt)

                # Expect scaling parameters to be fixed to the first data applied to
                nt2 = (a = [-1.0, 0.5, 0.0], b = [2.0, 2.0, 1.0])
                @test nt !== nt2
                expected2 = [[-1.67705, 0.0, -0.55902], [1.67705, 1.67705, 0.55902]]
                @test collect(FeatureTransforms.apply(nt2, scaling)) ≈ expected2 atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(nt)
                transformed = FeatureTransforms.apply(nt, scaling)
                expected_inverse = (Column1 = [0.0, -0.5, 0.5], Column2 = [1.0, 0.0, 2.0])
                inverted = FeatureTransforms.apply(transformed, scaling; inverse=true)
                @test expected_inverse == inverted
            end
        end

        @testset "DataFrame" begin
            df = DataFrame(:a => [0.0, -0.5, 0.5], :b => [1.0, 0.0, 2.0])

            df_expected = DataFrame(
                :Column1 => [-0.55902, -1.11803, 0.0],
                :Column2 => [0.55902, -0.55902, 1.67705],
            )

            @testset "Non-mutating" begin
                scaling = MeanStdScaling(df)
                @test FeatureTransforms.apply(df, scaling) ≈ df_expected atol=1e-5
                @test scaling(df) ≈ df_expected atol=1e-5
            end

            @testset "Mutating" begin
                scaling = MeanStdScaling(df)
                _df = deepcopy(df)
                FeatureTransforms.apply!(_df, scaling)
                @test _df isa DataFrame
                @test isapprox(
                    _df,
                    DataFrame(:a => [-0.55902, -1.11803, 0.0], :b => [0.55902, -0.55902, 1.67705]),
                    atol=1e-5
                )
            end

            @testset "cols = :a" begin
                scaling = MeanStdScaling(df; cols=:a)

                @test isequal(
                    FeatureTransforms.apply(df, scaling; cols=:a),
                    DataFrame(:Column1 => [0.0, -1.0, 1.0]),
                )

                _df = deepcopy(df)
                FeatureTransforms.apply!(_df, scaling; cols=:a)
                @test _df isa DataFrame
                @test _df == DataFrame(:a => [0.0, -1.0, 1.0], :b => [1.0, 0.0, 2.0])
            end

            @testset "Re-apply" begin
                # Expect scaling parameters to be fixed to the first data applied to
                df2 = DataFrame(:a => [-1.0, 0.5, 0.0], :b => [2.0, 2.0, 1.0])
                @test df !== df2

                scaling = MeanStdScaling(df)

                df_expected2 = DataFrame(
                    :Column1 => [-1.67705, 0.0, -0.55902],
                    :Column2 => [1.67705, 1.67705, 0.55902],
                )
                @test FeatureTransforms.apply(df2, scaling) ≈ df_expected2 atol=1e-5
            end

            @testset "Inverse" begin
                scaling = MeanStdScaling(df)
                transformed = FeatureTransforms.apply(df, scaling)

                expected_inverse = DataFrame(:Column1=>df.a, :Column2=>df.b)
                inverted = FeatureTransforms.apply(transformed, scaling; inverse=true)
                @test inverted == expected_inverse
            end
        end

        @testset "Zero std" begin
            x = ones(Float64, 3)
            expected = zeros(Float64, 3)

            scaling = MeanStdScaling(x)

            @test FeatureTransforms.apply(x, scaling) == expected  # default `eps`
            @test FeatureTransforms.apply(x, scaling; eps=1) == expected
            @test all(isnan.(FeatureTransforms.apply(x, scaling; eps=0)))  # 0/0
        end
    end
end
