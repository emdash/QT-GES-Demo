import Qt 4.7
import GES 1.0
import Gst 1.0

Item {
    id: root

    property GESTimelinePipeline pipeline
    property alias inPoint: slider.inPoint
    property alias outPoint: slider.outPoint
    property alias showEditPoints: slider.showEditPoints
    property bool  durationOnly: false 
     
    Button {
       id:pauseButton
       text: pipeline.playing ? "Pause" : "Play"
       visible: !durationOnly
       onClicked: {
	  if (pipeline.playing) {
	     pipeline.pause()
	  } else {
	     pipeline.preview()
	  }
       }

       anchors {
          top: parent.top
	  bottom: parent.bottom
	  left: parent.left
	  rightMargin: 6
       }
    }

    function seek (pos) {
	pipeline.seek(
		Math.max(0,
		     Math.min(pipeline.duration, pos)))
    }

    Slider {
           id: slider
	   anchors {
		    top: parent.top
		    bottom: parent.bottom
		    right: parent.right
		    left: pauseButton.right
		    topMargin: 10
		    bottomMargin: 10
		    leftMargin: 6
	   }

	   max_duration: pipeline.duration
	   position: pipeline.position
	   visible: !durationOnly

	   MouseArea {
		anchors.fill: parent
		onPositionChanged: { seek((mouse.x / width) * pipeline.duration) }
	   }
    }

    Joggle {
         id: joggle

	 anchors {
	     top: parent.top
	     bottom: parent.bottom
	     right: parent.right
	     left: parent.left
	 }

	 visible: durationOnly
	 position: outPoint / 10000000
	 
	 onPositionChanged: {
	     if (durationOnly) {
	          outPoint = position * 10000000
	     }
	 }
    }
}