#include <QApplication>
#include <QFileInfo>
#include <QLibraryInfo>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickView>
#include <QtQml>
#include <QTimer>

#include "wrap_qml.hpp"

namespace qml_wrapper
{

namespace detail
{
// Helper to convert from Julia to a QVariant
template<typename CppT>
QVariant convert_to_qt(jl_value_t* v)
{
  if(jl_type_morespecific(jl_typeof(v), (jl_value_t*)cxx_wrap::julia_type<CppT>()))
  {
    return QVariant::fromValue(cxx_wrap::convert_to_cpp<CppT>(v));
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

// Generic conversion from QVariant to jl_value_t*
template<typename CppT>
jl_value_t* convert_to_julia(const QVariant& v)
{
  if(v.type() == qMetaTypeId<CppT>())
  {
    return cxx_wrap::box(v.template value<CppT>());
  }

  return nullptr;
}

// String
template<>
jl_value_t* convert_to_julia<QString>(const QVariant& v)
{
  if(v.type() == qMetaTypeId<QString>())
  {
    return cxx_wrap::convert_to_julia(v.template value<QString>().toStdString());
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

} // namespace detail
} // namespace qml_wrapper

namespace cxx_wrap
{

template<>
struct ConvertToCpp<QVariant, false, false, false>
{
  QVariant operator()(jl_value_t* julia_value) const
  {
    return qml_wrapper::detail::try_convert_to_qt<bool, float, double, int32_t, int64_t, uint32_t, uint64_t, QString>(julia_value);
  }
};

template<>
struct ConvertToJulia<QVariant, false, false, false>
{
  jl_value_t* operator()(const QVariant& v) const
  {
    return qml_wrapper::detail::try_convert_to_julia<bool, float, double, int32_t, int64_t, uint32_t, uint64_t, QString>(v);
  }
};

// Treat QString specially to make conversion transparent
template<> struct static_type_mapping<QString>
{
	typedef jl_value_t* type;
	static jl_datatype_t* julia_type() { return (jl_datatype_t*)jl_get_global(jl_base_module, jl_symbol("AbstractString")); }
	template<typename T> using remove_const_ref = cxx_wrap::remove_const_ref<T>;
};

template<>
struct ConvertToJulia<QString, false, false, false>
{
	jl_value_t* operator()(const QString& str) const
	{
		return jl_cstr_to_string(str.toStdString().c_str());
	}
};

template<>
struct ConvertToCpp<QString, false, false, false>
{
	QString operator()(jl_value_t* julia_string) const
	{
		if(julia_string == nullptr || !jl_is_byte_string(julia_string))
		{
			throw std::runtime_error("Any type to convert to string is not a string");
		}
		return QString(jl_bytestring_ptr(julia_string));
	}
};

// Treat QUrl specially to make conversion transparent
template<> struct static_type_mapping<QUrl>
{
	typedef jl_value_t* type;
	static jl_datatype_t* julia_type() { return (jl_datatype_t*)jl_get_global(jl_base_module, jl_symbol("AbstractString")); }
	template<typename T> using remove_const_ref = cxx_wrap::remove_const_ref<T>;
};

template<>
struct ConvertToJulia<QUrl, false, false, false>
{
	jl_value_t* operator()(const QUrl& url) const
	{
		return jl_cstr_to_string(url.toDisplayString().toStdString().c_str());
	}
};

template<>
struct ConvertToCpp<QUrl, false, false, false>
{
	QUrl operator()(jl_value_t* julia_string) const
	{
		if(julia_string == nullptr || !jl_is_byte_string(julia_string))
		{
			throw std::runtime_error("Any type to convert to string is not a string");
		}

    QString qstr(jl_bytestring_ptr(julia_string));
    QFileInfo finfo(qstr);
    if(!finfo.exists())
    {
      return QUrl(qstr);
    }
		return QUrl::fromLocalFile(qstr);
	}
};

} // namespace cxx_wrap

namespace qml_wrapper
{

// Create an application, taking care of argc and argv
jl_value_t* application()
{
  static int argc = 1;
  static std::vector<char*> argv_buffer;
  if(argv_buffer.empty())
  {
    argv_buffer.push_back(const_cast<char*>("julia"));
  }

  // Using create instead of new automatically attaches a finalizer that calls delete
  return cxx_wrap::create<QApplication>(argc, &argv_buffer[0]);
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
    julia_args[i] = cxx_wrap::convert_to_julia<QVariant>(args.at(i));
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
  else if(!jl_is_nothing(result))
  {
    result_var = cxx_wrap::convert_to_cpp<QVariant>(result);
    if(result_var.isNull())
    {
      qWarning() << "Julia method " << fname << " returns unsupported " << QString(cxx_wrap::julia_type_name((jl_datatype_t*)jl_typeof(result)).c_str());
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

JuliaSlot::JuliaSlot(jl_function_t* func) : m_function(func)
{
  assert(m_function != nullptr);
}

void JuliaSlot::callJulia()
{
  jl_call0(m_function);
}

} // namespace qml_wrapper

JULIA_CPP_MODULE_BEGIN(registry)
  using namespace cxx_wrap;

  Module& qml_module = registry.create_module("QML");

  qmlRegisterType<qml_wrapper::JuliaContext>("org.julialang", 1, 0, "JuliaContext");

  qml_module.add_abstract<QObject>("QObject");

  qml_module.add_type<qml_wrapper::JuliaContext>("JuliaContext", julia_type<QObject>());

  qml_module.add_type<QApplication>("QApplication", julia_type<QObject>());
  qml_module.method("application", qml_wrapper::application);
  qml_module.method("exec", QApplication::exec);

  qml_module.add_type<QQmlContext>("QQmlContext", julia_type<QObject>());
  qml_module.method("set_context_property", [](QQmlContext* ctx, const QString& name, jl_value_t* v)
  {
    if(ctx == nullptr)
    {
      qWarning() << "Can't set property " << name << " on null context";
      return;
    }
    ctx->setContextProperty(name, convert_to_cpp<QVariant>(v));
  });
  qml_module.method("set_context_property", [](QQmlContext* ctx, const QString& name, QObject* o)
  {
    if(ctx == nullptr)
    {
      qWarning() << "Can't set object " << name << " on null context";
      return;
    }
    ctx->setContextProperty(name, o);
  });

  qml_module.add_type<QQmlEngine>("QQmlEngine", julia_type<QObject>())
    .method("root_context", &QQmlEngine::rootContext);

  qml_module.add_type<QQmlApplicationEngine>("QQmlApplicationEngine", julia_type<QQmlEngine>())
    .constructor<QString>() // Construct with path to QML
    .method("load", static_cast<void (QQmlApplicationEngine::*)(const QString&)>(&QQmlApplicationEngine::load)); // cast needed because load is overloaded

  qml_module.add_type<qml_wrapper::JuliaSlot>("JuliaSlot", julia_type<QObject>())
    .constructor<jl_function_t*>()
    .method("call_julia", &qml_wrapper::JuliaSlot::callJulia);

  qml_module.add_type<QTimer>("QTimer", julia_type<QObject>());
  qml_module.method("connect_timeout", [](QTimer* timer, qml_wrapper::JuliaSlot* jslot)
  {
    assert(timer != nullptr);
    assert(jslot != nullptr);
    QObject::connect(timer, SIGNAL(timeout()), jslot, SLOT(callJulia()));
  });

  qml_module.method("qt_prefix_path", []() { return QLibraryInfo::location(QLibraryInfo::PrefixPath); });


  qml_module.add_abstract<QQuickItem>("QQuickItem");

  qml_module.add_abstract<QQuickWindow>("QQuickWindow")
    .method("content_item", &QQuickWindow::contentItem);

  qml_module.add_type<QQuickView>("QQuickView", julia_type<QQuickWindow>())
    .method("set_source", &QQuickView::setSource)
    .method("show", &QQuickView::show) // not exported: conflicts with Base.show
    .method("engine", &QQuickView::engine)
    .method("root_object", &QQuickView::rootObject);

  qml_module.add_type<QByteArray>("QByteArray").constructor<const char*>();
  qml_module.add_type<QQmlComponent>("QQmlComponent", julia_type<QObject>())
    .constructor<QQmlEngine*>()
    .method("set_data", &QQmlComponent::setData);
  qml_module.method("create", [](QQmlComponent& comp, QQmlContext* context)
  {
    if(!comp.isReady())
    {
      qWarning() << "QQmlComponent is not ready, aborting create";
      return;
    }

    QObject* obj = comp.create(context);
    if(context != nullptr)
    {
      obj->setParent(context); // setting this makes sure the new object gets deleted
    }
  });

  // Exports:
  qml_module.export_symbols("QApplication", "QQmlApplicationEngine", "QQmlContext", "set_context_property", "root_context", "JuliaContext", "JuliaSlot", "call_julia", "QTimer", "connect_timeout", "load", "qt_prefix_path", "QQuickView", "set_source", "engine", "QByteArray", "QQmlComponent", "set_data", "create", "QQuickItem", "content_item", "QQuickWindow", "QQmlEngine");
JULIA_CPP_MODULE_END
