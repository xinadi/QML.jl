# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using QML
using GLVisualize, GeometryTypes, GLAbstraction, Colors
using Reactive

# Cat example from GLVisualize
mesh 	= loadasset("cat.obj")
timesignal = Signal(0f0)
rotation_angle  = const_lift(*, timesignal, 1f0*pi/180f0)
start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0)))
rotation 		= map(rotationmatrix_y, rotation_angle)
final_rotation 	= map(*, start_rotation, rotation)

# Render function that takes a parameter t from a QML slider
function render(t)
  global robj
  if(!isdefined(:robj))
    robj = visualize(mesh, model=final_rotation)
  end

  push!(timesignal, Float32(t))

  view(robj)
end

@qmlapp joinpath(dirname(@__FILE__), "qml", "glvisualize.qml")
exec()
