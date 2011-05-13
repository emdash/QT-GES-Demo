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
	    	   ListElement {
	    	   	   thumb: "media/thumbnails/20100510_007.png"
			       uri: "media/20100510_007.jpg"
	           }

               ListElement {
                   thumb: "media/thumbnails/20100512_003.png"
                   uri: "media/20100512_003.jpg"
               }

	    	   ListElement {
		   	       thumb: "media/thumbnails/small-mvi_0009.png"
			       uri: "media/small-mvi_0009.avi"
	           }
    
	    	   ListElement {
		   	       thumb: "media/thumbnails/mid-Caterpilla_345C_Longfront_01.ogv.jpg"
		   	       uri: "media/Caterpilla_345C_Longfront_01.ogv"
	    	    }

		       ListElement {
			       thumb: "media/thumbnails/mid-Typing_example.ogv.jpg"
			       uri: "media/Typing_example.ogv"
		       }
           }

           delegate: Image {
	            property int position: index
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
	    var idx = items.childAt(mouse.x, mouse.y).position
	    var obj = data.get(idx)
            itemChosen(obj.uri)
        }
    }
}
