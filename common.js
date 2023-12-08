.pragma library

const DEVICE_STATUS = "DSA_R16_DEVICE_STATUS"
const FUNC_NAME = "DSA_R16_FUNC_NAME"
const FUNC_ACK = "DSA_R16_FUNC_ACK"
const FUNC_STATUS = "DSA_R16_FUNC_STATUS"
const UMD1_STATUS = "DSA_R16_UMD1_STATUS"
const UMD2_STATUS = "DSA_R16_UMD2_STATUS"
const FLOW_CNT = "DSA_R16_FLOW_CNT"
const FLOW_SIZE = "DSA_R16_FLOW_SIZE"
const FLOW_RT = "DSA_R16_FLOW_RT"
const PRESS_RT = "DSA_R16_PRESS_RT"
const FLOW_TIME = "DSA_R16_FLOW_TIME"
const TRACE_CNT = "DSA_R16_TRACE_CNT"
const TRACE_SIZE = "DSA_R16_TRACE_SIZE"
const TRACE_UMD1 = "DSA_R16_TRACE_UMD1"
const TRACE_UMD2 = "DSA_R16_TRACE_UMD2"
const AMBIENT_PRESS = "DSA_R16_AMBIENT_PRESS"
const AMBIENT_TEMP = "DSA_R16_AMBIENT_TEMP"
const AMBIENT_HUMI = "DSA_R16_AMBIENT_HUMI"
const RTC_UNIX1 = "DSA_R16_RTC_UNIX1"
const RTC_UNIX2 = "DSA_R16_RTC_UNIX2"
const UMD1_TEMP = "DSA_R16_UMD1_TEMP"
const UMD2_TEMP = "DSA_R16_UMD2_TEMP"
const UMD1_BASELINE = "DSA_R16_UMD1_BASELINE"

const FLOW_TEMP = "DSA_R16_FLOW_TEMP"
const FLOW_HUMI = "DSA_R16_FLOW_HUMI"
const UMD1_CNT = "DSA_R16_UMD1_CNT"
const UMD1_VBAT = "DSA_R16_UMD1_VBAT"
const UPDATE_TIME = "update_time"

// 采样状态
const STATUS_FLOW1 = "StatusFlow1"
const STATUS_FLOW2 = "StatusFlow2"
const STATUS_FLOW3 = "StatusFlow3"
const STATUS_FLOW4 = "StatusFlow4"
const STATUS_FLOW5 = "StatusFlow5"
const STATUS_FLOW6 = "StatusFlow6"
const STATUS_FLOW7 = "StatusFlow7"
const STATUS_FLOW8 = "StatusFlow8"

// 分析
const STATUS_ANALY_0 = "StatusAnalysis0"
const STATUS_ANALY_1 = "StatusAnalysis1"
const STATUS_ANALY_2 = "StatusAnalysis2"
const STATUS_ANALY_3 = "StatusAnalysis3"
const STATUS_ANALY_4 = "StatusAnalysis4"

// 结束
const STATUS_IDLE = "StatusEndIdle"
const STATUS_END_FINISH = "StatusEndFinish"
const STATUS_END_STOP = "StatusEndStop"
const STATUS_END_FINISH2 = "StatusEndFinish2"

const STATUS_E1 = "StatusE1Inhale"
const STATUS_E2 = "StatusE2Inhale"
const STATUS_E3 = "StatusE3Hold"
const STATUS_E4 = "StatusE4Flow"
const STATUS_E5 = "StatusE5Flow"
const STATUS_E6 = "StatusE6Sample"
const STATUS_E7 = "StatusE7PHigh"
const STATUS_E8 = "StatusE8PLow"

const COMMAND_NONE = "None"
const COMMAND_FENO50_1 = "Feno50Train1"
const COMMAND_FENO50_2 = "Feno50Train2"
const COMMAND_FENO50_MODE1 = "Feno50Mode1"
const COMMAND_FENO50_MODE2 = "Feno50Mode2"

const HELXA_STATUS_SAMPLE = 0
const HELXA_STATUS_ANAY = 1
const HELXA_STATUS_FINISH = 2

var _sample_values = [FUNC_STATUS, FLOW_RT, FUNC_ACK, FUNC_NAME, AMBIENT_TEMP, UMD1_TEMP, TRACE_UMD1, AMBIENT_HUMI, PRESS_RT, AMBIENT_PRESS, UMD1_STATUS, UMD1_BASELINE]

