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

    // timelinePipeline

    GESTimelinePipeline {
    	id:timelinePipeline
	surface: timelineSurface;
    }

    // the timeline

    ReorderableList {
        id:timeline
	visible: ! (timelinePipeline.playing || timelinePipeline.paused)
        // create an item for each element in a ListModel
        // later the ListModel can be replaced with a proxy for a GESTimeline

        model: GESTimeline {
	       pipeline: timelinePipeline;
        }

        anchors {
            top: screen.top
        }
    }
    
    // Preview

    GstVideoItem {
	id: preview
	surface: timelineSurface;
	size: Qt.size(screen.width, screen.height - toolBar.height);
	visible: timelinePipeline.playing || timelinePipeline.paused
    }

    // Editor for trimming clips

    Editor {
        id: editor
        anchors {
	    left: parent.left
	    right: parent.right
	    leftMargin: 12
	    rightMargin: 12
	    topMargin: 12
	    top: parent.top
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
	    id:timelineButtons
	    visible: timeline.visible
	    
            anchors {
                top: parent.top
		left: parent.left
		bottom: parent.bottom
                topMargin: 12
                rightMargin: 12
                leftMargin: 12
		bottomMargin: 12
            }

            Button {
                id:clipButton
                height: parent.height
                text: "Add Clip"

                onClicked: {
                    chooser.state = "visible"
                }
            }

            Button {
                id:titleButton
                height: parent.height
                text: "Add Title"
            }

            Button {
                id:transitionButton
                height: parent.height
                text: "Add Crossfade"

                onClicked: {
                }
            }

        }

	MediaControls {
	    visible: preview.visible
	    anchors {
	       left: parent.left
	       right: rightButtons.left
	       top: parent.top
	       bottom: parent.bottom
	       topMargin: 12
	       bottomMargin: 12
	       rightMargin: 12
	    }

	    pipeline: timelinePipeline
	}

	Row {
	    spacing: 12
	    id: rightButtons
	    anchors {
	        rightMargin: 12
	        topMargin: 12
	        bottomMargin: 12
	        top: parent.top
	        right: parent.right
		bottom: parent.bottom
            }

            Button {
                id:previewButton
                text: preview.visible ? "Back" : "Preview"
		height: parent.height

                onClicked: {
	           if (preview.visible) {
		      timelinePipeline.stop()
		   }
		   else {
		      timelinePipeline.preview();
		   }
                }
            }

	    Button {
	       id:quitButton
	       text: "Quit"
	       height: parent.height
	       onClicked: Qt.quit()
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
