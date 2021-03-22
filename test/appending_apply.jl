# TODO - add to appropriate files
@testset "apply!!" begin

    @testset "Arrays" begin

        M = [1 2 3; 4 5 6; 7 8 9]

        @testset "Power" begin
            p = Power(3)

            @testset "dims=1, inds=:" begin
                @test FeatureTransforms.apply!!(M, p; dims=1) == vcat(M, M .^ 3)
            end

            @testset "dims=1, inds=1" begin
                @test FeatureTransforms.apply!!(M, p; dims=1, inds=1) == vcat(M, [1 ,8, 27]')
            end

            @testset "dims=2, inds=:" begin
                @test FeatureTransforms.apply!!(M, p; dims=2) == hcat(M, M .^ 3)
            end

            @testset "dims=2, inds=1" begin
                @test FeatureTransforms.apply!!(M, p; dims=2, inds=1) == hcat(M, [1, 64, 343])
            end

        end

        @testset "LinearCombination" begin
            lc = LinearCombination([1, -1])

            @testset "dims=1" begin
                @test FeatureTransforms.apply!!(M, lc; dims=1, inds=[1, 2]) == vcat(M, [-3, -3, -3]')
            end

            @testset "dims=2" begin
                @test FeatureTransforms.apply!!(M, lc; dims=2, inds=[1, 2]) == hcat(M, [-1, -1, -1])
            end
        end
    end

    @testset "Tables" begin

        nt = (a=[1, 2, 3], b=[4, 5, 6], c=[7, 8, 9])

        @testset "Power" begin
            p = Power(3)

            @testset "cols=:a" begin
                result = FeatureTransforms.apply!!(nt, p; cols=:a, new_cols=:a3)
                @test result == merge(nt, (a3=[1, 8, 27], ))
            end

            @testset "cols=[:a, :b]" begin
                result = FeatureTransforms.apply!!(nt, p; cols=[:a, :b], new_cols=[:a3, :b3])
                @test result == merge(nt, (a3=[1, 8, 27], b3=[64, 125, 216]))
            end

        end

        @testset "LinearCombination" begin
            lc = LinearCombination([1, -1])

            @testset "cols=[:a, :b]" begin
                result = FeatureTransforms.apply!!(nt, lc; cols=[:a, :b], new_cols=[:ab])
                @test result == merge(nt, (ab=[-3, -3, -3],))
            end
        end

    end


end
