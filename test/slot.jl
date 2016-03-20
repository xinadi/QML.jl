using Base.Test
using QML

testval = 0

function set_testval()
  global testval
  testval = 1
end

slot = JuliaSlot(set_testval)
@test testval == 0
call_julia(slot)
@test testval == 1
