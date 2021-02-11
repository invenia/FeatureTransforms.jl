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

        @testset "3D array" begin
            M = zeros(Float64, 3, 3, 2)
            M[:, :, 1] = [0.0 -0.5 0.5; 0.0 1.0 2.0; -1.0 0.0 1.0]
            M[:, :, 2] = [1.0 -1.0 0.0; -0.5 0.0 0.5; 2.0 0.0 1.0]

            M_expected = zeros(Float64, 3, 3, 2)
            M_expected[:, :, 1] = [
                -0.381181  -0.952953  0.190591
                -0.381181   0.762362  1.90591
                -1.52472   -0.381181  0.762362
            ]
            M_expected[:, :, 2] = [
                0.762362  -1.52472   -0.381181
                -0.952953  -0.381181   0.190591
                 1.90591   -0.381181   0.762362
            ]

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

            @testset "dims" begin
                @testset "dims = :" begin
                    scaling = MeanStdScaling()
                    d = Colon()

                    @test Transforms.apply(M, scaling; dims=d) ≈ M_expected atol=1e-5
                end

                @testset "dims = 1" begin
                    scaling = MeanStdScaling()
                    d = 1

                    M_1_expected = zeros(Float64, 3, 3, 2)
                    M_1_expected[:, :, 1] = [
                        0.57735  -0.872872  -0.872872
                        0.57735   1.09109    1.09109
                       -1.1547   -0.218218  -0.218218
                    ]
                    M_1_expected[:, :, 2] = [
                        0.132453   -1.1547   -1.0
                        -1.05963    0.57735   0.0
                        0.927173    0.57735   1.0
                    ]

                    @test Transforms.apply(M, scaling; dims=d) ≈ M_1_expected atol=1e-5
                end

                @testset "dims = 2" begin
                    scaling = MeanStdScaling()
                    d = 2

                    M_2_expected = zeros(Float64, 3, 3, 2)
                    M_2_expected[:, :, 1] = [
                         0.0  -1.0  1.0
                        -1.0   0.0  1.0
                        -1.0   0.0  1.0
                    ]
                    M_2_expected[:, :, 2] = [
                         1.0  -1.0  0.0
                        -1.0   0.0  1.0
                         1.0  -1.0  0.0
                    ]

                    @test Transforms.apply(M, scaling; dims=d) ≈ M_2_expected atol=1e-5
                end

                @testset "dims = 3" begin
                    scaling = MeanStdScaling()
                    d = 3

                    M_3_expected = zeros(Float64, 3, 3, 2)
                    M_3_expected[:, :, 1] = [
                       -0.707107    0.707107    0.707107
                        0.707107    0.707107    0.707107
                       -0.707107    0.0         0.0
                    ]
                    M_3_expected[:, :, 2] = [
                        0.707107   -0.707107   -0.707107
                       -0.707107   -0.707107   -0.707107
                        0.707107    0.0         0.0
                    ]

                    @test Transforms.apply(M, scaling; dims=d) ≈ M_3_expected atol=1e-5
                end
            end
        end

        @testset "DataFrame" begin
            scaling = MeanStdScaling()
            df = DataFrame(:a => [0.0, -0.5, 0.5], :b => [1.0, 0.0, 2.0])
            df_expected = DataFrame(
                :a => [-0.559017, -1.118034, 0.0], :b => [0.559017, -0.559017, 1.67705]
            )

            @testset "Non-mutating" begin
                @test ≈(
                    Transforms.apply(df, scaling),
                    [df_expected.a, df_expected.b],
                    atol=1e-5
                )
            end

            @testset "Mutating" begin
                _df = deepcopy(df)
                Transforms.apply!(_df, p)
                @test _df isa DataFrame
                @test _df ≈ df_expected atol=1e-5
            end

            @testset "cols = $c" for c in (:a, :b)
                scaling = MeanStdScaling()
                @test Transforms.apply(df, scaling; cols=[c]) ≈ [[0., -1., 1.]] atol=1e-5
            end
        end
    end
end
