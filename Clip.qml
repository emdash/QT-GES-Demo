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

    Text {
        id: durationLabel
        text: duration
        height: 25
        color: "white"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
