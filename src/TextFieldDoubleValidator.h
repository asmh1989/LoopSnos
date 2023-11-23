#ifndef TEXTFIELDDOUBLEVALIDATOR_H
#define TEXTFIELDDOUBLEVALIDATOR_H
#include <QDoubleValidator>

class TextFieldDoubleValidator : public QDoubleValidator {
 public:
  TextFieldDoubleValidator(QObject* parent = 0) : QDoubleValidator(parent) {}
  TextFieldDoubleValidator(double bottom, double top, int decimals,
                           QObject* parent)
      : QDoubleValidator(bottom, top, decimals, parent) {}

  QValidator::State validate(QString& s, int& pos) const {
    if (s.isEmpty() || (s.startsWith("-") && s.length() == 1)) {
      // allow empty field or standalone minus sign
      return QValidator::Intermediate;
    }
    // check length of decimal places
    QString point = locale().decimalPoint();
    if (s.indexOf(point) != -1) {
      int lengthDecimals = s.length() - s.indexOf(point) - 1;
      if (lengthDecimals > decimals()) {
        return QValidator::Invalid;
      }
    }
    // check range of value
    bool isNumber;
    double value = locale().toDouble(s, &isNumber);
    if (isNumber && bottom() <= value && value <= top()) {
      return QValidator::Acceptable;
    }

    return QValidator::Invalid;
  }
};
#endif  // TEXTFIELDDOUBLEVALIDATOR_H
