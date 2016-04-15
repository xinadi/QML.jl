import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
  title: "My Application"
  width: 640
  height: 480
  visible: true

  ColumnLayout {
    id: root
    spacing: 6
    anchors.fill: parent

    function do_plot()
    {
      if(jdisp === null)
        return;

      Julia.plotsin(jdisp, jdisp.width, jdisp.height, amplitude.value, frequency.value);
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignCenter

      Text {
        text: "Amplitude:"
      }

      Slider {
        id: amplitude
        value: 1.
        minimumValue: 0.1
        maximumValue: 5.
        onValueChanged: root.do_plot()
      }

      Text {
        text: "Frequency:"
      }

      Slider {
        id: frequency
        value: 1.
        minimumValue: 1.
        maximumValue: 50.
        onValueChanged: root.do_plot()
      }
    }

    JuliaDisplay {
      id: jdisp
      Layout.fillWidth: true
      Layout.fillHeight: true
      onHeightChanged: root.do_plot()
      onWidthChanged: root.do_plot()
    }
  }
}
