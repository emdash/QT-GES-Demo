#define GST_USE_UNSTABLE_API

#include <ges/ges.h>
#include <QtGui>

int main(int argc, char **argv)
{
  QApplication app(argc, argv);
  gst_init(&argc, &argv);
  ges_init();
  return 0;
}
