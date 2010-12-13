#define GST_USE_UNSTABLE_API

#include <ges/ges.h>
#include <QtGui>
#include <QtDeclarative>

int main(int argc, char **argv)
{
  QApplication app(argc, argv);
  gst_init(&argc, &argv);
  ges_init();
  
  QDeclarativeView view;
  view.setSource(QUrl::fromLocalFile("Timeline.qml"));
  view.show();
  
  return app.exec();
}
