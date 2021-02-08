@testset "temporal" begin

    hod = HoD()
    @test hod isa Transform

    @testset "Vector" begin
        x = collect(DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0))
        # Expected result is an hour a day starting and ending on the 9th hour inclusive,
        # with 126 full days in the middle
        expected = [9:23..., repeat(0:23, 126)..., 0:9...]

        @test Transforms.apply(x, hod) == expected
        @test hod(x) == expected

        # Test the tranform was not mutating
        @test x != expected

        @testset "StepRange" begin
            x = DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 5, 7, 9, 0)
            @test Transforms.apply(x, hod) == expected
            @test hod(x) == expected
        end

        @testset "DST" begin
            x = ZonedDateTime(2020, 3, 7, 9, 0, tz"America/New_York"):Hour(1):ZonedDateTime(2020, 3, 8, 9, 0, tz"America/New_York")

            # expected result skips the DST transition hour of 2
            expected = [9:23..., 0, 1, 3:9...]

            @test Transforms.apply(x, hod) == expected
            @test hod(x) == expected
        end
    end

    @testset "Matrix" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 3, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 11, 0)
        ]
        M = reshape(x, 3, 2)
        expected = [1 9; 2 10; 3 11]

        @test Transforms.apply(M, hod) == expected
        @test hod(M) == expected

        # Test the tranform was not mutating
        @test M != expected

        @testset "dims = :" begin
            d = Colon()
            @test Transforms.apply(M, hod; dims=d) == expected
            @test hod(M; dims=d) == expected

            # Test the tranform was not mutating
            @test M != expected
        end

        @testset "dims = 1" begin
            d = 1
            expected = [[1, 9], [2, 10], [3, 11]]
            @test Transforms.apply(M, hod; dims=d) == expected
            @test hod(M; dims=d) == expected

            # Test the tranform was not mutating
            @test M != expected
        end

        @testset "dims = 2" begin
            d = 2
            expected = [[1, 2, 3], [9, 10, 11]]
            @test Transforms.apply(M, hod; dims=d) == expected
            @test hod(M; dims=d) == expected

            # Test the tranform was not mutating
            @test M != expected
        end
    end

    @testset "AxisArray" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 2, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 10, 0);
            DateTime(2020, 1, 1, 10, 0):Hour(1):DateTime(2020, 1, 1, 11, 0)
        ]
        M = reshape(x, 2, 3)
        A = AxisArray(M, foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 9 10; 2 10 11]

        @test Transforms.apply(A, hod) == expected
        @test hod(A) == expected

        @testset "dims = :" begin
            d = Colon()
            @test Transforms.apply(A, hod; dims=d) == expected
            @test hod(A; dims=d) == expected
        end

        @testset "dims = 1" begin
            d = 1
            expected = [[1, 9, 10], [2, 10, 11]]
            @test Transforms.apply(A, hod; dims=d) == expected
            @test hod(A; dims=d) == expected
        end

        @testset "dims = 2" begin
            d = 2
            expected = [[1, 2], [9, 10], [10, 11]]
            @test Transforms.apply(A, hod; dims=d) == expected
            @test hod(A; dims=d) == expected
        end
    end

    @testset "AxisKey" begin
        x = [
            DateTime(2020, 1, 1, 1, 0):Hour(1):DateTime(2020, 1, 1, 2, 0);
            DateTime(2020, 1, 1, 9, 0):Hour(1):DateTime(2020, 1, 1, 10, 0);
            DateTime(2020, 1, 1, 10, 0):Hour(1):DateTime(2020, 1, 1, 11, 0)
        ]
        M = reshape(x, 2, 3)
        A = KeyedArray(M, foo=["a", "b"], bar=["x", "y", "z"])
        expected = [1 9 10; 2 10 11]

        @test Transforms.apply(A, hod) == expected
        @test hod(A) == expected

        @testset "dims = :" begin
            d = Colon()
            @test Transforms.apply(A, hod; dims=d) == expected
            @test hod(A; dims=d) == expected
        end

        @testset "dims = 1" begin
            d = 1
            expected = [[1, 9, 10], [2, 10, 11]]
            @test Transforms.apply(A, hod; dims=d) == expected
            @test hod(A; dims=d) == expected
        end

        @testset "dims = 2" begin
            d = 2
            expected = [[1, 2], [9, 10], [10, 11]]
            @test Transforms.apply(A, hod; dims=d) == expected
            @test hod(A; dims=d) == expected
        end
    end

    @testset "NamedTuple" begin
        nt = (
            a = DateTime(2020, 1, 1, 0, 0):Hour(1):DateTime(2020, 1, 1, 2, 0),
            b = DateTime(2020, 1, 1, 3, 0):Hour(1):DateTime(2020, 1, 1, 5, 0)
        )
        expected = [[0, 1, 2], [3, 4, 5]]

        @testset "all cols" begin
            @test Transforms.apply(nt, hod) == expected
            @test hod(nt) == expected

            # Test the tranform was not mutating
            @test nt != expected
        end

        @testset "cols" begin
            @testset "cols = all" begin
                cols = [:a, :b]
                @test Transforms.apply(nt, hod; cols=cols) == expected
                @test hod(nt; cols=cols) == expected
            end

            @testset "cols = :a" begin
                cols = [:a]
                # TODO: this is kind of ugly if only a single Vector is expected
                expected = [[0, 1, 2]]

                @test Transforms.apply(nt, hod; cols=cols) == expected
                @test hod(nt; cols=cols) == expected
            end

            @testset "cols = :b" begin
                cols = [:b]
                expected = [[3, 4, 5]]

                @test Transforms.apply(nt, hod; cols=cols) == expected
                @test hod(nt; cols=cols) == expected
            end
        end
    end


    @testset "DataFrame" begin
        df = DataFrame(
            :a => DateTime(2020, 1, 1, 0, 0):Hour(1):DateTime(2020, 1, 1, 2, 0),
            :b => DateTime(2020, 1, 1, 3, 0):Hour(1):DateTime(2020, 1, 1, 5, 0)
        )
        expected = [[0, 1, 2], [3, 4, 5]]

        @testset "all cols" begin
            @test Transforms.apply(df, hod) == expected
            @test hod(df) == expected

            # Test the tranform was not mutating
            @test df != expected
        end

        @testset "cols" begin
            @testset "cols = all" begin
                cols = [:a, :b]
                @test Transforms.apply(df, hod; cols=cols) == expected
                @test hod(df; cols=cols) == expected
            end

            @testset "cols = :a" begin
                cols = [:a]
                expected = [[0, 1, 2]]

                @test Transforms.apply(df, hod; cols=cols) == expected
                @test hod(df; cols=cols) == expected
            end

            @testset "cols = :b" begin
                cols = [:b]
                expected = [[3, 4, 5]]

                @test Transforms.apply(df, hod; cols=cols) == expected
                @test hod(df; cols=cols) == expected
            end
        end
    end
end
