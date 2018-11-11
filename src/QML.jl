module QML

export QQmlContext, root_context, load, qt_prefix_path, set_source, engine, QByteArray, to_string, QQmlComponent, set_data, create, QQuickItem, content_item, JuliaObject, QTimer, context_property, emit, JuliaDisplay, init_application, qmlcontext, init_qmlapplicationengine, init_qmlengine, init_qquickview, exec, exec_async, ListModel, addrole, setconstructor, removerole, setrole, roles, QVariantMap
export QPainter, device, width, height, logicalDpiX, logicalDpiY, QQuickWindow, effectiveDevicePixelRatio, window, JuliaPaintedItem, update
export @emit, @qmlfunction, qmlfunction, load, QQmlPropertyMap, set_context_object

const depsfile = joinpath(dirname(dirname(@__FILE__)), "deps", "deps.jl")
if !isfile(depsfile)
  error("$depsfile not found, package QML did not build properly")
end
include(depsfile)

@static if Sys.iswindows()
  ENV["QML_PREFIX_PATH"] = dirname(dirname(libjlqml))
end

using CxxWrap
using Observables
using FileIO
import Libdl

const envfile = joinpath(dirname(dirname(@__FILE__)), "deps", "env.jl")
if isfile(envfile)
  include(envfile)
end

"""
QVariant type encapsulation. Used to wrap Julia values that need to be passed as a QVariant to QML
"""
struct QVariant
  value::Any
end

@wrapmodule libjlqml

function FileIO.load(f::FileIO.File{format"QML"}, ctxobj::QObject)
  qml_engine = init_qmlapplicationengine()
  ctx = root_context(qml_engine)
  set_context_object(ctx, ctxobj)
  if !load_into_engine(qml_engine, filename(f))
    error("Failed to load QML file ", filename(f))
  end
  gcprotect(ctxobj)
  return qml_engine
end

"""

load(qml_file, prop1=x, prop2=y, ...)

Load a QML file, creating a QQmlApplicationEngine and setting the context properties supplied in the keyword arguments. Returns the created engine.

load(qml_file, context_object)

Load a QML file, creating a QQmlApplicationEngine and setting the context object to the supplied QObject
"""
function FileIO.load(f::FileIO.File{format"QML"}; kwargs...)
  qml_engine = init_qmlapplicationengine()
  ctx = root_context(qml_engine)
  propmap = QQmlPropertyMap(ctx)
  set_context_object(ctx, propmap)
  for (key,value) in kwargs
    propmap[String(key)] = value
  end
  if !load_into_engine(qml_engine, filename(f))
    error("Failed to load QML file ", filename(f))
  end
  return qml_engine
end

function __init__()
  @static if Sys.iswindows()
    libdir = joinpath(dirname(dirname(@__FILE__)),"deps","usr","lib")
    for fname in readdir(libdir)
      if endswith(fname, ".dll")
        Libdl.dlopen(joinpath(libdir,fname), Libdl.RTLD_GLOBAL)
      end
    end
  end

  @initcxx
  FileIO.add_format(format"QML", (), ".qml")
end

# Functor to update a QML property when an Observable is changed in Julia
struct QmlPropertyUpdater
  propertymap::QQmlPropertyMap
  key::String
end
function (updater::QmlPropertyUpdater)(x)
  updater.propertymap[updater.key] = x
end

# Predicate to find out if a handler is a QML updater
noqmlupdater(::Any) = true
noqmlupdater(::QmlPropertyUpdater) = false

# Called from C++ to update an Observable linked to a QML property
function update_observable_property!(o::Observable, v)
  # This avoids calling the to-qml update handler, since we initiated the update from QML
  Observables.setexcludinghandlers(o, v, noqmlupdater)
end

# Set arrays directly only if they have the same type
function update_observable_property!(o::Observable{Array{T}}, v::Array{T}) where {T}
  invoke(update_observable_property!, Tuple{Observable, Any}, o, v)
end

# Arrays with another type must be converted
function update_observable_property!(o::Observable{Array{T1}}, v::Array{T2}) where {T1,T2}
  invoke(update_observable_property!, Tuple{Observable, Any}, o, Array{T1}(v))
end

# QQmlPropertyMap indexing interface
Base.getindex(propmap::QQmlPropertyMap, key::AbstractString) = value(propmap, key).value
function Base.setindex!(propmap::QQmlPropertyMap, val::T, key::AbstractString) where {T}
  if !isbits(T) && !isimmutable(T)
    gcprotect(val)
  end
  insert(propmap, key, QVariant(val))
end
Base.setindex!(propmap::QQmlPropertyMap, val::QVariant, key::AbstractString) = insert(propmap, key, val)
function Base.setindex!(propmap::QQmlPropertyMap, val::Observable, key::AbstractString)
  insert_observable(propmap, key, val)
  on(QmlPropertyUpdater(propmap, key), val)
