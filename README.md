# QML
Small example for starting an interface to [Qt5 QML](http://qt.io/). It uses the [`CppWrapper`](https://github.com/barche/CppWrapper) package to expose C++ classes. Current functionality allows loading a simple QML file.

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
e = QML.QQmlApplicationEngine(QML.QString("main.qml"))
QML.exec()
```
