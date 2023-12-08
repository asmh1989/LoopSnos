#include "syssettings.h"

#include <QVariantMap>

SysSettings::SysSettings(QObject *parent)
    : QObject(parent),
      m_calibrationSensitivity(0.0),
      m_calibrationTemperature(0.0),
      m_calibrationZeroPoint(0.0),
      m_canoFlowSetting(0),
      m_feno200AdultEmptyingTime(0),
      m_feno200ChildrenPartialEmptyingTime(0),
      m_feno200MouthExhaleSamplingTime(0),
      m_feno50AdultEmptyingTime(0),
      m_feno50ChildrenEmptyingTime(0),
      m_feno50MouthExhaleSamplingTime(0),
      m_fenoLongestMouthExhaleTime(0),
      m_fnno10AdultNasalExhaleSamplingTime(0),
      m_fnno10ChildrenNasalExhaleSamplingTime(0),
      m_longestClearingTime(0),
      m_snoOfflineSamplingTime(0),
      m_temperatureParamA(0.0),
      m_temperatureParamB(0.0),
      m_temperatureParamC(0.0),
      m_temperatureParamD(0.0),
      m_timeOffset(0),
      m_umdRemain(0),
      m_umdTotal(0) {
  // ... (initialize other member variables if needed)
}

double SysSettings::calibrationSensitivity() const {
  return m_calibrationSensitivity;
}

double SysSettings::calibrationTemperature() const {
  return m_calibrationTemperature;
}

double SysSettings::calibrationZeroPoint() const {
  return m_calibrationZeroPoint;
}

int SysSettings::canoFlowSetting() const { return m_canoFlowSetting; }

int SysSettings::feno200AdultEmptyingTime() const {
  return m_feno200AdultEmptyingTime;
}

int SysSettings::feno200ChildrenPartialEmptyingTime() const {
  return m_feno200ChildrenPartialEmptyingTime;
}

int SysSettings::feno200MouthExhaleSamplingTime() const {
  return m_feno200MouthExhaleSamplingTime;
}

int SysSettings::feno50AdultEmptyingTime() const {
  return m_feno50AdultEmptyingTime;
}

int SysSettings::feno50ChildrenEmptyingTime() const {
  return m_feno50ChildrenEmptyingTime;
}

int SysSettings::feno50MouthExhaleSamplingTime() const {
  return m_feno50MouthExhaleSamplingTime;
}

int SysSettings::fenoLongestMouthExhaleTime() const {
  return m_fenoLongestMouthExhaleTime;
}

int SysSettings::fnno10AdultNasalExhaleSamplingTime() const {
  return m_fnno10AdultNasalExhaleSamplingTime;
}

int SysSettings::fnno10ChildrenNasalExhaleSamplingTime() const {
  return m_fnno10ChildrenNasalExhaleSamplingTime;
}

int SysSettings::longestClearingTime() const { return m_longestClearingTime; }

int SysSettings::snoOfflineSamplingTime() const {
  return m_snoOfflineSamplingTime;
}

double SysSettings::temperatureParamA() const { return m_temperatureParamA; }

double SysSettings::temperatureParamB() const { return m_temperatureParamB; }

double SysSettings::temperatureParamC() const { return m_temperatureParamC; }

double SysSettings::temperatureParamD() const { return m_temperatureParamD; }

int SysSettings::timeOffset() const { return m_timeOffset; }

QString SysSettings::umdExpDate() const { return m_umdExpDate; }

QString SysSettings::umdMfDate() const { return m_umdMfDate; }

int SysSettings::umdRemain() const { return m_umdRemain; }

QString SysSettings::umdSn() const { return m_umdSn; }

int SysSettings::umdTotal() const { return m_umdTotal; }

QString SysSettings::updateAt() const { return m_updateAt; }

