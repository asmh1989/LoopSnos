// highprecisiontimer.cpp
#include "highprecisiontimer.h"

HighPrecisionTimer::HighPrecisionTimer(QObject *parent) : QObject(parent) {
  timer.setTimerType(Qt::PreciseTimer);
  connect(&timer, &QTimer::timeout, this, &HighPrecisionTimer::onTimeout);
}

void HighPrecisionTimer::start(int interval) {
  this->interval = interval;
  elapsedTimer.start();
  timer.start(interval);
}

void HighPrecisionTimer::stop() { timer.stop(); }

void HighPrecisionTimer::onTimeout() {
  qint64 elapsed = elapsedTimer.elapsed();
  emit timeout(elapsed);
  // 校正定时器
  timer.start(interval - (elapsed % interval));
  elapsedTimer.restart();
}
