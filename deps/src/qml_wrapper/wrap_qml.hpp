#ifndef WRAP_QML_H
#define WRAP_QML_H

#include <QObject>
#include <QString>
#include <QVariant>

namespace qml_wrapper
{

/// Object to place in the QML context to gain access to Julia from QML
class JuliaContext : public QObject
{
  Q_OBJECT
public slots:
  // Call a Julia function that takes no arguments and returns a double
  QVariant call(const QString& fname);
};

}

#endif
