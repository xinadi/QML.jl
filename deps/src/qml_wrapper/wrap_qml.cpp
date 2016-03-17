#include <cpp_wrapper.hpp>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "wrap_qml.hpp"

namespace qml_wrapper
{

namespace detail
{
  // Helper to convert from Julia to a QVariant
  template<typename CppT>
  QVariant convert_to_qt(jl_value_t* v)
  {
    if(jl_type_morespecific(jl_typeof(v), (jl_value_t*)cpp_wrapper::julia_type<CppT>()))
    {
      return QVariant::fromValue(cpp_wrapper::convert_to_cpp<CppT>(v));
    }

    return QVariant();
  }

  // String overload
  template<>
  QVariant convert_to_qt<QString>(jl_value_t* v)
  {
    if(jl_type_morespecific(jl_typeof(v), (jl_value_t*)cpp_wrapper::julia_type<const char*>()))
    {
      return QVariant::fromValue(QString(cpp_wrapper::convert_to_cpp<const char*>(v)));
    }

    return QVariant();
  }

  // Try conversion for a list of types
  template<typename... TypesT>
  QVariant try_convert_to_qt(jl_value_t* v)
  {
    for(auto&& variant : {convert_to_qt<TypesT>(v)...})
    {
      if(!variant.isNull())
        return variant;
    }

    return QVariant();
  }

  // Helper to convert from Julia to a QVariant. Tries a few common types
  QVariant convert_to_qt(jl_value_t* v)
  {
    return try_convert_to_qt<double, int64_t, QString>(v);
  }
}

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
  var = detail::convert_to_qt(result);
  JL_GC_POP();
  if(var.isNull())
  {
    qWarning() << "Julia method " << fname << " returns unsupported " << QString(cpp_wrapper::julia_type_name((jl_datatype_t*)jl_typeof(result)).c_str());
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

  // Exports:
  qml_module.export_symbols("QString", "QApplication", "QQmlApplicationEngine");
JULIA_CPP_MODULE_END
