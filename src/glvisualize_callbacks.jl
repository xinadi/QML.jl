module MakieSupport

using Colors
using FixedPointNumbers
using Makie
using ModernGL
using QML


mutable struct QMLWindow
end

Base.isopen(w::QMLWindow) = true

struct QMLGLContext
  frambuffer::GLuint
end

Makie.GLMakie.GLAbstraction.native_switch_context!(fbo::QML.QOpenGLFramebufferObject) = QML.bind(fbo)
Makie.GLMakie.GLAbstraction.native_context_alive(fbo::QML.QOpenGLFramebufferObject) = QML.isValid(fbo)

struct QMLScreen <: AbstractPlotting.AbstractScreen
  size::Tuple{Int,Int}
  makiescreen::Makie.GLMakie.Screen
end

function Makie.GLMakie.render_frame(screen::QMLScreen)
  fb = screen.makiescreen.framebuffer
  w, h = screen.size
  Makie.GLMakie.GLAbstraction.render(screen.makiescreen, true)
  return
  glDisable(GL_STENCIL_TEST)
  #prepare for geometry in need of anti aliasing
  glBindFramebuffer(GL_FRAMEBUFFER, fb.id[1]) # color framebuffer
  glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])
  glClearColor(0,0,0,0)
  glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT | GL_COLOR_BUFFER_BIT)
  #setup!(screen)
  glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE)
  Makie.GLMakie.GLAbstraction.render(screen.makiescreen, true)
  # transfer color to luma buffer and apply fxaa
  glBindFramebuffer(GL_FRAMEBUFFER, fb.id[2]) # luma framebuffer
  glDrawBuffer(GL_COLOR_ATTACHMENT0)
  glViewport(0, 0, w, h)
  glClearColor(0,0,0,0)
  glClear(GL_COLOR_BUFFER_BIT)
  Makie.GLMakie.GLAbstraction.render(fb.postprocess[1]) # add luma and preprocess

  glBindFramebuffer(GL_FRAMEBUFFER, fb.id[1]) # transfer to non fxaa framebuffer
  glViewport(0, 0, w, h)
  glDrawBuffer(GL_COLOR_ATTACHMENT0)
  Makie.GLMakie.GLAbstraction.render(fb.postprocess[2]) # copy with fxaa postprocess

  #prepare for non anti aliased pass
  glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])

  Makie.GLMakie.GLAbstraction.render(screen.makiescreen, false)
  #Read all the selection queries
  glReadBuffer(GL_COLOR_ATTACHMENT1)
  for query_func in Makie.GLMakie.selection_queries
      query_func(fb.objectid, w, h)
  end
  glBindFramebuffer(GL_FRAMEBUFFER, 0) # transfer back to window
  glViewport(0, 0, w, h)
  glClearColor(0, 0, 0, 0)
  glClear(GL_COLOR_BUFFER_BIT)
  Makie.GLMakie.GLAbstraction.render(fb.postprocess[3]) # copy postprocess
  return
end

function Base.display(screen::QMLScreen, scene::Scene)
  scene.events.window_area[] = AbstractPlotting.IRect(0,0,screen.size...)
  empty!(screen.makiescreen)
  #AbstractPlotting.register_callbacks(scene, screen)
  insertplots!(screen.makiescreen, scene)
  AbstractPlotting.update!(scene)
  Makie.GLMakie.render_frame(screen)
  return
end

