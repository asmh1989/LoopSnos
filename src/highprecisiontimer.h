// highprecisiontimer.h
#ifndef HIGHPRECISIONTIMER_H
#define HIGHPRECISIONTIMER_H

#include <QElapsedTimer>
#include <QObject>
#include <QTimer>

class HighPrecisionTimer : public QObject {
  Q_OBJECT
 public:
  explicit HighPrecisionTimer(QObject *parent = nullptr);

  Q_INVOKABLE void start(int interval);
  Q_INVOKABLE void stop();

 signals:
  void timeout(qint64 elapsed);

 private slots:
  void onTimeout();

 private:
  QTimer timer;
  QElapsedTimer elapsedTimer;
  int interval;
};

#endif  // HIGHPRECISIONTIMER_H
