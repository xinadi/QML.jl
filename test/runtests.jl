using Base.Test

excluded = ["runtests.jl", "qml", "include", "julia_object.jl"]

# OpenGL on Linux travis is excessively old, causing a crash when attempting display of a window
if get(ENV, "QML_SKIP_GUI_TESTS", "0") != "0"
  excluded = [excluded; ["listviews.jl", "qqmlcomponent.jl", "qquickview.jl"]]
end

@testset "QML tests" begin
  @testset "$f" for f in filter(fname -> fname ∉ excluded, readdir())
    include(f)
  end
end