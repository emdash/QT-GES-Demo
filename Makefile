LIBS=gstreamer-0.10\
	gst-editing-services-0.10\
	QtCore\
	QtGui\
	QtDeclarative\
	qt-gst-qml-sink\

ifndef QTMOBILITY_ROOT
QTMOBILITY_ROOT=/usr
endif

INCPATH= -I$(QTMOBILITY_ROOT)/include/QtMobility \
	 -I$(QTMOBILITY_ROOT)/include/QtMultimediaKit

LFLAGS= -L$(QTMOBILITY_ROOT)/lib/ -lQtMultimediaKit

SRCS=main.cpp\
	timeline.cpp\
	moc_timeline.cpp\
	pipeline.cpp\
	moc_pipeline.cpp

HEADERS=timeline.h\
	pipeline.h

CFLAGS=-g $(INCPATH) $(LFLAGS) `pkg-config --cflags --libs $(LIBS)`


all: $(SRCS) $(HEADERS) debug
	gcc $(CFLAGS) $(SRCS) -o ges-demo

moc_%.cpp: %.h
	moc $< -o $@

check:
	echo "not implemented"

debug:
	@echo "QTMOBILITY_ROOT is:" $(QTMOBILITY_ROOT)

install:
	cp launch.sh /usr/bin/ges-demo;\
        cp ges_demo.desktop /usr/share/applications
