#define GST_USE_UNSTABLE_API

#include <ges/ges.h>

int main(int argc, char **argv)
{
  gst_init(&argc, &argv);
  ges_init();
  return 0;
}
