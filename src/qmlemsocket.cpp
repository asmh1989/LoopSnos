#include "qmlemsocket.h"

#include <QtSerialPort/QSerialPortInfo>

#include "model.h"
#include "qaesencryption.h"
#include "utils.h"

QmlEmSocket::QmlEmSocket(QObject *parent)
    : QObject(parent),
      m_webSocket(),
      m_status(Closed),
      m_url(),
      m_type(ChannelType::WebSocket),
      m_isActive(false),
      m_componentCompleted(true),
      m_errorString() {
  customThreadPool.setMaxThreadCount(2);  // 设置最大线程数
  setPort();

  QObject::connect(&m_timer, &QTimer::timeout, this, &QmlEmSocket::testCheck);
  m_timer.setInterval(100);
}

QmlEmSocket::~QmlEmSocket() {}

qint64 QmlEmSocket::sendTextMessage(const QString &message) {
  if (m_status != Open) {
    setErrorString(tr("Messages can only be sent when the socket is open."));
    setStatus(Error);
    return 0;
  }

  if (m_type == ChannelType::WebSocket) {
    return m_webSocket->sendTextMessage(message);
  } else {
    auto bytes = message.toUtf8();
    auto data = utils::encode("90", "51", bytes.toHex());
    return m_serial.write(data);
  }
}

QUrl QmlEmSocket::url() const { return m_url; }

void QmlEmSocket::setUrl(const QUrl &url) {
  if (m_url == url) {
    return;
  }
  if (m_webSocket && (m_status == Open)) {
    m_webSocket->close();
  }
  m_url = url;
  Q_EMIT urlChanged();
  open();
}

void QmlEmSocket::setType(QmlEmSocket::ChannelType type) {
  if (m_type == type) {
    return;
  }
  qDebug() << "new type = " << type;

  if (m_status == Open) {
    close();
  }

  m_type = type;
  Q_EMIT typeChanged();
}

QmlEmSocket::Status QmlEmSocket::status() const { return m_status; }

QmlEmSocket::ChannelType QmlEmSocket::type() const { return m_type; }

QString QmlEmSocket::errorString() const { return m_errorString; }

void QmlEmSocket::classBegin() {
  m_componentCompleted = false;
  m_errorString = tr("QmlEmSocket is not ready.");
  m_status = Closed;
}

void QmlEmSocket::componentComplete() {
  if (m_type == ChannelType::WebSocket) {
    setSocket(new QWebSocket);
  }
  m_componentCompleted = true;
  open();
}

void QmlEmSocket::testCheck() {
  if (m_serial.isOpen()) {
    auto now = QDateTime::currentDateTime();
    qDebug() << now << m_serial.portName() << " testCheck "
             << qAbs(now.secsTo(m_testDate));
    if (m_portName.isEmpty() && qAbs(now.secsTo(m_testDate)) > 4) {
      qDebug() << "recv test response timeout!";
      close();
      findPort();
      m_timer.stop();
    }
  }
}

void QmlEmSocket::findPort() {
  if (m_status != Closed || m_serial.isOpen() || m_timer.isActive() ||
      !m_portName.isEmpty()) {
    return;
  }
  qDebug() << "findPort  ....";
  auto serialPortList = QSerialPortInfo::availablePorts();
  if (serialPortList.length() == m_testPort.length()) {
    m_errorString = "not found serial port!";
    setStatus(Error);
    qDebug("not found serial port!");
    return;
  }

  foreach (const QSerialPortInfo &serialPortInfo, serialPortList) {
    auto port = serialPortInfo.portName();
    if (m_testPort.contains(port)) {
      continue;
    }
    setStatus(Connecting);
    auto err = openSerialPort(port);
    m_testPort.push_back(m_portName);
    if (err.isEmpty()) {
      auto msg = "{\"method\":\"test\"}";
      qDebug() << "send test msg";
      m_testDate = QDateTime::currentDateTime();
      sendTextMessage(msg);
      auto times = 1;
      m_portName = "";
      m_timer.start();
      break;
    } else {
      setStatus(Error);
      m_errorString = err;
      qDebug() << "open serial error: " << m_errorString;
    }
  }
}

void QmlEmSocket::setPort() {
  // 连接readyRead()信号，当串口有可用数据时触发
  QObject::connect(&m_serial, &QSerialPort::readyRead, this,
                   &QmlEmSocket::receive);

  QObject::connect(&m_serial, &QSerialPort::errorOccurred, this,
                   &QmlEmSocket::onSerialError);
}

void QmlEmSocket::recvFrame(const SerialData &data) {
  Q_EMIT textMessageReceived(data.data);
}

void QmlEmSocket::notifyTestOk() {
  qDebug() << "recv pi_pc_serial_port test Ok!";
  m_portName = m_serial.portName();
  m_timer.stop();
}

