#ifndef SYSSETTINGS_H
#define SYSSETTINGS_H

#include <QObject>

class SysSettings : public QObject {
  Q_OBJECT
  Q_PROPERTY(double calibrationSensitivity READ calibrationSensitivity NOTIFY
                 calibrationSensitivityChanged)
  Q_PROPERTY(double calibrationTemperature READ calibrationTemperature NOTIFY
                 calibrationTemperatureChanged)
  Q_PROPERTY(double calibrationZeroPoint READ calibrationZeroPoint NOTIFY
                 calibrationZeroPointChanged)
  Q_PROPERTY(
      int canoFlowSetting READ canoFlowSetting NOTIFY canoFlowSettingChanged)
  Q_PROPERTY(int feno200AdultEmptyingTime READ feno200AdultEmptyingTime NOTIFY
                 feno200AdultEmptyingTimeChanged)
  Q_PROPERTY(int feno200ChildrenPartialEmptyingTime READ
                 feno200ChildrenPartialEmptyingTime NOTIFY
                     feno200ChildrenPartialEmptyingTimeChanged)
  Q_PROPERTY(
      int feno200MouthExhaleSamplingTime READ feno200MouthExhaleSamplingTime
          NOTIFY feno200MouthExhaleSamplingTimeChanged)
  Q_PROPERTY(int feno50AdultEmptyingTime READ feno50AdultEmptyingTime NOTIFY
                 feno50AdultEmptyingTimeChanged)
  Q_PROPERTY(int feno50ChildrenEmptyingTime READ feno50ChildrenEmptyingTime
                 NOTIFY feno50ChildrenEmptyingTimeChanged)
  Q_PROPERTY(
      int feno50MouthExhaleSamplingTime READ feno50MouthExhaleSamplingTime
          NOTIFY feno50MouthExhaleSamplingTimeChanged)
  Q_PROPERTY(int fenoLongestMouthExhaleTime READ fenoLongestMouthExhaleTime
                 NOTIFY fenoLongestMouthExhaleTimeChanged)
  Q_PROPERTY(int fnno10AdultNasalExhaleSamplingTime READ
                 fnno10AdultNasalExhaleSamplingTime NOTIFY
                     fnno10AdultNasalExhaleSamplingTimeChanged)
  Q_PROPERTY(int fnno10ChildrenNasalExhaleSamplingTime READ
                 fnno10ChildrenNasalExhaleSamplingTime NOTIFY
                     fnno10ChildrenNasalExhaleSamplingTimeChanged)
  Q_PROPERTY(int longestClearingTime READ longestClearingTime NOTIFY
                 longestClearingTimeChanged)
  Q_PROPERTY(int snoOfflineSamplingTime READ snoOfflineSamplingTime NOTIFY
                 snoOfflineSamplingTimeChanged)
  Q_PROPERTY(double temperatureParamA READ temperatureParamA NOTIFY
                 temperatureParamAChanged)
  Q_PROPERTY(double temperatureParamB READ temperatureParamB NOTIFY
                 temperatureParamBChanged)
  Q_PROPERTY(double temperatureParamC READ temperatureParamC NOTIFY
                 temperatureParamCChanged)
  Q_PROPERTY(double temperatureParamD READ temperatureParamD NOTIFY
                 temperatureParamDChanged)
  Q_PROPERTY(int timeOffset READ timeOffset NOTIFY timeOffsetChanged)
  Q_PROPERTY(QString umdExpDate READ umdExpDate NOTIFY umdExpDateChanged)
  Q_PROPERTY(QString umdMfDate READ umdMfDate NOTIFY umdMfDateChanged)
  Q_PROPERTY(int umdRemain READ umdRemain NOTIFY umdRemainChanged)
  Q_PROPERTY(QString umdSn READ umdSn NOTIFY umdSnChanged)
  Q_PROPERTY(int umdTotal READ umdTotal NOTIFY umdTotalChanged)
  Q_PROPERTY(QString updateAt READ updateAt NOTIFY updateAtChanged)

 public:
  explicit SysSettings(QObject *parent = nullptr);

  double calibrationSensitivity() const;
  double calibrationTemperature() const;
  double calibrationZeroPoint() const;
  int canoFlowSetting() const;
  int feno200AdultEmptyingTime() const;
  int feno200ChildrenPartialEmptyingTime() const;
  int feno200MouthExhaleSamplingTime() const;
  int feno50AdultEmptyingTime() const;
  int feno50ChildrenEmptyingTime() const;
  int feno50MouthExhaleSamplingTime() const;
  int fenoLongestMouthExhaleTime() const;
  int fnno10AdultNasalExhaleSamplingTime() const;
  int fnno10ChildrenNasalExhaleSamplingTime() const;
  int longestClearingTime() const;
  int snoOfflineSamplingTime() const;
  double temperatureParamA() const;
  double temperatureParamB() const;
  double temperatureParamC() const;
  double temperatureParamD() const;
  int timeOffset() const;
  QString umdExpDate() const;
  QString umdMfDate() const;
  int umdRemain() const;
  QString umdSn() const;
  int umdTotal() const;
  QString updateAt() const;

  Q_INVOKABLE void loadFromJson(const QVariantMap &jsonData);

 signals:
  void calibrationSensitivityChanged();
  void calibrationTemperatureChanged();
  void calibrationZeroPointChanged();
  void canoFlowSettingChanged();
  void feno200AdultEmptyingTimeChanged();
  void feno200ChildrenPartialEmptyingTimeChanged();
  void feno200MouthExhaleSamplingTimeChanged();
  void feno50AdultEmptyingTimeChanged();
  void feno50ChildrenEmptyingTimeChanged();
  void feno50MouthExhaleSamplingTimeChanged();
  void fenoLongestMouthExhaleTimeChanged();
  void fnno10AdultNasalExhaleSamplingTimeChanged();
  void fnno10ChildrenNasalExhaleSamplingTimeChanged();
  void longestClearingTimeChanged();
  void snoOfflineSamplingTimeChanged();
  void temperatureParamAChanged();
  void temperatureParamBChanged();
  void temperatureParamCChanged();
  void temperatureParamDChanged();
  void timeOffsetChanged();
  void umdExpDateChanged();
  void umdMfDateChanged();
  void umdRemainChanged();
  void umdSnChanged();
  void umdTotalChanged();
  void updateAtChanged();
  void dataChanged();

 private:
  double m_calibrationSensitivity;
  double m_calibrationTemperature;
  double m_calibrationZeroPoint;
  int m_canoFlowSetting;
  int m_feno200AdultEmptyingTime;
  int m_feno200ChildrenPartialEmptyingTime;
  int m_feno200MouthExhaleSamplingTime;
  int m_feno50AdultEmptyingTime;
  int m_feno50ChildrenEmptyingTime;
  int m_feno50MouthExhaleSamplingTime;
  int m_fenoLongestMouthExhaleTime;
  int m_fnno10AdultNasalExhaleSamplingTime;
  int m_fnno10ChildrenNasalExhaleSamplingTime;
  int m_longestClearingTime;
  int m_snoOfflineSamplingTime;
  double m_temperatureParamA;
  double m_temperatureParamB;
  double m_temperatureParamC;
  double m_temperatureParamD;
  int m_timeOffset;
  QString m_umdExpDate;
  QString m_umdMfDate;
  int m_umdRemain;
  QString m_umdSn;
  int m_umdTotal;
  QString m_updateAt;

  void emitSignals();
};

#endif  // SYSSETTINGS_H
