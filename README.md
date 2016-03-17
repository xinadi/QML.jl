# QML
Small example for starting an interface to [Qt5 QML](http://qt.io/). It uses the [`CppWrapper`](https://github.com/barche/CppWrapper) package to expose C++ classes. Current functionality allows loading a simple QML file and calling a Julia function without arguments returning either a `FLoat64` or an `Int64`.

## Installation
This was tested on Linux and OS X. You need `cmake` in your path for installation to work.

First install [`CppWrapper`](https://github.com/barche/CppWrapper). Compilation of `QML.jl` requires Qt to be reachable by CMake. If it is in a non-standard location, set the environment variable `CMAKE_PREFIX_PATH` to the base Qt directory before executing the following commands:

```julia
Pkg.clone("https://github.com/barche/QML.jl.git")
Pkg.build("QML")
Pkg.test("QML")
```
## Usage

To run the QML file `main.qml` from the current directory, execute:
```julia
using QML

app = QML.application()
e = QQmlApplicationEngine(QString("main.qml"))
QML.exec()
```

In QML, include the `JuliaContext` component:
```qml
JuliaContext {
  id: julia
}
```

Then call a Julia function in QML using:
```qml
julia.call("my_function")
```

To call a function with arguments, put them in a list:
```qml
julia.call("my_function", [arg1, arg2])
```

See test for complete example.
