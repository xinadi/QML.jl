using QML
using Observables
using Plots
using ColorTypes
import CxxWrap # for safe_cfunction

const qmlfile = joinpath(dirname(Base.source_path()), "qml", "canvas_and_display.qml")

do_this = Observable(0)

amplitude = Observable(0.0)
frequency = Observable(0.0)
diameter = Observable(0.0)

foinkle = Observable(1.0)

on(do_this) do d
    println("do_this changed to ", d)
end

on(amplitude) do a
    update_sin_display()
    update_cos_display()
end

on(frequency) do f
    foinkle[] = round(2*f, digits=2)
    update_sin_display()
    update_cos_display()
end

on(diameter) do d
    @emit updateCircle()
end

struct JDisplay
    disp:: Union{JuliaDisplay, Nothing}
    width:: Int
    height:: Int
    function JDisplay()
        return new(nothing, 0, 0)
    end
    function JDisplay(disp, width, height)
        return new(disp, width, height)
    end
end

sin_display = JDisplay()
cos_display = JDisplay()

function init_jdisp1(disp::JuliaDisplay, width::Float64, height::Float64)
    global sin_display = JDisplay(disp, width, height)
    update_sin_display()
end

function init_jdisp2(disp::JuliaDisplay, width::Float64, height::Float64)
    global cos_display = JDisplay(disp, width, height)
    update_cos_display()
end

function update_sin_display()
    jdisp = sin_display
    jdisp.disp != nothing || return
    Plots.gr(size=(Int64(round(jdisp.width)),Int64(round(jdisp.height))))
    Plots.GR.inline()
    x = 0:π/2000:π
    f = amplitude[] * sin.(frequency[] .* x)
    plt = Plots.plot(x,f,ylims=(-5,5),show=false)
    display(jdisp.disp, plt)
    return
end

function update_cos_display()
    jdisp = cos_display
    jdisp.disp != nothing || return
    Plots.gr(size=(Int64(round(jdisp.width)),Int64(round(jdisp.height))))
    Plots.GR.inline()
    x = 0:π/2000:π
    f = amplitude[] * sin.(frequency[] .* x)
    plt = Plots.plot(x,f,ylims=(-5,5),show=false)
    display(jdisp.disp, plt)
    return
end

# fix callback arguments (TODO: macro this?)
function paint_circle(buffer::Array{UInt32, 1},
                      width32::Int32,
                      height32::Int32)
    width::Int = width32
    height::Int = height32
    buffer = reshape(buffer, width, height)
    buffer = reinterpret(ARGB32, buffer)
    paint_circle(buffer)
end

# callback to paint circle
function paint_circle(buffer)
    width, height = size(buffer)

    center_x = width/2
    center_y = height/2
    rad2 = (diameter[]/2)^2
    for x in 1:width
        for y in 1:height
            if (x-center_x)^2 + (y-center_y)^2 < rad2
                buffer[x,y] = ARGB32(1, 0, 0, 1) #red
            else
                buffer[x,y] = ARGB32(0, 0, 0, 1) #black
            end
            if x < 10
                buffer[x,y] = ARGB32(1, 0, 0, 1) # red
            end
            if y < 10
                buffer[x,y] = ARGB32(0, 0, 1, 1) # blue
            end
            if x == y
                if y < height/2
                    buffer[x,y] = ARGB32(0, 1, 0, 1) # green
                else
                    buffer[x,y] = ARGB32(1, 1, 0, 1) # yellow
                end
            end
        end
    end
    return
end

@qmlfunction init_jdisp1 init_jdisp2

load("main.qml",
     do_this=do_this,
     amplitude=amplitude,
     frequency=frequency,
     diameter=diameter,
     foinkle=foinkle,
     paint_cfunction = CxxWrap.@safe_cfunction(paint_circle, Cvoid, (Array{UInt32,1}, Int32, Int32))
     )

exec()
