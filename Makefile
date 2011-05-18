LIBS=gstreamer-0.10\
	gst-editing-services-0.10\
	QtCore\
	QtGui\
	QtDeclarative\
	qt-gst-qml-sink\

SRCS=main.cpp\
	timeline.cpp\
	moc_timeline.cpp

HEADERS=timeline.h

CFLAGS=-g `pkg-config --cflags --libs $(LIBS)`


all: $(SRCS) $(HEADERS)
	gcc $(CFLAGS) $(SRCS) -o ges-demo

moc_%.cpp: %.h
	moc $< -o $@

check:
	echo "not implemented"