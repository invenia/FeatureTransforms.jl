@testset "scaling" begin

    @testset "IdentityScaling" begin
        scaling = IdentityScaling()
        @test scaling isa Transform
        @test cardinality(scaling) == OneToOne()

        @testset "Arguments do nothing" begin
            @test IdentityScaling(123) == IdentityScaling()
            @test IdentityScaling([1, 2, 3]) == IdentityScaling()
        end
    end

    @testset "MeanStdScaling" begin
        @testset "Constructor" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            nt = (a = [0.0, -0.5, 0.5], b = [1.0, 0.0, 2.0])

            @testset "simple" for x in (M, nt)
                x_copy = deepcopy(x)
                scaling = MeanStdScaling(x)
                @test cardinality(scaling) == OneToOne()
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

        @testset "Re-apply" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            scaling = MeanStdScaling(M; dims=2)
            new_M = [1.0 -2.0 -1.0; 0.5 0.0 0.5]
            @test M !== new_M
            # Expect scaling parameters to be fixed to the first data applied to
            expected_reapply = [0.559017 -2.79508 -1.67705; 0.0 -0.55901 0.0]
            @test FeatureTransforms.apply(new_M, scaling; dims=2) ≈ expected_reapply atol=1e-5
        end

        @testset "Inverse" begin
            M = [0.0 -0.5 0.5; 0.0 1.0 2.0]
            M_expected = [-0.559017 -1.11803 0.0; -0.559017 0.559017 1.67705]
            scaling = MeanStdScaling(M)
            transformed = FeatureTransforms.apply(M, scaling)

            @test transformed ≈ M_expected atol=1e-5
            @test FeatureTransforms.apply(transformed, scaling; inverse=true) ≈ M atol=1e-5
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
