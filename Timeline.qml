import Qt 4.7
import GES 1.0

Item {
    id:screen

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

        model: GESTimeline {
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
                text: timeline.model.playing ? "Pause" : "Preview"

                onClicked: {
	           if (timeline.model.playing) {
		      timeline.model.pause()
		   }
		   else {
		     timeline.model.preview();
		   }
                }
            }

	    Button {
	       id:stopButton
	       height: parent.height - 24
	       text: "Stop"
	       onClicked: timeline.model.stop()
	    }
        }
        Text {
            id: status
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            text: ""
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
	    console.log(item)
            if (item != null) {
                timeline.model.appendPath(item)
            }
        }

   }
}
