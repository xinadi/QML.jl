myname = splitdir(@__FILE__)[end]

for fname in readdir()
  if fname != myname && endswith(fname, ".jl")
    println("running test ", fname, "...")
    include(fname)
  end
end