void SysSettings::loadFromJson(const QVariantMap &jsonData) {
  if (jsonData.contains("calibration_sensitivity"))
    m_calibrationSensitivity =
        jsonData.value("calibration_sensitivity").toDouble();

  if (jsonData.contains("calibration_temperature"))
    m_calibrationTemperature =
        jsonData.value("calibration_temperature").toDouble();

  if (jsonData.contains("calibration_zero_point"))
    m_calibrationZeroPoint =
        jsonData.value("calibration_zero_point").toDouble();

  if (jsonData.contains("cano_flow_setting"))
    m_canoFlowSetting = jsonData.value("cano_flow_setting").toInt();

  if (jsonData.contains("feno200_adult_emptying_time"))
    m_feno200AdultEmptyingTime =
        jsonData.value("feno200_adult_emptying_time").toInt();

  if (jsonData.contains("feno200_children_partial_emptying_time"))
    m_feno200ChildrenPartialEmptyingTime =
        jsonData.value("feno200_children_partial_emptying_time").toInt();

  if (jsonData.contains("feno200_mouth_exhale_sampling_time"))
    m_feno200MouthExhaleSamplingTime =
        jsonData.value("feno200_mouth_exhale_sampling_time").toInt();

  if (jsonData.contains("feno50_adult_emptying_time"))
    m_feno50AdultEmptyingTime =
        jsonData.value("feno50_adult_emptying_time").toInt();

  if (jsonData.contains("feno50_children_emptying_time"))
    m_feno50ChildrenEmptyingTime =
        jsonData.value("feno50_children_emptying_time").toInt();

  if (jsonData.contains("feno50_mouth_exhale_sampling_time"))
    m_feno50MouthExhaleSamplingTime =
        jsonData.value("feno50_mouth_exhale_sampling_time").toInt();

  if (jsonData.contains("feno_longest_mouth_exhale_time"))
    m_fenoLongestMouthExhaleTime =
        jsonData.value("feno_longest_mouth_exhale_time").toInt();

  if (jsonData.contains("fnno10_adult_nasal_exhale_sampling_time"))
    m_fnno10AdultNasalExhaleSamplingTime =
        jsonData.value("fnno10_adult_nasal_exhale_sampling_time").toInt();

  if (jsonData.contains("fnno10_children_nasal_exhale_sampling_time"))
    m_fnno10ChildrenNasalExhaleSamplingTime =
        jsonData.value("fnno10_children_nasal_exhale_sampling_time").toInt();

  if (jsonData.contains("longest_clearing_time"))
    m_longestClearingTime = jsonData.value("longest_clearing_time").toInt();

  if (jsonData.contains("sno_offline_sampling_time"))
    m_snoOfflineSamplingTime =
        jsonData.value("sno_offline_sampling_time").toInt();

  if (jsonData.contains("temperature_param_a"))
    m_temperatureParamA = jsonData.value("temperature_param_a").toDouble();

  if (jsonData.contains("temperature_param_b"))
    m_temperatureParamB = jsonData.value("temperature_param_b").toDouble();

  if (jsonData.contains("temperature_param_c"))
    m_temperatureParamC = jsonData.value("temperature_param_c").toDouble();

  if (jsonData.contains("temperature_param_d"))
    m_temperatureParamD = jsonData.value("temperature_param_d").toDouble();

  if (jsonData.contains("time_offset"))
    m_timeOffset = jsonData.value("time_offset").toInt();

  if (jsonData.contains("umd_exp_date"))
    m_umdExpDate = jsonData.value("umd_exp_date").toString();

  if (jsonData.contains("umd_mf_date"))
    m_umdMfDate = jsonData.value("umd_mf_date").toString();

  if (jsonData.contains("umd_remain"))
    m_umdRemain = jsonData.value("umd_remain").toInt();

  if (jsonData.contains("umd_sn"))
    m_umdSn = jsonData.value("umd_sn").toString();

  if (jsonData.contains("umd_total"))
    m_umdTotal = jsonData.value("umd_total").toInt();

  if (jsonData.contains("update_at"))
    m_updateAt = jsonData.value("update_at").toString();

  emit dataChanged();
}

void SysSettings::emitSignals() {
  emit calibrationSensitivityChanged();
  emit calibrationTemperatureChanged();
  emit calibrationZeroPointChanged();
  emit canoFlowSettingChanged();
  emit feno200AdultEmptyingTimeChanged();
  emit feno200ChildrenPartialEmptyingTimeChanged();
  emit feno200MouthExhaleSamplingTimeChanged();
  emit feno50AdultEmptyingTimeChanged();
  emit feno50ChildrenEmptyingTimeChanged();
  emit feno50MouthExhaleSamplingTimeChanged();
  emit fenoLongestMouthExhaleTimeChanged();
  emit fnno10AdultNasalExhaleSamplingTimeChanged();
  emit fnno10ChildrenNasalExhaleSamplingTimeChanged();
  emit longestClearingTimeChanged();
  emit snoOfflineSamplingTimeChanged();
  emit temperatureParamAChanged();
  emit temperatureParamBChanged();
  emit temperatureParamCChanged();
  emit temperatureParamDChanged();
  emit timeOffsetChanged();
  emit umdExpDateChanged();
  emit umdMfDateChanged();
  emit umdRemainChanged();
  emit umdSnChanged();
  emit umdTotalChanged();
  emit updateAtChanged();
}
