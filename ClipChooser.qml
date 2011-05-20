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
	    	   id:data
                    ListElement { uri: "20100516_005.mp4.avi" }
                    ListElement { uri: "20100516_007.mp4.avi" }
                    ListElement { uri: "20100516_015.jpg" }
                    ListElement { uri: "20100525_003.mp4.avi" }
                    ListElement { uri: "20100818_006.mp4.avi" }
                    ListElement { uri: "20100818_011.mp4.avi" }
                    ListElement { uri: "20101011_001.mp4.avi" }
                    ListElement { uri: "20101105_002.mp4.avi" }
                    ListElement { uri: "20110101_002.mp4.avi" }
                    ListElement { uri: "20110101_003.mp4.avi" }
                    ListElement { uri: "20110101_004.mp4.avi" }
                    ListElement { uri: "20110101_006.mp4.avi" }
                    ListElement { uri: "20110101_007.mp4.avi" }
                    ListElement { uri: "20110202_008.jpg" }
                    ListElement { uri: "20110202_023.jpg" }
                    ListElement { uri: "20110216_004.jpg" }
                    ListElement { uri: "20110218_010.jpg" }
                    ListElement { uri: "20110227_002.jpg" }
           }

           delegate: Image {
	            property int position: index
                width: 100
                height: 100
                source: "media/thumbnails/" + uri + ".jpg"
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
	    var idx = items.childAt(mouse.x, mouse.y).position
	    var obj = data.get(idx)
            itemChosen("media/" + obj.uri)
        }
    }
}
