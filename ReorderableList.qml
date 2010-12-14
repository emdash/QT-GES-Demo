import Qt 4.7

Item {
    id:root

    width: items.model.count * childWidth
    property alias model: items.model

    // where should this go?

    property int childWidth: 250
    property int childHeight: 250
    property int rows: height / childHeight

    // layout functions
  
    function pointToIndex(x, y) {
       var row, col
       col = Math.floor(x / childWidth)
       return col
    }

    function indexToY(index) {
        return 0
    }

    function indexToX(index) {
        return index * childWidth
    }

    // implement scrolling

    MouseArea {
        anchors.fill: parent
        property double mdown;

        onPressed: {
            var point
            point = mapToItem(screen, mouse.x, mouse.y)
            mdown = point.x - parent.x
        }

        onPositionChanged: {
            var point = mapToItem(screen, mouse.x, mouse.y)
            var max = 0
            var min = -Math.max(0, width - screen.width)
            parent.x = Math.max(min, Math.min(max,
                point.x - mdown))
        }
    }

    // auto-scroll when items are added to the model

    Connections {
        target:items.model 
        onCountChanged: {
            root.x = -Math.max(0, indexToX(items.model.count)
                - screen.width)
        }
    }

    // smooth scrolling

    Behavior on x {
        SmoothedAnimation {
            velocity: 800
            duration: 500
        }
    }

    // a repeater to supply the items

    Repeater {
        id:items

        delegate: Item {
            id: container
            width: childWidth
            height: childHeight

            property bool completed: false
            Component.onCompleted: {
                completed = true
            }

            opacity: completed ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                }
            }

            // we calculate the coordinates manually

            x: indexToX(index)
            y: indexToY(index)

            // animate changes to position. 1/8 second seems to be about
            // right.

            Behavior on x {
                NumberAnimation {
                    duration: 125
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 125
                }
            }

            Clip {id:child}

            // this implements drag-and-drop re-ordering of the timeline.

            MouseArea {
                anchors.fill: parent
                property int cur
                property double mx
                property double my

                onPressed: {
                    var point, child_loc 
                    point = mapToItem(timeline, mouse.x, mouse.y)

                    point = mapToItem(timeline, mouse.x, mouse.y)
                    child_loc = mapToItem(timeline, child.x, child.y)
                    mx = point.x - child_loc.x
                    my = point.y - child_loc.y
                }

                onReleased: {
                    child.parent = container 
                    hand.visible = false
                }

                onPositionChanged: {
                    var point
                    hand.visible = true
                    child.parent = hand
                    point = mapToItem(timeline, mouse.x, mouse.y)
                    cur = pointToIndex(point.x, point.y)
                    mouse.accepted = true
                    hand.x = point.x - mx
                    hand.y = point.y - my
                }

                onCurChanged: {
                    if ((0 <= cur) && (cur < items.model.count)) {
                        items.model.move(index, cur, 1)
                    }
                }
            }

        }
    }

   // item used for drag-and-drop positioning

   Item {
       id: hand
       width: childWidth
       height: childHeight
       visible: false
   }
}
