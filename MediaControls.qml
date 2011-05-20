import Qt 4.7
import GES 1.0
import Gst 1.0

Item {
    id: root

    property GESTimelinePipeline pipeline
     
    Button {
       id:pauseButton
       text: pipeline.playing ? "Pause" : "Play"
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

    Slider {
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

	   MouseArea {
		anchors.fill: parent
		onPositionChanged: {
		   pipeline.seek(
			    Math.max(0,
				 Math.min(parent.max_duration,
					  (mouse.x / width) * parent.max_duration)))
		}
	   }
    }


}