const METHOD_START_HELXA = "start_exhale_test"
const METHOD_HELXA_STARTING = "exhale_starting"
const METHOD_HELXA_STARTED = "exhale_started"
const METHOD_DEVICE_HELXA_FAILED = "device_exhale_failed"
const METHOD_GET_SAMPLE = "get_sample"
const METHOD_GET_PRINTER_SERIAL_STATUS = "get_printer_serial_status"
const METHOD_GET_POWER_DATA = "get_power_data"
const METHOD_DB_QUERY = "db_query"
const METHOD_SHUTDOWN = "shutdown"
const METHOD_CLEAR_POWER_KEY = "clear_power_key"
const METHOD_FINISH_QC_OR_COMBINE = "finish_qc_or_combine"
const METHOD_READ_UMD_PARAMS = "read_umd_params"

const TABLE_EXHALE_TEST = "exhale_test"
const TABLE_PATIENT = "patient"
const TABLE_DEVICE_INFO = "device_info"
const TABLE_SYS_SETTINGS = "sys_setting"

const MESSAGE_STOP_EXHALE = "__msg__stop__exhale"
const MESSAGE_PRINT_RD = "__msg__print__rd"
const MESSAGE_DATA_RECEIVED = "__msg__received"
const MESSAGE_SOCKET_CONNECT = "__msg__socket_connect"

const SENSORS_CONFIG_PATH = "./config/sensors.json"
const AIRBAG_CONFIG_PATH = "./config/airbags.json"
const MESSAGE_REFRESH_CONFIG = "__msg_refresh_label"
const JSON_SENSOR = {
    "addr": "",
    "airLine_name": "",
    "detector_name": "",
    "detector_no": "",
    "id": "",
    "instrument_name": "",
    "sensor_no": "",
    "umd_standard": ""
}

const JSON_AIRBAG = {
    "id": "",
    "airbag_no": "",
    "gas_conc": ""
}

const HELXA_TIPS = {
    "init": "开始吸气前, 请先主动排空肺里的气",
    "ready": "请开始吸气(注意是吸仪器中的气!!)",
    "start_inhale": "吸气中, 不要停,保持2-3秒, 吸满!",
    "start_exhale": "请开始呼气, 流量尽可能保持在红线之间",
    "ex_flow": "呼气流量过高, 请慢一点...",
    "low_flow": "呼气流量过低, 加把油!",
    "keep": "很好, 请保持住, 均匀呼气",
    "done": "测试结束, 可以拿开仪器了,你真棒!",
    "failed": "测试失败, 不要气馁, 再来一次!"
}

function get_sample_req(delay) {
    return {
        "method": METHOD_GET_SAMPLE,
        "args": _sample_values,
        "delay": delay
    }
}

function get_start_helxa_req(command) {
    return {
        "method": METHOD_START_HELXA,
        "args": {
            "command": command
        }
    }
}

function get_stop_helxa_req() {
    return {
        "method": "stop_exhale_test"
    }
}

// 当前呼吸测试是否在采样
function is_helxa_sample(value) {
    let v = get_helxa_status(value)
    return v === HELXA_STATUS_SAMPLE
}

// 当前呼吸测试是否在分析
function is_helxa_analy(value) {
    let v = get_helxa_status(value)
    return v === HELXA_STATUS_ANAY
}

// 当前呼吸测试是否在已完成
function is_helxa_finish(value) {
    let v = get_helxa_status(value)
    return v === HELXA_STATUS_FINISH
}

function is_helxa_failed(value) {
    if (value === STATUS_E1 || value === STATUS_E2 || value
            === STATUS_E3 || value === STATUS_E4 || value === STATUS_E8 || value
            === STATUS_E5 || value === STATUS_E7 || value === STATUS_E6) {
        return true
    }

    return false
}

function get_helxa_status(value) {
    if (value === STATUS_FLOW1 || value === STATUS_FLOW2 || value
            === STATUS_FLOW3 || value === STATUS_FLOW4 || value === STATUS_FLOW5 || value
            === STATUS_FLOW6 || value === STATUS_FLOW7 || value === STATUS_FLOW8) {
        return HELXA_STATUS_SAMPLE
    } else if (value === STATUS_ANALY_0 || value === STATUS_ANALY_1
               || value === STATUS_ANALY_2 || value === STATUS_ANALY_3
               || value === STATUS_ANALY_4) {
        return HELXA_STATUS_ANAY
    } else {
        return HELXA_STATUS_FINISH
    }
}