function setup_framebuffer(fbo)
  render_framebuffer = QML.handle(fbo)
  
  #output = [GLint(0)]
  #glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, pointer(output))

  Makie.GLMakie.GLAbstraction.switch_context!(fbo)
  fb_size = Int.(QML.size(fbo))

  color_buffer = Makie.GLMakie.Texture(RGBA{N0f8}, fb_size, minfilter=:nearest, x_repeat=:clamp_to_edge)
  objectid_buffer = Makie.GLMakie.Texture(Vec{2,GLushort}, fb_size, minfilter=:nearest, x_repeat=:clamp_to_edge)
  depth_buffer = Makie.GLMakie.Texture(Float32, fb_size,
    minfilter=:nearest, x_repeat=:clamp_to_edge,
    internalformat=GL_DEPTH_COMPONENT32F,
    format=GL_DEPTH_COMPONENT)

  Makie.GLMakie.attach_framebuffer(color_buffer, GL_COLOR_ATTACHMENT0)
  Makie.GLMakie.attach_framebuffer(objectid_buffer, GL_COLOR_ATTACHMENT1)
  Makie.GLMakie.attach_framebuffer(depth_buffer, GL_DEPTH_ATTACHMENT)
  status = glCheckFramebufferStatus(GL_FRAMEBUFFER)
  @assert status == GL_FRAMEBUFFER_COMPLETE

  color_luma = Makie.GLMakie.Texture(RGBA{N0f8}, fb_size, minfilter=:linear, x_repeat=:clamp_to_edge)
  color_luma_framebuffer = glGenFramebuffers()
  glBindFramebuffer(GL_FRAMEBUFFER, color_luma_framebuffer)
  Makie.GLMakie.attach_framebuffer(color_luma, GL_COLOR_ATTACHMENT0)
  @assert status == GL_FRAMEBUFFER_COMPLETE

  glBindFramebuffer(GL_FRAMEBUFFER, 0)
  fb_size_node = Node(fb_size)
  p = Makie.GLMakie.postprocess(color_buffer, color_luma, fb_size_node)

  fb = Makie.GLMakie.GLFramebuffer(fb_size_node,
    (render_framebuffer, color_luma_framebuffer),
    color_buffer, objectid_buffer, depth_buffer,
    color_luma,
    p)
  
  # Bind the render buffer again
  QML.bind(fbo)


  # clear = true
  # stroke = (0f0, color)

  # glctx = QMLGLContext(window, fb, true)
  # if !isdefined(state, :screen)
  #   state.screen = Screen(Symbol("QMLWindow"),
  #     window_area, nothing, Screen[], signal_dict,
  #     (), false, clear, color, stroke,
  #     Dict{Symbol, Any}(),
  #     glctx
  #   )
  # else
  #   state.screen.glcontext = glctx
  # end

  # GLVisualize.add_screen(state.screen)
  # GLWindow.add_complex_signals!(state.screen)



  @show QML.size(fbo)

  screen = QMLScreen(QML.size(fbo), Makie.GLMakie.Screen(
    Makie.GLMakie.GLFW.Window(C_NULL), fb,
    Base.RefValue{Task}(),
    Dict{WeakRef, Makie.GLMakie.ScreenID}(),
    Makie.GLMakie.ScreenArea[],
    Tuple{Makie.GLMakie.ZIndex, Makie.GLMakie.ScreenID, Makie.GLMakie.RenderObject}[],
    Dict{UInt64, Makie.GLMakie.RenderObject}(),
    Dict{UInt16, AbstractPlot}(),
  ))
  return screen
end

# on_window_close(signals) = push!(signals.window_open, false)
# on_window_size_change(signals, w, h) = push!(signals.window_size, Vec{2,Int}(w, h))

# function on_context_destroy()
#   GLAbstraction.empty_shader_cache!()
#   return
# end

# # Copy of the render function from GLWindow, Screen should be abstract so isopen and ishidden can be overridden
# function qml_render(x::Screen, parent::Screen=x, context=x.area.value)
#   colorbits = GL_DEPTH_BUFFER_BIT
#   if alpha(x.color) > 0
#   glClearColor(red(x.color), green(x.color), blue(x.color), alpha(x.color))
#   colorbits = colorbits | GL_COLOR_BUFFER_BIT
#   end
#   glClear(colorbits)

#   # TODO: actually do the fxaa stuff
#   render(x.renderlist_fxaa)
#   if !isempty(x.children)
#   println("warning: screen used in QML has children, but they are ignored")
#   end
# end

# function render_glvisualize_scene(state)
#   fb = GLWindow.framebuffer(state.screen)
#   qml_render(state.screen)
#   #GLWindow.push_selectionqueries!(state.screen)
#   #GLWindow.render(fb.postprocess)
# end

end
