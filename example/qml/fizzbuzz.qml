import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.julialang 1.0

ApplicationWindow {
    visible: true
    width: 200
    height: 200
    title: "FizzBuzz"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        TextField {
            placeholderText: "Input"
            text: ""
            id: textField
            onTextChanged: Julia.call("do_fizzbuzz", [textField.text])
        }
        Text {
            id: text
            text: fizzbuzz.result
        }
        Button {
            text: 'Quit'
            onClicked: Qt.quit()
        }
        Text {
            id: lastFizzBuzz
            text: "No fizzbuzz yet!"
        }
    }

    JuliaSignals {
      signal fizzBuzzFound(int fizzbuzzvalue)
      onFizzBuzzFound: lastFizzBuzz.text = fizzbuzzvalue
    }
}
