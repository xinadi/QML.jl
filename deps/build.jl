using BinaryProvider

const JLQML_DIR = get(ENV, "JLQML_DIR", "")
const prefix = Prefix(JLQML_DIR == "" ? !isempty(ARGS) ? ARGS[1] : joinpath(@__DIR__,"usr") : JLQML_DIR)

products = Product[
    LibraryProduct(prefix, "libjlqml", :libjlqml)
]

if any(!satisfied(p; verbose=true) for p in products)
    # TODO: Add download code here
end

write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
