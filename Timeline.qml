/* GStreamer Editing Services
 * Copyright (C) 2010 Brandon Lewis <brandon.lewis@collabora.co.uk>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

import Qt 4.7
import GES 1.0
import Gst 1.0

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
	    surface: timelineSurface;
        }

        anchors {
            top: screen.top
            bottom: toolBar.top
        }
    }

    // Preview

    GstVideoItem {
    	id: preview
	surface: timelineSurface;
	size: Qt.size(320, 240);
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
	    id:buttons

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

	Button {
	   id:quitButton
	   height: buttons.height - 24
	   text: "Quit"
	   onClicked: Qt.quit()
	   anchors {
	       rightMargin: 12
	       top: buttons.top
	       right: buttons.right
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
