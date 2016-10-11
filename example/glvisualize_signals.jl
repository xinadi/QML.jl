# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using QML
using QML.GLVisualizeSupport
using GLVisualize, GeometryTypes, GLAbstraction, Colors
using Reactive

# Cat example from GLVisualize
mesh 	= loadasset("cat.obj")

input_degrees = Signal(0f0)
rotation_angle  = const_lift(*, input_degrees, pi/180f0)
start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0)))
rotation = map(rotationmatrix_y, rotation_angle)
final_rotation = map(*, start_rotation, rotation)

# Render function that takes a parameter t from a QML slider
function render_callback(degrees)
  # Set up the visualization only the first time
  global context
  if(!isdefined(:context))
    context = visualize(mesh, model=final_rotation)
    _view(context)
  end

  # Update the input signal
  push!(input_degrees, Float32(degrees))
  yield() # Needed to give the signals a chance to update
end

@qmlapp joinpath(dirname(@__FILE__), "qml", "glvisualize.qml")
exec()