function get_status_info(value) {
    if (value === STATUS_E1) {
        return "未检测到吸气动作"
    } else if (value === STATUS_E2) {
        return "未检测到吸气动作"
    } else if (value === STATUS_E3) {
        return "未检测到吸气动作"
    } else if (value === STATUS_E4) {
        return "呼气流量过高"
    } else if (value === STATUS_E5) {
        return "呼气流量过低"
    } else if (value === STATUS_E6) {
        return "采样超时"
    } else if (value === STATUS_E7) {
        return "正压过大"
    } else if (value === STATUS_E8) {
        return "负压过大"
    } else if (value === STATUS_END_STOP) {
        return "手动停止"
    } else if (value === STATUS_END_FINISH) {
        return "测试完成"
    } else {
        //        console.log("status = "+ value)
        return "手动停止"
    }
}

// 红线为40-60
function mapValue2(input) {
    if (input < -80) {
        return -19
    } else if (input <= -30) {
        // -80, -30 => -18,-10
        return -10 + (input + 30) * 8 / 50
    } else if (input <= 0) {
        // -30, 0 => -10, 0
        return input / 3
    } else if (input <= 20) {
        // 0 , 20 =>  0, 15
        return input * 15 / 20
    } else if (input <= 40) {
        // 20, 40 => 15,30
        return 15 + (input - 20) * 15 / 20
    } else if (input <= 60) {
        // 40, 60 => 30, 70
        return 30 + (input - 40) * 2.5
    } else if (input <= 84) {
        // 60, 85 => 70, 83
        return 70 + (input - 60) * 13 / 24
    } else {
        return 84
    }
}

// 红线为 45-55
function mapValue(input) {
    if (input < -80) {
        return -14
    } else if (input <= -30) {
        // -80, -30 => -14,-10
        return -10 + (input + 30) * 4 / 50
    } else if (input <= 0) {
        // -30, 0 => -10, 0
        return input / 3
    } else if (input <= 20) {
        // 0 , 20 =>  0, 15
        return input * 15 / 20
    } else if (input <= 45) {
        // 20, 40 => 15,30
        return 15 + (input - 20) * 15 / 25
    } else if (input <= 55) {
        // 45, 55 => 30, 70
        return 30 + (input - 45) * 4
    } else if (input <= 84) {
        // 55, 84 => 70, 83
        return 70 + (input - 55) * 13 / 29
    } else {
        return 84
    }
}

function is_exhale(_status) {
    if (_status === STATUS_FLOW5 || _status === STATUS_FLOW6
            || _status === STATUS_FLOW7 || _status === STATUS_FLOW8) {
        return true
    } else {
        return false
    }
}

function formatDate() {
    var currentDate = new Date()
    var year = currentDate.getFullYear()
    var month = (currentDate.getMonth() + 1).toString().padStart(2, '0')
    // Months are 0-based
    var day = currentDate.getDate().toString().padStart(2, '0')
    var hours = currentDate.getHours().toString().padStart(2, '0')
    var minutes = currentDate.getMinutes().toString().padStart(2, '0')
    var seconds = currentDate.getSeconds().toString().padStart(2, '0')

    var formattedDate = year + '-' + month + '-' + day + '.' + hours + ':' + minutes + ":" + seconds
    return formattedDate
}

function formatDate2(currentDate) {
    var year = currentDate.getFullYear()
    var month = (currentDate.getMonth() + 1).toString().padStart(2, '0')
    // Months are 0-based
    var day = currentDate.getDate().toString().padStart(2, '0')
    var hours = currentDate.getHours().toString().padStart(2, '0')
    var minutes = currentDate.getMinutes().toString().padStart(2, '0')
    var seconds = currentDate.getSeconds().toString().padStart(2, '0')
    var mir = currentDate.getMilliseconds().toString().padStart(2, '0')

    var formattedDate = year + '-' + month + '-' + day + '.' + hours + ':'
            + minutes + ":" + seconds + ":" + mir
    return formattedDate
}

function umd_avg(state1, state2, state3, state4, arr_umd1) {
    var lastElements = arr_umd1.slice(state1, state2)
    var sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
    var av1 = sum / lastElements.length

    lastElements = arr_umd1.slice(state3, state4)
    sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
    var av2 = sum / lastElements.length
    var r = Math.abs(av1 - av2).toFixed(2)
    return r
}

function fix_url(url) {
    var addr = url
    if (!addr.startsWith("ws://")) {
        addr = "ws://" + addr
    }
    return addr
}
