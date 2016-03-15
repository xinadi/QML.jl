#include <cpp_wrapper.hpp>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QString>

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

}

JULIA_CPP_MODULE_BEGIN(registry)
  using namespace cpp_wrapper;

  Module& qml_module = registry.create_module("QML");

  qml_module.add_type<QString>("QString")
    .constructor<const char*>();

  qml_module.add_type<QApplication>("QApplication");
  qml_module.method("application", qml_wrapper::application);
  qml_module.method("exec", QApplication::exec);

  qml_module.add_type<QQmlApplicationEngine>("QQmlApplicationEngine")
    .constructor<QString>(); // Construct with path to QML

JULIA_CPP_MODULE_END
