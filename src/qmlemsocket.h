#ifndef QMLEMSOCKET_H
#define QMLEMSOCKET_H

#include <QObject>
#include <QQmlParserStatus>
#include <QScopedPointer>
#include <QtQml>
#include <QtSerialPort/QSerialPort>
#include <QtWebSockets/QWebSocket>

#include "model.h"

class QmlEmSocket : public QObject, public QQmlParserStatus {
  Q_OBJECT
  Q_DISABLE_COPY(QmlEmSocket)
  Q_INTERFACES(QQmlParserStatus)

  Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
  Q_PROPERTY(ChannelType type READ type WRITE setType NOTIFY typeChanged)

  Q_PROPERTY(Status status READ status NOTIFY statusChanged)
  Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
  Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

 public:
  QmlEmSocket(QObject *parent = 0);

  ~QmlEmSocket() override;
  enum ChannelType { SerialPort = 0, WebSocket = 1 };
  Q_ENUM(ChannelType)

  enum Status { Connecting = 0, Open = 1, Closing = 2, Closed = 3, Error = 4 };
  Q_ENUM(Status)

  QUrl url() const;
  void setUrl(const QUrl &url);

  ChannelType type() const;
  void setType(ChannelType type);

  Status status() const;
  QString errorString() const;

  void setActive(bool active);
  bool isActive() const;

  Q_INVOKABLE qint64 sendTextMessage(const QString &message);

  Q_INVOKABLE void notifyTestOk();

  Q_INVOKABLE void open();
  Q_INVOKABLE void close();

 Q_SIGNALS:
  void textMessageReceived(QString message);
  void statusChanged(QmlEmSocket::Status status);
  void activeChanged(bool isActive);
  void errorStringChanged(QString errorString);
  void urlChanged();
  void typeChanged();

 public:
  void classBegin() override;
  void componentComplete() override;

 private Q_SLOTS:
  void receive();
  void testCheck();
  void onError(QAbstractSocket::SocketError error);
  void onSerialError(QSerialPort::SerialPortError error);

  void onStateChanged(QAbstractSocket::SocketState state);

 private:
  QScopedPointer<QWebSocket> m_webSocket;
  Status m_status;
  QUrl m_url;
  bool m_isActive;
  bool m_componentCompleted;
  QString m_errorString;

  QString m_portName;

  // takes ownership of the socket
  void setSocket(QWebSocket *socket);

  void setStatus(Status status);
  void setErrorString(QString errorString = QString());
  void recvFrame(const SerialData &data);

  QString openSerialPort(const QString &port_name);

  void findPort();
  void setPort();

  ChannelType m_type;

  QSerialPort m_serial;  // 定义全局串口对象
  QByteArray buffer;
  QThreadPool customThreadPool;
  QStringList m_testPort;
  QDateTime m_testDate;
  QTimer m_timer;
};

#endif  // QMLEMSOCKET_H
