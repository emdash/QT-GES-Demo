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
	    	   ListElement {
	    	   	       thumb: "media/thumbnails/20100510_007.png"
			       uri: "media/20100510_007.jpg"
	           }

		   ListElement {
		   	       thumb: "media/thumbnails/20100512_003.png"
			       uri: "media/20100512_003.png"
		   }

		   ListElement {
		   	       thumb: "media/thumbnails/AVRO1036K.png"
			       uri: "media/AVRO1036K.wmv"
	           }

		   ListElement {
		   	       thumb: "media/thumbnails/small-mvi_0009.png"
			       uri: "media/small-mvi_0009.avi"
	           }
	    }
            delegate: Image {
                width: 100
                height: 100
                source: thumb
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
