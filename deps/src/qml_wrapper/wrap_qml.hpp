#ifndef WRAP_QML_H
#define WRAP_QML_H

#include <string>
#include <map>

#include <cxx_wrap.hpp>

#include <QObject>
#include <QQmlPropertyMap>
#include <QString>
#include <QVariant>

namespace qml_wrapper
{

/// Object to place in the QML context to gain access to Julia from QML
class JuliaContext : public QObject
{
  Q_OBJECT
public slots:

  // Call a Julia function that takes any number of arguments as a list
  QVariant call(const QString& fname, const QVariantList& arg);

  // Call a Julia function that takes no arguments
  QVariant call(const QString& fname);
};

/// Provides a slot for a zero-argument function
class JuliaSlot : public QObject
{
  Q_OBJECT
public:
  JuliaSlot(jl_function_t* func);
public slots:
  void callJulia();

private:
  jl_function_t* m_function;
};

/// Wrap Julia composite types
class JuliaObject : public QQmlPropertyMap
{
  Q_OBJECT
public:
  JuliaObject(jl_value_t* julia_object, QObject* parent = 0);
private slots:
  void onValueChanged(const QString &key, const QVariant &value);
private:
  jl_value_t* m_julia_object;
  std::map<std::string, uint32_t> m_field_mapping;
};

}

#endif
