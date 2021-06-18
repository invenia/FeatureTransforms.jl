# TODO: test on rowtable https://github.com/invenia/FeatureTransforms.jl/issues/64
@testset "$TableType" for TableType in (columntable, DataFrame)

    table = TableType((a=[1, 2, 3], b=[4, 5, 6]))

    @test is_transformable(table)

    @testset "apply" begin

        @testset "OneToOne" begin

            T = FakeOneToOneTransform()

            @test isequal(
                FeatureTransforms.apply(table, T),
                TableType((Column1=ones(3), Column2=ones(3)))
            )
            @test isequal(
                FeatureTransforms.apply(table, T; cols=:a),
                TableType((Column1=ones(3), ))
            )
            @test isequal(
                FeatureTransforms.apply(table, T; header=[:x, :y]),
                TableType((x=ones(3), y=ones(3)))
            )
        end

        @testset "OneToMany" begin

            T = FakeOneToManyTransform()

            @test isequal(
                FeatureTransforms.apply(table, T),
                TableType((Column1=ones(3), Column2=ones(3), Column3=ones(3), Column4=ones(3)))
            )
            @test isequal(
                FeatureTransforms.apply(table, T; cols=:a),
                TableType((Column1=ones(3), Column2=ones(3)))
            )
            @test isequal(
                FeatureTransforms.apply(table, T; header=[:x, :y, :p, :q]),
                TableType((x=ones(3), y=ones(3), p=ones(3), q=ones(3)))
            )
        end

        @testset "ManyToOne" begin

            T = FakeManyToOneTransform()

            @test isequal(
                FeatureTransforms.apply(table, T),
                TableType((Column1=ones(3),))
            )
            @test isequal(
                FeatureTransforms.apply(table, T; cols=(:a, :b)),
                TableType((Column1=ones(3),))
            )
            @test isequal(
                FeatureTransforms.apply(table, T; header=[:x]),
                TableType((x=ones(3),))
            )
        end

        @testset "ManyToMany" begin

            T = FakeManyToManyTransform()

            @test isequal(
                FeatureTransforms.apply(table, T),
                TableType((
                    Column1=ones(3), Column2=ones(3), Column3=ones(3),  Column4=ones(3)
                ))
            )
            @test isequal(
                FeatureTransforms.apply(table, T; cols=(:a, :b)),
                TableType((
                        Column1=ones(3), Column2=ones(3), Column3=ones(3),  Column4=ones(3)
                    ))
                )

            @test isequal(
                FeatureTransforms.apply(table, T; header=[:p, :q, :r, :s]),
                TableType((p=ones(3), q=ones(3), r=ones(3), s=ones(3)))
            )
        end

    end

    # TODO: test passing in dims / inds too apply! after addressing
    # https://github.com/invenia/FeatureTransforms.jl/issues/68
    @testset "apply!" begin
        T = FakeOneToOneTransform()

        _table = deepcopy(table)
        FeatureTransforms.apply!(_table, T)
        @test _table == TableType((a=ones(3), b=ones(3)))

        _table = deepcopy(table)
        FeatureTransforms.apply!(_table, T; cols=:a)
        @test _table == TableType((a=[1, 1, 1], b=[4, 5, 6]))
    end

    @testset "apply_append" begin

        @testset "OneToOne" begin

            T = FakeOneToOneTransform()

            @test isequal(
                FeatureTransforms.apply_append(table, T),
                TableType((a=[1, 2, 3], b=[4, 5, 6], Column1=ones(3), Column2=ones(3)))
            )

            @test isequal(
                FeatureTransforms.apply_append(table, T; header=[:x, :y]),
                TableType((a=[1, 2, 3], b=[4, 5, 6], x=ones(3), y=ones(3)))
            )
        end

        @testset "OneToMany" begin

            T = FakeOneToManyTransform()

            @test isequal(
                FeatureTransforms.apply_append(table, T),
                TableType((
                    a=[1, 2, 3], b=[4, 5, 6],
                    Column1=ones(3), Column2=ones(3), Column3=ones(3), Column4=ones(3)
                ))
            )
            @test isequal(
                FeatureTransforms.apply_append(table, T; cols=:a),
                TableType((a=[1, 2, 3], b=[4, 5, 6], Column1=ones(3), Column2=ones(3)))
            )
            @test isequal(
                FeatureTransforms.apply_append(table, T; header=[:x, :y, :p, :q]),
                TableType((
                    a=[1, 2, 3], b=[4, 5, 6], x=ones(3), y=ones(3), p=ones(3), q=ones(3)
                ))
            )
        end

        @testset "ManyToOne" begin

            T = FakeManyToOneTransform()

            @test isequal(
                FeatureTransforms.apply_append(table, T),
                TableType((a=[1, 2, 3], b=[4, 5, 6], Column1=ones(3)))
            )

            @test isequal(
                FeatureTransforms.apply_append(table, T; header=[:x]),
                TableType((a=[1, 2, 3], b=[4, 5, 6], x=ones(3)))
            )
        end

        @testset "ManyToMany" begin

            T = FakeManyToManyTransform()

            @test isequal(
                FeatureTransforms.apply_append(table, T),
                TableType((
                    a=[1, 2, 3], b=[4, 5, 6],
                    Column1=ones(3), Column2=ones(3),
                    Column3=ones(3), Column4=ones(3),
                ))
            )

            @test isequal(
                FeatureTransforms.apply_append(table, T; header=[:p, :q, :r, :s]),
                TableType((
                    a=[1, 2, 3], b=[4, 5, 6], p=ones(3), q=ones(3), r=ones(3), s=ones(3)
                ))
            )
        end

    end

end
