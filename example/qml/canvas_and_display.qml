import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    ColumnLayout {
	id: root
	anchors.fill: parent
	RowLayout {
	    ColumnLayout {
		CheckBox {
		    text: "do this"
		    onClicked: {
			do_this = checked
		    }
		}
		NamedSlider {
		    text: "frequency"; from: 1; to: 10
		    onValueChanged: frequency = value
		}
		NamedSlider {
		    text: "amplitude"; from: 1; to: 5
		    onValueChanged: amplitude = value
		}
		NamedSlider {
		    text: "diameter"; from: 50; to: 100
		    onValueChanged: diameter = value
		}
	    }
	    JuliaDisplay {
		id: jdisp1
		Layout.minimumHeight: 80
		Layout.minimumWidth: 150
		Layout.fillWidth: true
		Layout.fillHeight: true
		onHeightChanged:  init_plot()
		onWidthChanged:  init_plot()
		function init_plot() { Julia.init_jdisp1(jdisp1, width, height) }
	    }
	    JuliaDisplay {
		id: jdisp2
		Layout.minimumHeight: 100
		Layout.minimumWidth: 300
		Layout.fillWidth: true
		Layout.fillHeight: true
		onHeightChanged:  init_plot()
		onWidthChanged:  init_plot()
		function init_plot() { Julia.init_jdisp2(jdisp2, width, height) }
	    }
	}
	RowLayout {
	    Frame {
		GridLayout {
		    columns: 2   // name, value
		    Text { text: "foinkle"}
		    Text { text: foinkle }
		    Text { text: "sheesh boogles"}
		    Text { text: "1.62 GHz" }
		}
	    }
	    JuliaCanvas {
		id: circle_canvas
		paintFunction: paint_cfunction
		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.minimumWidth: 100
		Layout.minimumHeight: 100
	    }
	}	    
    }
    JuliaSignals {
	signal updateCircle()
	onUpdateCircle: circle_canvas.update()
    }
}

