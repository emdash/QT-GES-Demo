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

    ListView {
        id:items
        spacing: 5
	orientation: ListView.Horizontal

	anchors.fill: parent

	model: ListModel {
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
	    width: 200
	    height: 200
	    source: "media/thumbnails/" + uri + ".jpg"
	    fillMode: Image.PreserveAspectFit

	    MouseArea {
		anchors.fill: parent
		onClicked: {
		    itemChosen("media/" + uri)
		}
	    }
       }
    }
}
