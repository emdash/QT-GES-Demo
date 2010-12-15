LIBS=gstreamer-0.10\
	gstreamer-editing-services-plugins-0.10\
	QtCore\
	QtGui\
	QtDeclarative

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