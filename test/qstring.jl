using CxxWrap
using QML
using Test

let strings = ["TestStr", "😁😃😆abc😎😈☹"]
  qsl = QStringList()
  for s in strings
      qs = QString(s)
      @test qs == s
      io = IOBuffer()
      write(io, qs)
      @test String(take!(io)) == s
      @test length(qs) == length(s)
      push!(qsl, s)
  end

  @test strings == qsl
end