void QmlEmSocket::receive() {
  QByteArray receivedData = m_serial.readAll();
  if (receivedData.isEmpty()) {
    return;
  }

  buffer.append(receivedData);

  // 寻找帧头'$'
  int startIndex = buffer.indexOf('$');
  while (startIndex != -1) {
    // 寻找帧尾'\r'
    int endIndex = buffer.indexOf('\r', startIndex);
    if (endIndex != -1) {
      // 提取一帧内容
      QByteArray frameData =
          buffer.mid(startIndex + 1, endIndex - startIndex - 1);

      // 使用Lambda函数在线程池中处理数据
      auto processor = [frameData, this]() {
        QByteArray encode = QByteArray::fromBase64(frameData);
        QAESEncryption decryption(QAESEncryption::AES_128, QAESEncryption::ECB,
                                  QAESEncryption::PKCS7);
        QByteArray crcData2 =
            decryption.decode(encode, globalReadOnlyKey->toUtf8());
        QByteArray crcData =
            QAESEncryption::RemovePadding(crcData2, QAESEncryption::PKCS7);

        auto s = utils::parseCrc(crcData);
        recvFrame(s);
      };

      QThreadPool::globalInstance()->start(std::bind(processor));

      // 从缓存中移除已处理的数据
      buffer.remove(0, endIndex + 1);
    } else {
      // 如果没有找到帧尾，保留剩余数据到缓存中
      buffer = buffer.mid(startIndex);
      break;
    }

    // 寻找下一个帧头
    startIndex = buffer.indexOf('$');
  }
}

QString QmlEmSocket::openSerialPort(const QString &port_name) {
  qDebug() << "openSerialPort port = " << port_name;
  m_serial.setPortName(port_name);
  m_serial.setBaudRate(QSerialPort::Baud115200);
  m_serial.setDataBits(QSerialPort::Data8);
  m_serial.setFlowControl(QSerialPort::NoFlowControl);
  m_serial.setParity(QSerialPort::NoParity);
  m_serial.setStopBits(QSerialPort::OneStop);
  if (m_serial.isOpen()) {
    return tr("Can't open %1").arg(port_name);
  }
  if (!m_serial.open(QIODevice::ReadWrite)) {
    return tr("Can't open %1, error code %2")
        .arg(port_name)
        .arg(m_serial.error());
  } else {
    setStatus(Open);
    qDebug() << "openSerial success!";
  }

  return "";
}

void QmlEmSocket::setSocket(QWebSocket *socket) {
  m_webSocket.reset(socket);
  if (m_webSocket) {
    // explicit ownership via QScopedPointer
    m_webSocket->setParent(Q_NULLPTR);
    connect(m_webSocket.data(), &QWebSocket::textMessageReceived, this,
            &QmlEmSocket::textMessageReceived);
    typedef void (QWebSocket::*ErrorSignal)(QAbstractSocket::SocketError);
#if (QT_VERSION >= QT_VERSION_CHECK(6, 5, 0))
    connect(m_webSocket.data(),
                static_cast<ErrorSignal>(&QWebSocket::errorOccurred), this,
                &QmlEmSocket::onError);

#else
    connect(m_webSocket.data(),
            static_cast<ErrorSignal>(&QWebSocket::error), this,
            &QmlEmSocket::onError);
#endif

    connect(m_webSocket.data(), &QWebSocket::stateChanged, this,
            &QmlEmSocket::onStateChanged);
  }
}

void QmlEmSocket::onError(QAbstractSocket::SocketError error) {
  Q_UNUSED(error);
  setErrorString(m_webSocket->errorString());
  setStatus(Error);
}

void QmlEmSocket::onSerialError(QSerialPort::SerialPortError error) {
  Q_UNUSED(error);
  if (error != QSerialPort::NoError) {
    setErrorString(m_serial.errorString());
    setStatus(Error);
  }
}

void QmlEmSocket::onStateChanged(QAbstractSocket::SocketState state) {
  switch (state) {
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::BoundState:
    case QAbstractSocket::HostLookupState: {
      setStatus(Connecting);
      break;
    }
    case QAbstractSocket::UnconnectedState: {
      setStatus(Closed);
      break;
    }
    case QAbstractSocket::ConnectedState: {
      setStatus(Open);
      break;
    }
    case QAbstractSocket::ClosingState: {
      setStatus(Closing);
      break;
    }
    default: {
      setStatus(Connecting);
      break;
    }
  }
}

void QmlEmSocket::setStatus(QmlEmSocket::Status status) {
  if (m_status == status) {
    return;
  }
  m_status = status;
  if (status != Error) {
    setErrorString();
  }
  Q_EMIT statusChanged(m_status);
}

void QmlEmSocket::setActive(bool active) {
  if (m_isActive == active) {
    return;
  }
  m_isActive = active;
  Q_EMIT activeChanged(m_isActive);
  if (!m_componentCompleted) {
    return;
  }
  if (m_isActive) {
    open();
  } else {
    close();
  }
}

bool QmlEmSocket::isActive() const { return m_isActive; }

void QmlEmSocket::open() {
  if (m_type == ChannelType::WebSocket) {
    if (m_componentCompleted && m_isActive && m_url.isValid() &&
        Q_LIKELY(m_webSocket)) {
      //      qDebug() << "start open websockets";
      m_webSocket->open(m_url);
    } else {
      if (!Q_LIKELY(m_webSocket)) {
        setSocket(new QWebSocket);
        open();
      }
      //      qDebug() << "open failed!" << m_url.isValid() <<
      //      Q_LIKELY(m_webSocket);
    }
  } else {
    if (m_portName.isEmpty()) {
      findPort();
    } else {
      setStatus(Connecting);
      openSerialPort(m_portName);
    }
  }
}

void QmlEmSocket::close() {
  if (m_type == ChannelType::WebSocket) {
    if (m_componentCompleted && Q_LIKELY(m_webSocket)) {
      m_webSocket->close();
    }
  } else {
    setStatus(Closed);
    m_serial.close();
  }
}

void QmlEmSocket::setErrorString(QString errorString) {
  if (m_errorString == errorString) {
    return;
  }
  m_errorString = errorString;
  Q_EMIT errorStringChanged(m_errorString);
}
