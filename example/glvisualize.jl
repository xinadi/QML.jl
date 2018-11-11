# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using CxxWrap
using QML
using Makie

# Cat example from GLVisualize
#mesh 	= loadasset("cat.obj")

mutable struct CatAngle
  angle::Float64
end

const catangle = CatAngle(0)

# Render function that takes a parameter t from a QML slider
function render_function(screen)
  #rotation_angle = Float32(catangle.angle)*pi/180f0
  #rotation  = rotationmatrix_x(deg2rad(90f0)) * rotationmatrix_y(rotation_angle)

  scene = mesh(Makie.loadasset("cat.obj"))
  display(screen, scene)
  @show size(scene)
  return
end

load(joinpath(dirname(@__FILE__), "qml", "glvisualize.qml"),
  catangle=catangle,
  render_callback=@safe_cfunction(render_function, Cvoid, (Any,))
)
exec()
