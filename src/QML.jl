@windows_only ENV["QML_PREFIX_PATH"] = joinpath(Pkg.dir("QML"),"deps","usr")
using CxxWrap
wrap_modules(CxxWrap.lib_path(joinpath(Pkg.dir("QML"),"deps","usr","lib","libqmlwrap")))


@doc """
Module for building [Qt5 QML](http://doc.qt.io/qt-5/qtqml-index.html) graphical user interfaces for Julia programs.
Types starting with `Q` are equivalent of their Qt C++ counterpart, so they have no Julia docstring and we refer to
the [Qt documentation](http://doc.qt.io/qt-5/qtqml-index.html) for details instead.
""" QML

@doc """
Create a new [QApplication](http://doc.qt.io/qt-5/qapplication.html). This function generates
a writable `argc` and `argv` as required by Qt. The returned object must be manually finalized
before julia exit.
""" QML.application

@doc "Equivalent to [`QApplication::exec`](http://doc.qt.io/qt-5/qapplication.html#exec)" QML.exec

@doc """
Equivalent to [`QQmlContext::setContextProperty`](http://doc.qt.io/qt-5/qqmlcontext.html#setContextProperty).

This function is useful to expose Julia values to QML. Current properties can be fundamental numeric types,
strings and any `QObject`.

Example:
```julia
qml_engine = QQmlApplicationEngine()
root_ctx = root_context(qml_engine)
set_context_property(root_ctx, "my_property", 1)
```

You can now use `my_property` in QML and every time `set_context_property` is called on it the GUI gets notified.
""" QML.set_context_property

@doc "Equivalent to [`QQmlEngine::rootContext`](http://doc.qt.io/qt-5/qqmlengine.html#rootContext)" QML.root_context

@doc """
Equivalent to [`&QQmlApplicationEngine::load`](http://doc.qt.io/qt-5/qqmlapplicationengine.html#load-1). The first argument is
the application engine, the second is a string containing a path to the local QML file to load.
""" QML.load

@doc "Equivalent to `QLibraryInfo::location(QLibraryInfo::PrefixPath)`" QML.qt_prefix_path
@doc "Equivalent to `QQuickWindow::contentItem`" QML.content_item
@doc "Equivalent to `QQuickView::setSource`" QML.set_source
@doc "Equivalent to `QQuickView::show`" QML.show
@doc "Equivalent to `QQuickView::engine`" QML.engine
@doc "Equivalent to `QQuickView::rootObject`" QML.root_object

@doc """
Equivalent to `QQmlComponent::setData`. Use this to set the QML code for a QQmlComponent from a Julia string literal.
""" QML.set_data

@doc """
Equivalent to `QQmlComponent::create`. This creates a component defined by the QML code set using `set_data`.
It also makes sure the newly created object is parented to the given context.
""" QML.create
