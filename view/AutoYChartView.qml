import QtQuick
import QtCharts

Item {
    property int min_y: 8000
    property int max_y: -8000
    property int min_y2: 8000
    property int max_y2: -8000

    property alias rightYVisible: chart2.visible
    property alias titleText: umd1AxisY.titleText
    property alias legendVisible: chartView.legend.visible

    function add(pX, average, id) {
        if (pX > umdAxisX.max) {
            umdAxisX.max += 1
        }

        if (min_y > average) {
            min_y = average
        }
        if (average > max_y) {
            max_y = average
        }
        umd1AxisY.min = Math.round(min_y - Math.abs(min_y) / 20 - 1)
        umd1AxisY.max = Math.ceil(max_y + Math.abs(max_y) / 20 + 1)
        var s = chartView.series(id)
        if (s) {
            s.append(pX, average)
        } else {

        }
    }

    function addRight(pX, average) {
        if (pX > umdAxisX.max) {
            umdAxisX.max += 1
        }

        if (min_y2 > average) {
            min_y2 = average
        }
        if (average > max_y2) {
            max_y2 = average
        }
        umd1AxisY2.min = Math.round(min_y2 - Math.abs(min_y2) / 20 - 1)
        umd1AxisY2.max = Math.ceil(max_y2 + Math.abs(max_y2) / 20 + 1)
        chart2.append(pX, average)
    }

    function clear() {
        chart.clear()
        chart2.clear()
        resetXY()
    }

    function resetXY() {
        min_y = 8000000
        max_y = -8000000
        min_y2 = 8000000
        max_y2 = -800000
        umdAxisX.max = 60
    }

    function createSeries(id) {
        return chartView.createSeries(ChartView.SeriesTypeLine, id, umdAxisX,
                                      umd1AxisY)
    }

    function removeAllSeries() {
        chartView.removeAllSeries()
        resetXY()
    }

    ChartView {
        id: chartView
        width: parent.width
        height: parent.height * 1.1
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true

        legend {
            alignment: Qt.AlignRight
        }

        SplineSeries {
            id: chart
            axisX: umdAxisX
            axisY: umd1AxisY
        }

        SplineSeries {
            id: chart2
            axisX: umdAxisX
            axisYRight: umd1AxisY2
            visible: false
        }

        ValuesAxis {
            id: umdAxisX
            min: 0
            max: 60
            gridVisible: false
            labelFormat: "%.0f"
        }

        ValuesAxis {
            id: umd1AxisY
            min: 80
            max: 160
            tickCount: 6
            labelFormat: "%.0f"
        }

        ValuesAxis {
            id: umd1AxisY2
            min: 80
            max: 160
            tickCount: 6
            labelFormat: "%.0f"
            visible: false
        }
    }
}
