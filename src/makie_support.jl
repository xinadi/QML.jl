module MakieSupport

using Colors
using FixedPointNumbers
using Makie
using ModernGL
using QML

mutable struct QMLGLContext
  valid::Bool
  fbo::QML.QOpenGLFramebufferObjectRef
end

Makie.GLMakie.GLAbstraction.native_switch_context!(ctx::QMLGLContext) = QML.bind(ctx.fbo)

function Makie.GLMakie.GLAbstraction.native_context_alive(ctx::QMLGLContext)
  return ctx.valid
end

const ScreenID = Makie.GLMakie.ScreenID
const ZIndex = Makie.GLMakie.ZIndex
const RenderObject = Makie.GLMakie.RenderObject
const ScreenArea = Makie.GLMakie.ScreenArea

mutable struct QMLScreen <: Makie.GLMakie.GLScreen
  size::Tuple{Int,Int}
  screen2scene::Dict{WeakRef, ScreenID}
  screens::Vector{ScreenArea}
  renderlist::Vector{Tuple{ZIndex, ScreenID, RenderObject}}
  cache::Dict{UInt64, RenderObject}
  cache2plot::Dict{UInt16, AbstractPlot}
  framecache::Tuple{Matrix{RGB{N0f8}}, Matrix{RGB{N0f8}}}

  function QMLScreen(w, h)
    newscreen = new(
      (w,h),
      Dict{WeakRef, ScreenID}(),
      ScreenArea[],
      Tuple{ZIndex, ScreenID, RenderObject}[],
      Dict{UInt64, RenderObject}(),
      Dict{UInt16, AbstractPlot}()
    )
    finalizer(newscreen) do s
      # save_print("Freeing screen")
      empty!.((s.renderlist, s.screens, s.cache, s.screen2scene, s.cache2plot))
      return
    end
  end
end

Base.isopen(screen::QMLScreen) = true
Makie.GeometryTypes.widths(screen::QMLScreen) = screen.size

function Makie.GLMakie.render_frame(screen::QMLScreen)
  Makie.GLMakie.setup!(screen)
  for (zindex, screenid, elem) in screen.renderlist
    Makie.GLMakie.render(elem)
  end
end

function Base.display(screen::QMLScreen, scene::Scene)
  scene.events.window_area[] = AbstractPlotting.IRect(0,0,screen.size...)
  empty!(screen)
  insertplots!(screen, scene)
  AbstractPlotting.update!(scene)
  Makie.GLMakie.render_frame(screen)
  return
end

function setup_screen(fbo)
  try
    old_ctx = Makie.GLMakie.GLAbstraction.current_context()
    old_ctx.valid = false
  catch
  end
  Makie.GLMakie.GLAbstraction.switch_context!(QMLGLContext(true, fbo))
  return QMLScreen(QML.size(fbo)...)
end

function on_context_destroy()
  Makie.GLMakie.GLAbstraction.switch_context!()
  return
end

end
