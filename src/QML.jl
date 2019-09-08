module QML

export QVariant, QString
export QQmlContext, root_context, load, qt_prefix_path, set_source, engine, QByteArray, to_string, QQmlComponent, set_data, create, QQuickItem, content_item, JuliaObject, QTimer, context_property, emit, JuliaDisplay, init_application, qmlcontext, init_qmlapplicationengine, init_qmlengine, init_qquickview, exec, exec_async, ListModel, addrole, setconstructor, removerole, setrole, roles, QVariantMap
export QStringList, QVariantList
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

@readmodule libjlqml
@wraptypes

# Make sure functions accepting a QString argument also accept a Julia string
CxxWrap.argument_overloads(::Type{<:QString}) = [QString,String]

@wrapfunctions

function FileIO.load(f::FileIO.File{format"QML"}, ctxobj::QObject)
  qml_engine = init_qmlapplicationengine()
  rootctx = root_context(CxxRef(qml_engine))
  # Make a child context, to avoid clobbering the global Qt object
  ctx = CxxPtr(QQmlContext(rootctx, rootctx))
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
  rootctx = root_context(CxxRef(qml_engine))
  # Make a child context, to avoid clobbering the global Qt object
  ctx = rootctx#CxxPtr(QQmlContext(rootctx, rootctx))
  propmap = QQmlPropertyMap(ctx)
  set_context_object(CxxRef(ctx), CxxPtr(propmap))
  for (key,value) in kwargs
    propmap[String(key)] = value
  end
  if !load_into_engine(qml_engine, QString(filename(f)))
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

# QString
function QString(s::String)
  char_arr = transcode(UInt16, s)
  return fromUtf16(char_arr, length(char_arr))
end
Base.ncodeunits(s::QString)::Int = cppsize(s)
Base.codeunit(s::QString) = UInt16
Base.codeunit(s::QString, i::Integer) = uint16char(s, i-1)
Base.isvalid(s::QString, i::Integer) = isvalidindex(s, i-1)
function Base.iterate(s::QString, i::Integer=1)
  if !isvalid(s,i)
    return nothing
  end
  (charcode, nexti) = get_iterate(s,i-1)
  if nexti == -1
    return nothing
  end
  return(Char(charcode),nexti+1)
end

const QVariantList = QList{QVariant}

# Conversion to the strongly-types QVariant interface
@inline QVariant(x) = QVariant(Any,x)
@inline QVariant(x::T) where {T<:Union{Number,Ref,CxxWrap.SafeCFunction,QVariantMap,Nothing}} = QVariant(T, x)
@inline QVariant(x::AbstractString) = QVariant(QString,QString(x))
@inline QVariant(x::QString) = QVariant(QString,x)
@inline QVariant(x::QObject) = QVariant(CxxPtr{QObject},CxxPtr(x))
@inline QVariant(x::QVariant) = x

function QVariant(arr::AbstractArray)
  qvarlist = QVariantList()
  for x in arr
    push!(qvarlist, x)
  end
  return QVariant(QVariantList, qvarlist)
end

@inline setValue(v::QVariant, x::T) where {T} = setValue(T, v, x)
@inline setValue(v::CxxWrap.CxxBaseRef{QVariant}, x::T) where {T} = setValue(T, v, x)
QVariant(::Type{Nothing}, ::Nothing) = QVariant()
value(v::Union{QVariant,CxxWrap.CxxBaseRef{QVariant}}) = value(type(v),v)
Base.convert(::Type{QVariant}, x::T) where {T} = QVariant(x)
Base.convert(::Type{T}, x::QVariant) where {T} = convert(T,value(x))
Base.convert(::Type{<:QVariant}, x::QVariant) = x

Base.IndexStyle(::Type{<:QList}) = IndexLinear()
Base.size(v::QList) = (Int(cppsize(v)),)
Base.getindex(v::QList, i::Int) = cppgetindex(v,i-1)[]
Base.setindex!(v::QList{T}, val, i::Int) where {T} = cppsetindex!(v, convert(T,val), i-1)
function Base.push!(v::QList{T}, x) where {T}
  push_back(v, convert(T,x))
  return v
end
Base.empty!(l::QList) = clear(l)
Base.deleteat!(l::QList, i::Integer) = removeAt(l, i-1)

# Helper to call a julia function
function julia_call(f, argptr::Ptr{Cvoid})
  arglist = CxxRef{QVariantList}(argptr)[]
  result = QVariant(f((value(x) for x in arglist)...))
  return result.cpp_object
end

function get_julia_call()
  return @cfunction(julia_call, Ptr{Cvoid}, (Any,Ptr{Cvoid}))
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

# QQmlPropertyMap indexing interface
Base.getindex(propmap::QQmlPropertyMap, key::AbstractString) = value(propmap, key).value
function Base.setindex!(propmap::QQmlPropertyMap, val::T, key::AbstractString) where {T}
  if !isbits(T) && !isimmutable(T)
    gcprotect(val)
  end
  qvar = QVariant(val)
  insert(propmap, QString(key), qvar)
end
Base.setindex!(propmap::QQmlPropertyMap, val::QVariant, key::AbstractString) = insert(propmap, key, val)
function Base.setindex!(propmap::QQmlPropertyMap, ob::Observable, key::AbstractString)
  val = QVariant(ob[])
  insert_observable(propmap, key, ob, val)
  on(QmlPropertyUpdater(propmap, key), ob)
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

function emit(name, args...)
  arglist = QVariantList()
  for arg in args
    push!(arglist, QVariant(arg))
  end
  emit(name, arglist)
end

"""
Emit a signal in the form:
```
@emit signal_name(arg1, arg2)
```
"""
macro emit(expr)
  esc(:(emit($(string(expr.args[1])), $(expr.args[2:end]...))))
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