end
Base.setindex!(propmap::QQmlPropertyMap, val::Irrational, key::AbstractString) = (propmap[key] = convert(Float64, val))

"""
Expand an expression of the form a.b.c to replace the dot operator by function calls:
`@expand_dots a.b.c.d f` returns `f(f(f(a,"b"),"c"),"d")`
"""
macro expand_dots(source_expr, func)
  if source_expr.head == :escape
    source_expr = source_expr.args[1]
  end
  if isa(source_expr, Expr) && source_expr.head == :(.)
    return :($func(@expand_dots($(esc(source_expr.args[1])), $func), $(string(source_expr.args[2].args[1]))))
  end
  return esc(source_expr)
end

"""
Emit a signal in the form:
```
@emit signal_name(arg1, arg2)
```
"""
macro emit(expr)
  esc(:(emit($(string(expr.args[1])), Any[$(expr.args[2:end]...)])))
end

"""
Register a Julia function for access from QML:
```
@qmlfunction MyFunc
```
"""
macro qmlfunction(fnames...)
  result = quote end
  for fname in fnames
    push!(result.args, :(qmlfunction($(esc(string(fname))), $(esc(fname)))))
  end

  return result
end

function qmlapp(path::AbstractString)
  qml_engine = init_qmlapplicationengine()
  return load_into_engine(qml_engine, path)
end

function Base.display(d::JuliaDisplay, x)
  buf = IOBuffer()
  supported_types = (MIME"image/svg+xml"(), MIME"image/png"())
  write_methods = (load_svg, load_png)
  written = false
  for (t,write_method) in zip(supported_types, write_methods)
    if showable(t,x)
      Base.show(buf, t, x)
      write_method(d, take!(buf))
      written = true
      break
    end
  end
  if !written
    throw(MethodError(display, (d,x)))
  end

end

function Base.displayable(d::JuliaDisplay, mime::AbstractString)
  if mime == "image/png"
    return true
  end
  return false
end

function load_makie_support()
  include(joinpath(dirname(@__FILE__), "makie_support.jl"))
end

"""
Constructor for ListModel that automatically copies a typed array into an Array{Any,1} and creates a constructor and setter and getter functions for each field if addroles == true
"""
function ListModel(a::Array{T}, addroles=true) where {T}
  any_array = Array{Any,1}(a)
  function update_array()
    n = length(any_array)
    resize!(a,n)
    for i = 1:n
      a[i] = any_array[i]
    end
  end

  listmodel = ListModel(any_array, update_array)

  if nfields(T) > 0 && addroles
    for fname in fieldnames(T)
      addrole(listmodel, string(fname), (x) -> getfield(x, fname), (array, value, index) -> setfield!(array[index], fname, value))
    end
    setconstructor(listmodel, T)
  end

  return listmodel
end

# ListModel Julia interface
Base.push!(lm::ListModel, val) = push_back(lm, val)
Base.size(lm::ListModel) = (model_length(lm),)
Base.length(lm::ListModel) = model_length(lm)
Base.delete!(lm::ListModel, i) = remove(lm, i-1)

@doc """
Module for building [Qt5 QML](http://doc.qt.io/qt-5/qtqml-index.html) graphical user interfaces for Julia programs.
Types starting with `Q` are equivalent of their Qt C++ counterpart, so they have no Julia docstring and we refer to
the [Qt documentation](http://doc.qt.io/qt-5/qtqml-index.html) for details instead.
""" QML

@doc "Equivalent to [`QQmlEngine::rootContext`](http://doc.qt.io/qt-5/qqmlengine.html#rootContext)" root_context

@doc "Equivalent to `QLibraryInfo::location(QLibraryInfo::PrefixPath)`" qt_prefix_path
@doc "Equivalent to `QQuickWindow::contentItem`" content_item
@doc "Equivalent to `QQuickView::setSource`" set_source
@doc "Equivalent to `QQuickView::show`" show
@doc "Equivalent to `QQuickView::engine`" engine
@doc "Equivalent to `QQuickView::rootObject`" root_object

@doc "Equivalent to `QByteArray::toString`" to_string

@doc """
Equivalent to `QQmlComponent::setData`. Use this to set the QML code for a QQmlComponent from a Julia string literal.
""" set_data

@doc """
Equivalent to `QQmlComponent::create`. This creates a component defined by the QML code set using `set_data`.
It also makes sure the newly created object is parented to the given context.
""" create

@doc """
qmlfunction(name, function)

Register the given function using the given name. Useful for registering functions from a non-exported module or renaming a function upon register (e.g. removing the !)

""" qmlfunction

end
