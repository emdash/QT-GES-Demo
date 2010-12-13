LIBS=gstreamer-0.10 QtCore QtGui
SRCS=main.cpp

CFLAGS=`pkg-config --cflags --libs $(LIBS)`

all: $(SRCS) $(HEADERS)
	gcc $(CFLAGS) $(SRCS) -o ges-demo

check:
	echo "not implemented"