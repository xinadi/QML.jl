# QML
Small example for starting an interface to [Qt5 QML](http://qt.io/). It uses the [`CxxWrap`](https://github.com/barche/CxxWrap.jl) package to expose C++ classes. Current functionality allows loading a simple QML file, calling Julia functions and run a background task during event loop idle time. See test/gui.jl for details, docs not fully up-to-date.

## Installation
This was tested on Linux and OS X. You need `cmake` in your path for installation to work.

First install [`CxxWrap`](https://github.com/barche/CxxWrap.jl) using `Pkg.add`. Compilation of `QML.jl` requires Qt to be reachable by CMake. If it is in a non-standard location, set the environment variable `CMAKE_PREFIX_PATH` to the base Qt directory (the one containing `lib` and `bin`) before executing the following commands:

```julia
Pkg.clone("https://github.com/barche/QML.jl.git")
Pkg.build("QML")
Pkg.test("QML")
```

You can check that the correct Qt version is used using the `qt_prefix_path()` function.

## Usage
### Loading a QML file
We support three methods of loading a QML file: `QQmlApplicationEngine`, `QQuickView` and `QQmlComponent`. These behave equivalently to the corresponding Qt classes.
#### QQmlApplicationEngine
To run the QML file `main.qml` from the current directory, execute:
```julia
using QML

app = QML.application()
e = QQmlApplicationEngine("main.qml")
QML.exec()
finalize(app)
```
The QML must have an `ApplicationWindow` as top component. It is also possible to default-construct the `QQmlApplicationEngine` and call `load` to load the QML separately:
```julia
qml_engine = QQmlApplicationEngine()
# ...
# set properties, ...
# ...
load(qml_engine, "main.qml")
```

This is useful to set context properties before loading the QML, for example.

To prevent a crash when exiting the program, the app object must be deleted manually, hence the call to `finalize(app)` in the above example.

#### QQuickView
The `QQuickView` creates a window, so it's not necessary to wrap the QML in `ApplicationWindow`. A QML file is loaded as follows:

```julia
app = QML.application()
qview = QQuickView()
set_source(qview, "main.qml")
QML.show(qview)
QML.exec()
```

#### QQmlComponent
Using `QQmlComponent` the QML code can be set from a Julia string wrapped in `QByteArray`:

```julia
qml_data = QByteArray("""
import ...

ApplicationWindow {
  ...
}
""")

app = QML.application()
qengine = QQmlEngine()
root_ctx = root_context(qengine)
qcomp = QQmlComponent(qengine)
set_data(qcomp, qml_data, "")
create(qcomp, root_ctx);

# Run the application
QML.exec()
```

## Interacting with Julia
Interaction with Julia happens through the following mechanisms:
* Call Julia functions from QML
* Read and set context properties from Julia and QML

## Calling Julia functions
In QML, include the Julia API:
```qml
import org.julialang 1.0
```

Then call a Julia function in QML using:
```qml
Julia.call("my_function")
```

To call a function with arguments, put them in a list:
```qml
Julia.call("my_function", [arg1, arg2])
```

## Context properties
The entry point for setting context properties is the root context of the engine:
```julia
root_ctx = root_context(qml_engine)
@qmlset root_ctx.property_name = property_value
```

This sets the QML context property named `property_name` to value `julia_value`. Any time the `@qmlset` macro is called on such a property, QML is notified of the change and updates any dependent values.

The value of a property can be queried from Julia like this:
```julia
@qmlget root_ctx.property_name
```

### Type conversion
Most fundamental types are converted implicitly. Mind that the default integer type in QML corresponds to `Int32` in Julia

### Composite types
Setting a composite type as a context property maps the type fields into a `JuliaObject`, which derives from `QQmlPropertyMap`. Example:

```julia
type JuliaTestType
  a::Int32
end

jobj = JuliaTestType(0.)
@qmlset root_ctx.julia_object = jobj
@qmlset root_ctx.julia_object.a = 2
@test @qmlget(root_ctx.julia_object.a) == 2
@test jobj.a == 2
```

Access from QML:
```qml
import QtQuick 2.0

Timer {
     interval: 0; running: true; repeat: false
     onTriggered: {
       julia_object.a = 1
       Qt.quit()
     }
 }
```

## Using QTimer
`QTimer` can be used to simulate running Julia code in the background. Exerepts from [`test/gui.jl`](test/gui.jl):

```julia
bg_counter = 0

function counter_slot()
  global bg_counter
  global root_ctx
  bg_counter += 1
  @qmlset root_ctx.bg_counter = bg_counter
end

timer = QTimer()
@qmlset root_ctx.timer = timer
@qmlset root_ctx.bg_counter = bg_counter
```

Use in QML like this:
```qml
import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    title: "My Application"
    width: 480
    height: 640
    visible: true

    Connections {
      target: timer
      onTimeout: Julia.call("counter_slot")
    }

    ColumnLayout {
      spacing: 6
      anchors.centerIn: parent

      Button {
          Layout.alignment: Qt.AlignCenter
          text: "Start counting"
          onClicked: timer.start()
      }

      Text {
          Layout.alignment: Qt.AlignCenter
          text: bg_counter.toString()
      }

      Button {
          Layout.alignment: Qt.AlignCenter
          text: "Stop counting"
          onClicked: timer.stop()
      }
  }
}

```

Note that QML provides the infrastructure to connect to the `QTimer` signal through the `Connections` item.
