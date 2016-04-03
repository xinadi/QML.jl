module QML

@windows_only ENV["QML_PREFIX_PATH"] = joinpath(Pkg.dir("QML"),"deps","usr")
using CxxWrap
wrap_module(CxxWrap.lib_path(joinpath(Pkg.dir("QML"),"deps","usr","lib","libqmlwrap")))

generic_property_get(ctx::QQmlContext, key::AbstractString) = context_property(ctx, key)
generic_property_get(o::JuliaObject, key::AbstractString) = value(o, key)

macro expand_dots(source_expr, func)
  if isa(source_expr, Expr) && source_expr.head == :(.)
    return :($func(@expand_dots($(esc(source_expr.args[1])), $func), $(string(source_expr.args[2].args[1]))))
  end
  return esc(source_expr)
end

macro qmlget(dots_expr)
  :(@expand_dots($(esc(dots_expr)), generic_property_get))
end

macro qmlset(assign_expr)
  :(generic_property_set(@expand_dots($(assign_expr.args[1].args[1]), generic_property_get), $(string(assign_expr.args[1].args[2].args[1])), $(assign_expr.args[2])))
end

export @qmlget

@doc """
Module for building [Qt5 QML](http://doc.qt.io/qt-5/qtqml-index.html) graphical user interfaces for Julia programs.
Types starting with `Q` are equivalent of their Qt C++ counterpart, so they have no Julia docstring and we refer to
the [Qt documentation](http://doc.qt.io/qt-5/qtqml-index.html) for details instead.
""" QML

@doc """
Create a new [QApplication](http://doc.qt.io/qt-5/qapplication.html). This function generates
a writable `argc` and `argv` as required by Qt. The returned object must be manually finalized
before julia exit.
""" application

@doc "Equivalent to [`QApplication::exec`](http://doc.qt.io/qt-5/qapplication.html#exec)" exec

@doc """
Equivalent to [`QQmlContext::setContextProperty`](http://doc.qt.io/qt-5/qqmlcontext.html#setContextProperty).

This function is useful to expose Julia values to  Current properties can be fundamental numeric types,
strings and any `QObject`.

Example:
```julia
qml_engine = QQmlApplicationEngine()
root_ctx = root_context(qml_engine)
set_context_property(root_ctx, "my_property", 1)
```

You can now use `my_property` in QML and every time `set_context_property` is called on it the GUI gets notified.
""" set_context_property

@doc "Equivalent to [`QQmlEngine::rootContext`](http://doc.qt.io/qt-5/qqmlengine.html#rootContext)" root_context

@doc """
Equivalent to [`&QQmlApplicationEngine::load`](http://doc.qt.io/qt-5/qqmlapplicationengine.html#load-1). The first argument is
the application engine, the second is a string containing a path to the local QML file to load.
""" load

@doc "Equivalent to `QLibraryInfo::location(QLibraryInfo::PrefixPath)`" qt_prefix_path
@doc "Equivalent to `QQuickWindow::contentItem`" content_item
@doc "Equivalent to `QQuickView::setSource`" set_source
@doc "Equivalent to `QQuickView::show`" show
@doc "Equivalent to `QQuickView::engine`" engine
@doc "Equivalent to `QQuickView::rootObject`" root_object

@doc """
Equivalent to `QQmlComponent::setData`. Use this to set the QML code for a QQmlComponent from a Julia string literal.
""" set_data

@doc """
Equivalent to `QQmlComponent::create`. This creates a component defined by the QML code set using `set_data`.
It also makes sure the newly created object is parented to the given context.
""" create

end
