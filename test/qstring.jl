using CxxWrap
using QML
using Test

for s in ["TestStr", "😁😃😆abc😎😈☹"]
    qs = QString(s)
    @test qs == s
    io = IOBuffer()
    write(io, qs)
    @test String(take!(io)) == s
    @test length(qs) == length(s)
end
