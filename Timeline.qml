import Qt 4.7

Item {
    id:screen

    function formatDuration(duration) {
        return Math.floor(duration / 60) + "m " + (duration % 60) + "s"
    }

    // basic layout properties

    SystemPalette { id: activePalette }

    width: 720
    height: 490

    // background rectangle

    Rectangle {
        width: parent.width
        height: parent.height
        color: "black"
    }

    // the timeline

    ReorderableList {
        id:timeline
        // create an item for each element in a ListModel
        // later the ListModel can be replaced with a proxy for a GESTimeline

        model: ListModel {
            ListElement {
                uri: "pics/pic001.jpg"
                duration: 1
            }
        }

        anchors {
            top: screen.top
            bottom: toolBar.top
        }
    }

    // main toolbar

    Rectangle {
        id: toolBar
        height: 100

        color: activePalette.window

        anchors {
            bottom: screen.bottom
            left: screen.left
            right: screen.right
        }

        Row {
            spacing: 24

            anchors {
                fill: parent
                centerIn:parent
                topMargin: 12
                rightMargin: 12
                leftMargin: 12
            }

            Button {
                id:clipButton
                height: parent.height - 24
                text: "Add Clip"

                onClicked: {
                    chooser.state = "visible"
                }
            }

            Button {
                id:titleButton
                height: parent.height - 24
                text: "Add Title"
            }

            Button {
                id:transitionButton
                height: parent.height - 24
                text: "Add Crossfade"

                onClicked: {
                }
            }

            Button {
                id:previewButton
                height: parent.height - 24
                text: "Preview"

                onClicked: {
                }
            }
        }
        Text {
            id: status
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            text: formatDuration(0)
        }
    }

    // library of images to choose from
 
    ClipChooser {
        id:chooser
        state: "invisible"
        y: 0
        visible_y: toolBar.height
        height: screen.height - visible_y

        onItemChosen: {
            chooser.state = "invisible"
            if (item != null) {
                timeline.model.append({"uri": item, "duration": 1.0})
            }
        }

   }
}
