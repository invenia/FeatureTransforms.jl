@testset "is_transformable" begin

    # Test that AbstractArrays and Tables are transformable
    @test is_transformable([1, 2, 3, 4, 5])
    @test is_transformable([1 2 3; 4 5 6])
    @test is_transformable(AxisArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"]))
    @test is_transformable(KeyedArray([1 2 3; 4 5 6], foo=["a", "b"], bar=["x", "y", "z"]))
    @test is_transformable((a = [1, 2, 3], b = [4, 5, 6]))
    @test is_transformable(DataFrame(:a => [1, 2, 3], :b => [4, 5, 6]))

    # Test types that are not transformable
    @test is_transformable(1) == false
    @test is_transformable("string") == false
    @test is_transformable(true) == false
    @test is_transformable(Dict(2 => 3)) == false
end
