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

  // Generic conversion from QVariant to jl_value_t*
  template<typename CppT>
  jl_value_t* convert_to_julia(const QVariant& v)
  {
    if(v.type() == qMetaTypeId<CppT>())
    {
      return cpp_wrapper::box(v.template value<CppT>());
    }

    return nullptr;
  }

  // String
  template<>
  jl_value_t* convert_to_julia<QString>(const QVariant& v)
  {
    if(v.type() == qMetaTypeId<QString>())
    {
      return cpp_wrapper::convert_to_julia(v.template value<QString>().toStdString());
    }

    return nullptr;
  }

  // Try conversion for a list of types
  template<typename... TypesT>
  jl_value_t* try_convert_to_julia(const QVariant& v)
  {
    for(auto&& jval : {convert_to_julia<TypesT>(v)...})
    {
      if(jval != nullptr)
        return jval;
    }

    qWarning() << "returning null julia value for variant of type " << v.typeName();
    return nullptr;
  }

  jl_value_t* convert_to_julia(const QVariant& v)
  {
    return try_convert_to_julia<double, int64_t, QString>(v);
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

QVariant JuliaContext::call(const QString& fname, const QVariantList& args)
{
  jl_function_t *func = jl_get_function(jl_current_module, fname.toStdString().c_str());
  if(func == nullptr)
  {
    qWarning() << "Julia method " << fname << " was not found.";
    return QVariant();
  }

  QVariant result_var;

  const int nb_args = args.size();

  jl_value_t* result = nullptr;
  jl_value_t** julia_args;
  JL_GC_PUSH1(&result);
  JL_GC_PUSHARGS(julia_args, nb_args);

  // Process arguments
  for(int i = 0; i != nb_args; ++i)
  {
    julia_args[i] = detail::convert_to_julia(args.at(i));
    if(julia_args[i] == nullptr)
    {
      qWarning() << "Julia argument type for function " << fname << " is unsupported:" << args[0].typeName();
      JL_GC_POP();
      JL_GC_POP();
      return QVariant();
    }
  }

  // Do the call
  result = jl_call(func, julia_args, nb_args);

  // Process result
  if(result == nullptr)
  {
    qWarning() << "Null result calling Julia function " << fname;
  }
  else
  {
    result_var = detail::convert_to_qt(result);
    if(result_var.isNull())
    {
      qWarning() << "Julia method " << fname << " returns unsupported " << QString(cpp_wrapper::julia_type_name((jl_datatype_t*)jl_typeof(result)).c_str());
    }
  }
  JL_GC_POP();
  JL_GC_POP();

  return result_var;
}

QVariant JuliaContext::call(const QString& fname)
{
  return call(fname, QVariantList());
}

} // namespace qml_wrapper

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
