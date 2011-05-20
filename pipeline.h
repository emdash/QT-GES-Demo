
#ifndef __PIPELINE_H__
#define __PIPELINE_H__

#include <QObject>
#include <QtCore>
#include <QtGstQmlSink/qmlvideosurfacegstsink.h>
#include <QtGstQmlSink/qmlpaintervideosurface.h>

#define GST_USE_UNSTABLE_API
#include <ges/ges.h>

class Pipeline : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool playing READ playing NOTIFY playingChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)
    Q_PROPERTY(double position READ position NOTIFY positionChanged)
    Q_PROPERTY(double duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(QmlPainterVideoSurface * surface READ surface WRITE setSurface)
    
 public:
  Pipeline();
  ~Pipeline();
  bool playing();
  bool paused();
  double position ();
  double duration ();
  QmlPainterVideoSurface * surface();
  void setSurface (QmlPainterVideoSurface * surface);
  void setSource (GstElement * source);
  Q_INVOKABLE void preview();
  Q_INVOKABLE void pause();
  Q_INVOKABLE void stop();
  Q_INVOKABLE void seek(double position);
  Q_INVOKABLE void setUri(QString uri);

 signals:
  void playingChanged(bool isPlaying);
  void pausedChanged(bool isPaused);
  void positionChanged(double position);
  void durationChanged(double duration);
  
 public slots:
  void queryPositionDuration();
  void seekToPosition();

 private:
  void privSetState(GstState state);
  
  QTimer * queryTimer;
  QTimer * seekTimer;
  QElapsedTimer * lastSeek;
  gint64 mPosition;
  gint64 mDuration;
  gint64 mSeekRequest;

  bool isUriSource;
  
  GstElement *src;
  GstElement *pipeline;
  GstElement *vq;
  GstElement *aq;
  GstElement *vsnk;
  GstElement *asnk;
  GstElement *aconv;
  GstElement *csp;
  GstState m_state;
  
  friend void bus_message_cb (GstBus *, GstMessage *, Pipeline *);
  friend void pipeline_pad_added_cb (GstElement *, GstPad *, Pipeline *);
  QmlPainterVideoSurface *mSurface;
};

#endif