struct ListModelFunctionUndefined <: Exception end
defaultsetter(array, value, index) = throw(ListModelFunctionUndefined())
defaultconstructor(roles...) = throw(ListModelFunctionUndefined())

mutable struct ListModelData
  values::AbstractVector
  roles::QStringList
  getters::Vector{Any}
  setters::Vector{Any}
  constructor
  customroles::Bool

  function ListModelData(values::AbstractVector)
    roles = QStringList()
    push!(roles, "string")
    return new(values, roles, [string], [defaultsetter], defaultconstructor, false)
  end
end

rowcount(m::ListModelData) = Int32(length(m.values))
rolenames(m::ListModelData) = m.roles

function data(m::ListModelData, row::Integer, role::Integer)
  if row ∉ axes(m.values,1)
    @warn "row $row is out of range for listmodel"
    return QVariant()
  end
  @assert length(rolenames(m)) == length(m.getters)
  return QVariant(m.getters[role](m.values[row]))
end

function setdata(m::ListModelData, row::Integer, val::CxxWrap.CxxBaseRef{QVariant}, role::Integer)
  if row ∉ axes(m.values,1)
    @warn "row $row is out of range for listmodel"
    return false
  end

  try
    m.setters[role](m.values, value(val), row)
    return true
  catch e
    rolename = rolenames(m)[role]
    if e isa ListModelFunctionUndefined
      @warn "No setter for role $rolename"
    else
      @warn "Error $e when setting value at row $row for role $rolename"
    end
    return false
  end
end

function append_list(m::ListModelData, args::CxxWrap.CxxBaseRef{QVariantList})
  try
    push!(m.values, m.constructor((value(x) for x in args[])...))
  catch e
    @error "Error $e when appending value to listmodel."
  end
end

function remove(m::ListModelData, row::Integer)
  if row ∉ axes(m.values,1)
    @warn "row $row is out of range for listmodel"
    return
  end
  deleteat!(m.values, row)
end

function move(m::ListModelData, from::Integer, to::Integer, nb::Integer)
  @assert from < to

  # Save elements to mov
  removed_elems = m.values[from:from+nb-1]
  # Shift elements that remain
  m.values[from:to-1] .= m.values[(from:to-1).+nb]
  # Place saved elements in to block
  m.values[to:to+nb-1] .= removed_elems

  return
end

clear(m::ListModelData) = empty!(m.values)
Base.push!(m::ListModelData, val) = push!(m.values, val)

"""
Constructor for ListModel that automatically creates a constructor and setter and getter functions for each field if addroles == true
"""
function ListModel(a::AbstractVector{T}, addroles=true) where {T}
  data = ListModelData(a)

  if !isabstracttype(T) && nfields(T) > 0 && addroles
    empty!(data.roles)
    empty!(data.getters)
    empty!(data.setters)
    for fname in fieldnames(T)
      push!(data.roles, string(fname))
      push!(data.getters, (x) -> getfield(x, fname))
      push!(data.setters, (array, value, index) -> setfield!(array[index], fname, value))
    end
    data.constructor = T
  end

  return ListModel(data)
end

function addrole(lm::ListModel, name, getter, setter=defaultsetter)
  m = get_julia_data(lm)
  if name ∈ rolenames(m)
    @error "Role $name exists, aborting add"
    return
  end

  if !m.customroles
    empty!(m.roles)
    empty!(m.getters)
    empty!(m.setters)
    m.customroles = true
  end

  push!(m.roles, name)
  push!(m.getters, getter)
  push!(m.setters, setter)

  emit_roles_changed(lm)

  return
end

function setrole(lm::ListModel, idx::Integer, name, getter, setter=defaultsetter)
  m = get_julia_data(lm)
  if idx ∉ axes(rolenames(m),1)
    @error "Listmodel index $idx is out of range, aborting setrole"
  end

  if name ∈ rolenames(m) && rolenames(m)[idx] != name
    @error "Role $name exists, aborting setrole"
    return
  end

  m.getters[idx] = getter
  m.setters[idx] = setter

  if rolenames(m)[idx] == name
    emit_data_changed(lm, 0, length(lm), StdVector(Int32[idx]))
  else
    m.roles[idx] = name
    emit_roles_changed(lm)
  end
end

function removerole(lm::ListModel, idx::Integer)
  m = get_julia_data(lm)
  if idx ∉ axes(rolenames(m),1)
    @error "Request to delete non-existing role $idx, aborting"
    return
  end

  println("removing role $(m.roles[idx])")

  deleteat!(m.roles, idx)
  deleteat!(m.getters, idx)
  deleteat!(m.setters, idx)

  @assert length(m.roles) == length(m.getters)

  emit_roles_changed(lm)
end

function removerole(lm::ListModel, name::AbstractString)
  m = get_julia_data(lm)
  idx = findfirst(isequal(name), m.roles)

  if isnothing(idx)
    @error "Request to delete non-existing role $name, aborting"
    return
  end
  removerole(lm,idx)
end

function setconstructor(lm::ListModel, constructor)
  get_julia_data(lm).constructor = constructor
end

# ListModel Julia interface
Base.getindex(lm::ListModel, idx::Int) = get_julia_data(lm).values[idx]
function Base.setindex!(lm::ListModel, value, idx::Int)
  lmdata = get_julia_data(lm)
  lmdata.values[idx] = value
  emit_data_changed(lm, idx-1, 1, StdVector(Int32.(axes(rolenames(lmdata), 1))))
end
Base.push!(lm::ListModel, val) = push_back(lm, val)
Base.size(lm::ListModel) = Base.size(get_julia_data(lm).values)
Base.length(lm::ListModel) = length(get_julia_data(lm).values)
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
