#include <cpp_wrapper.hpp>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "wrap_qml.hpp"

namespace qml_wrapper
{

// Create an application, taking care of argc and argv
QApplication* application()
{
  static int argc = 1;
  static std::vector<char*> argv_buffer;
  if(argv_buffer.empty())
  {
    argv_buffer.push_back(const_cast<char*>("julia"));
  }
  QApplication* app = new QApplication(argc, &argv_buffer[0]);
  return app;
}

QVariant JuliaContext::call(const QString& fname)
{
  jl_function_t *func = jl_get_function(jl_current_module, fname.toStdString().c_str());
  if(func == nullptr)
  {
    qWarning() << "Julia method " << fname << " was not found.";
    return 0.;
  }

  QVariant var;

  jl_value_t* result;
  JL_GC_PUSH1(&result);
  result = jl_call0(func);
  if(jl_is_float64(result))
  {
    var = QVariant::fromValue(jl_unbox_float64(result));
  }
  else if(jl_is_int64(result))
  {
    var = QVariant::fromValue(jl_unbox_int64(result));
  }
  JL_GC_POP();
  if(var.isNull())
  {
    qWarning() << "Julia method " << fname << " returns a " << QString(cpp_wrapper::julia_type_name((jl_datatype_t*)jl_typeof(result)).c_str());
  }
  return var;
}

}

JULIA_CPP_MODULE_BEGIN(registry)
  using namespace cpp_wrapper;

  Module& qml_module = registry.create_module("QML");

  qmlRegisterType<qml_wrapper::JuliaContext>("org.julialang", 1, 0, "JuliaContext");

  qml_module.add_type<QString>("QString")
    .constructor<const char*>();

  qml_module.add_type<QApplication>("QApplication");
  qml_module.method("application", qml_wrapper::application);
  qml_module.method("exec", QApplication::exec);

  qml_module.add_type<QQmlApplicationEngine>("QQmlApplicationEngine")
    .constructor<QString>(); // Construct with path to QML

JULIA_CPP_MODULE_END
