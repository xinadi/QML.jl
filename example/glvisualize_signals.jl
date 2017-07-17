# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using CxxWrap
using QML
using GLVisualize, GeometryTypes, GLAbstraction, Colors
using Reactive

# Cat example from GLVisualize
mesh 	= loadasset("cat.obj")

input_degrees = Signal(0f0)
rotation_angle  = const_lift(*, input_degrees, pi/180f0)
start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0)))
rotation = map(rotationmatrix_y, rotation_angle)
final_rotation = map(*, start_rotation, rotation)

type CatAngle
  angle::Float64
end

const catangle = CatAngle(0)

# Render function that takes a parameter t from a QML slider
function render_function()
  # Set up the visualization only the first time
  global context
  if(!isdefined(:context))
    context = visualize(mesh, model=final_rotation)
    _view(context)
  end

  # Update the input signal
  push!(input_degrees, Float32(catangle.angle))
  yield() # Needed to give the signals a chance to update
end

render_callback = CxxWrap.safe_cfunction(render_function, Void, ())

@qmlapp joinpath(dirname(@__FILE__), "qml", "glvisualize.qml") catangle render_callback
exec()
