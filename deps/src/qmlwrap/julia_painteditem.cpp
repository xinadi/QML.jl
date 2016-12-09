#include <functions.hpp>

#include <QPainter>

#include "julia_api.hpp"
#include "julia_painteditem.hpp"
#include "julia_object.hpp"

namespace qmlwrap
{

JuliaPaintedItem::JuliaPaintedItem(QQuickItem *parent) : QQuickPaintedItem(parent)
{
  if(qgetenv("QSG_RENDER_LOOP") != "basic")
  {
    qCritical() << "QSG_RENDER_LOOP must be set to basic to use JuliaPaintedItem. Add the line\n" << "ENV[\"QSG_RENDER_LOOP\"] = \"basic\"" << "\nat the top of your Julia program";
  }
}

void JuliaPaintedItem::paint(QPainter* painter)
{
  m_callback(painter);
}

void JuliaPaintedItem::setPaintFunction(cxx_wrap::SafeCFunction f)
{
  m_callback = cxx_wrap::make_function_pointer<void(void*)>(f);
}

} // namespace qmlwrap