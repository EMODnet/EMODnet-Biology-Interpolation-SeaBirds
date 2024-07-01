using Dates
using Test


@testset "Date parsing" begin
    @test parse_date("1993-08-14/1993-08-14") == DateTime(1993, 8, 14)
    @test parse_date("1993-08-12") == DateTime(1993, 8, 12)
    @test parse_date("1993-08-14T08:55:00Z") == DateTime(1993, 8, 14, 8, 55, 0)
end
