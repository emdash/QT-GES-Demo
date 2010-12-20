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
    // image and label

    anchors {
        fill: parent
    }

    Image {
        id:image
        anchors {
            right: parent.right
            left: parent.left
            rightMargin: 2
            leftMargin: 2
            top: parent.top
            bottom: durationLabel.top
        }
        source: uri
        sourceSize.width: parent.width 
        fillMode: Image.PreserveAspectFit
    }

    Button {
		   anchors {
		   		   right: parent.right
				   top: parent.top
				   rightMargin: 12
				   topMargin: 12
		   }
		   width: 25
		   height: 25
		   text: "X"

		   onClicked: {
					  timeline.model.remove(index)
		   }
    }

    Text {
        id: durationLabel
        text: duration
        height: 25
        color: "white"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
