//pragma Singleton
import QtQml
import QtQuick.LocalStorage

QtObject {
    id: root

    property var _db

    function _database() {
        if (_db)
            return _db

        try {
            let db = LocalStorage.openDatabaseSync("TestData", "1.0",
                                                   "SnoLoopTestData")

            db.transaction(function (tx) {
                tx.executeSql(
                            'CREATE TABLE IF NOT EXISTS test_data (id INTEGER PRIMARY KEY AUTOINCREMENT, ti REAL NOT NULL, rhi INT NOT NULL, td REAL NOT NULL, ta REAL NOT NULL, rha INT NOT NULL, mode TEXT NOT NULL, job_id TEXT NOT NULL, instrument_name TEXT, airLine_name TEXT, detector_name TEXT, airbag_no TEXT NOT NULL, gas_conc INT NOT NULL, result REAL NOT NULL, flow_rt TEXT, pressure_rt TEXT, no_rt TEXT, detector_no TEXT, sensor_no TEXT, sensor_standard Text, create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)')
            })
            _db = db
        } catch (error) {
            console.log("Error opening database: " + error)
        }

        return _db
    }

    function insertTestData(ti, rhi, td, ta, rha, mode, id, instrument_name, airLine_name, detector_name, airbag_no, gas_conc, result, flow_rt, pressure_rt, no_rt, detector_no, sensor_no, sensor_standard) {
        root._database().transaction(function (tx) {
            tx.executeSql(
                        'INSERT INTO test_data (ti, rhi, td, ta, rha, mode, job_id, instrument_name, airLine_name, detector_name, airbag_no, gas_conc, result, flow_rt, pressure_rt, no_rt, detector_no, sensor_no, sensor_standard) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [ti, rhi, td, ta, rha, mode, id, instrument_name, airLine_name, detector_name, airbag_no, gas_conc, result, flow_rt, pressure_rt, no_rt, detector_no, sensor_no, sensor_standard])
        })
    }

    function queryTestData() {
        var result = []
        root._database().transaction(function (tx) {
            var query = tx.executeSql('SELECT * FROM test_data')
            for (var i = 0; i < query.rows.length; ++i) {
                var row = query.rows.item(i)
                result.push(row)
            }
        })
        return result
    }
}
