myname = splitdir(@__FILE__)[end]

excluded = []

# OpenGL on Linux travis is excessively old, causing a crash when attempting display of a window
if get(ENV, "QML_SKIP_GUI_TESTS", "0") != "0"
  excluded = ["listviews.jl", "qqmlcomponent.jl", "qquickview.jl"]
end

for fname in readdir()
  if fname ∈ excluded
    println("Skipping disabled test $fname")
    continue
  end
  if fname != myname && endswith(fname, ".jl")
    println("running test ", fname, "...")
    include(fname)
  end
end
