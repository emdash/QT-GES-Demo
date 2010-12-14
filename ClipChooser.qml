import Qt 4.7

Item {
    id: root

    signal itemChosen (string item);
    property int visible_y

    anchors {
        left: parent.left
        right: parent.right
    }


    Grid {
        id:items
        spacing: 5
        Repeater {
            model: ListModel {
                ListElement { uri: "pics/pic001.jpg" }
                ListElement { uri: "pics/pic002.jpg" }
                ListElement { uri: "pics/pic003.jpg" }
                ListElement { uri: "pics/pic004.jpg" }
            }
            delegate: Image {
                width: 100
                height: 100
                source: uri
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    // animate "falling" from the top down when state changes to visible

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: chooser 
                y: visible_y
            }
        },

        State {
            name: "invisible"
            PropertyChanges {
                target: chooser
                y: -chooser.height
            }
        }
    ]

    transitions: [
        Transition {
            from: "invisible"
            to: "visible"
            SpringAnimation { 
                properties: "y"
                damping: 0.2
                spring: 2
            }
        },

        Transition {
            to: "invisible"
            from: "visible"
            SpringAnimation { 
                properties: "y"
                damping: 0.2
                spring: 2
            }
        }
    ]

    MouseArea {
        anchors.fill: parent
        onClicked: { 
            itemChosen(items.childAt(mouse.x, mouse.y).source)
        }
    }
}
