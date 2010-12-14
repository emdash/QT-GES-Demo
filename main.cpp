#define GST_USE_UNSTABLE_API

#include <ges/ges.h>
#include <QtCore>
#include <QtGui>
#include <QtDeclarative>
#include "timeline.h"

int main(int argc, char **argv)
{
  QApplication app(argc, argv);
  gst_init(&argc, &argv);
  ges_init();

  qmlRegisterType<Timeline>("GES", 1, 0, "GESTimeline");

  QDeclarativeView view;
  view.setSource(QUrl::fromLocalFile("Timeline.qml"));
  view.show();
  
  return app.exec();
}
