@testset "linear combination" begin

    lc = LinearCombination([1, -1])
    @test lc isa Transform
    @test cardinality(lc) == ManyToOne()

    @testset "default reduces over columns" begin
        M = [1 1; 2 2; 3 5]
        lc = LinearCombination([1, -1, 1])
        @test FeatureTransforms.apply(M, lc) == [2, 4]
        @test lc(M) == [2, 4]
    end

    @testset "dims = :" begin
        M = [1 1; 2 2; 3 5]
        lc = LinearCombination([1, -1, 1])
        @test_deprecated FeatureTransforms.apply(M, lc; dims=:)
    end

    @testset "dimension mismatch" begin
        M = [1 1 1; 2 2 2]
        lc = LinearCombination([1, -1, 1])  # there are only 2 rows
        @test_throws DimensionMismatch FeatureTransforms.apply(M, lc)
    end

    @testset "N-dim Array" begin
        A = reshape(1:27, 3, 3, 3)
        lc = LinearCombination([1, -1, 1])
        @test FeatureTransforms.apply(A, lc) == [2 11 20; 5 14 23; 8 17 26]
        @test lc(A) == [2 11 20; 5 14 23; 8 17 26]
    end
end
