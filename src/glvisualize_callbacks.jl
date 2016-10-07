using Colors
using FixedPointNumbers
using FixedSizeArrays
using GeometryTypes
using GLAbstraction
using GLFW
using GLVisualize
using GLWindow
using ModernGL
using Reactive

type GLVisualizeState
  window_open::Signal{Bool}
  window_size::Signal{Vec{2,Int}}
  window_position::Signal{Vec{2,Int}}
  keyboard_buttons::Signal{NTuple{4, Int}}
  mouse_buttons::Signal{NTuple{3, Int}}
  dropped_files::Signal{Vector{Compat.UTF8String}}
  framebuffer_size::Signal{Vec{2,Int}}
  unicode_input::Signal{Vector{Char}}
  cursor_position::Signal{Vec{2, Float64}}
  scroll::Signal{Vec{2, Float64}}
  hasfocus::Signal{Bool}
  entered_window::Signal{Bool}
  mouseinside::Signal{Bool}

  screen::Screen

  GLVisualizeState() = new(
    Signal(true),
    Signal(Vec{2,Int}(0,0)),
    Signal(Vec{2,Int}(0,0)),
    Signal((0,0,0,0)),
    Signal((0,0,0)),
    Signal(Compat.UTF8String[]),
    Signal(Vec{2,Int}(0,0)),
    Signal(Char[]),
    Signal(Vec(0.,0.)),
    Signal(Vec(0.,0.)),
    Signal(false),
    Signal(false),
    Signal(false)
  )
end

function initialize_signals()
  state = GLVisualizeState()
  return state
end

function on_framebuffer_setup(state, handle, width, height)
  signal_dict = Dict{Symbol, Any}()

  window = GLFW.Window(C_NULL)

  push!(state.framebuffer_size, Vec2(width, height))

  # window area signal as a rectangle
  window_area = map(SimpleRectangle,
      Signal(Vec(0,0)),
      state.framebuffer_size
  )
  signal_dict[:window_area] = window_area

  # mouse position in pixel coordinates with 0,0 in left down corner
  signal_dict[:mouseposition] = state.cursor_position

  signal_dict[:mouse2id] = Signal(GLWindow.SelectionID{Int}(-1, -1))

  color = RGBA{Float32}(1,1,1,1)

  for fdname in fieldnames(state)[1:end-1]
    signal_dict[fdname] = getfield(state,fdname)
  end

  buffersize = tuple(width, height)
  color_buffer = GLAbstraction.Texture(RGBA{UFixed8}, buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)
  objectid_buffer = Texture(Vec{2, GLushort}, buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)
  depth_buffer = Texture(Float32, buffersize,
    internalformat = GL_DEPTH_COMPONENT32F,
    format         = GL_DEPTH_COMPONENT,
    minfilter=:nearest, x_repeat=:clamp_to_edge
  )

  # GLWindow.attach_framebuffer(color_buffer, GL_COLOR_ATTACHMENT0)
  # GLWindow.attach_framebuffer(objectid_buffer, GL_COLOR_ATTACHMENT1)
  # GLWindow.attach_framebuffer(depth_buffer, GL_DEPTH_ATTACHMENT)

  p  = GLWindow.postprocess(color_buffer, state.framebuffer_size)
  fb = GLWindow.GLFramebuffer(handle, color_buffer, objectid_buffer, depth_buffer, p)

  if !isdefined(state, :screen)
    state.screen = Screen(Symbol("QMLWindow"),
        window_area, Screen[], signal_dict,
        (), false, color,
        Dict{Symbol, Any}(),
        GLWindow.GLContext(window, fb)
    )
  else
    state.screen.glcontext = GLWindow.GLContext(window, fb)
  end

  GLVisualize.add_screen(state.screen)
  GLWindow.add_complex_signals!(state.screen)
end

on_window_close(signals) = push!(signals.window_open, false)
on_window_size_change(signals, w, h) = push!(signals.window_size, Vec{2,Int}(w, h))

function on_context_destroy()
  println("on_context_destroy called")
  GLAbstraction.empty_shader_cache!()
  return
end

# Copy of the render function from GLWindow, Screen should be abstract so isopen and ishidden can be overridden
function qml_render(x::Screen, parent::Screen=x, context=x.area.value)
  colorbits = GL_DEPTH_BUFFER_BIT
  if alpha(x.color) > 0
    glClearColor(red(x.color), green(x.color), blue(x.color), alpha(x.color))
    colorbits = colorbits | GL_COLOR_BUFFER_BIT
  end
  glClear(colorbits)

  render(x.renderlist)
  if !isempty(x.children)
    println("warning: screen used in QML has children, but they are ignored")
  end
end

function render_glvisualize_scene(state)
  fb = GLWindow.framebuffer(state.screen)
  qml_render(state.screen)
  # GLWindow.push_selectionqueries!(state.screen)
  #GLWindow.render(fb.postprocess)
end
