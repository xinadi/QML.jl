# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using CxxWrap
using Observables
using QML
using Makie

const catangle = Observable(0.0)
const cat = mesh(Makie.loadasset("cat.obj"))

# Render function that takes a parameter t from a QML slider
function render_function(screen)
  rotate!(cat, Vec3f0(0, 0, 1), catangle[]*π/180)
  display(screen, cat)
end

load(joinpath(dirname(@__FILE__), "qml", "makie.qml"),
  catangle=catangle,
  render_callback=@safe_cfunction(render_function, Cvoid, (Any,))
)
exec()
