# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using QML
using GLVisualize, GeometryTypes, GLAbstraction, Colors
using Reactive

# lines2d example
const N = 2048
function spiral(i, start_radius, offset)
	Point2f0(sin(i), cos(i)) * (start_radius + ((i/2pi)*offset))
end
# 2D particles
curve_data(i, N) = Point2f0[spiral(i+x/20f0, 1, (i/20)+1) for x=1:N]

timesignal = Signal(0.)

t = const_lift(x-> (1f0-x)*100f0, timesignal)
color = map(RGBA{Float32}, colormap("Blues", N))

# The qml_time parameter is a Float64 from the QML slider
function render(qml_time)
  global robj
  if(!isdefined(:robj))
    robj = visualize(const_lift(curve_data, t, N), :lines, color=color)
  end

  push!(timesignal, qml_time)

  view(robj)

  return
end

# Cat example shows up blank
# mesh 	= loadasset("cat.obj")
# timesignal = Signal(0.)
# rotation_angle  = const_lift(*, timesignal, 2f0*pi)
# start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0)))
# rotation 		= map(rotationmatrix_y, rotation_angle)
# final_rotation 	= map(*, start_rotation, rotation)
#
# # Render function that takes a parameter t from a QML slider
# function render(t)
#   global robj
#   if(!isdefined(:robj))
#     robj = visualize(mesh, model=final_rotation)
#   end
#
#   push!(timesignal, t)
#
#   view(robj)
# end

@qmlapp joinpath(dirname(@__FILE__), "qml", "glvisualize.qml")
exec()
