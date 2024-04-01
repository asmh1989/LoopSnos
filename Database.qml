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
                            'CREATE TABLE IF NOT EXISTS test_data (id INTEGER PRIMARY KEY AUTOINCREMENT, ti REAL NOT NULL, rhi INT NOT NULL, td REAL NOT NULL, ta REAL NOT NULL, rha INT NOT NULL, mode TEXT NOT NULL, job_id TEXT NOT NULL, instrument_name TEXT, airLine_name TEXT, detector_name TEXT, airbag_no TEXT NOT NULL, gas_conc INT NOT NULL, result REAL NOT NULL, flow_rt TEXT, press_rt TEXT, no_rt TEXT,baseline TEXT, detector_no TEXT, sensor_no TEXT, sensor_standard Text, create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)')
            })
            _db = db
        } catch (error) {
            console.log("Error opening database: " + error)
        }

        return _db
    }

    function insertTestData(ti, rhi, td, ta, rha, mode, id, instrument_name, airLine_name, detector_name, airbag_no, gas_conc, result, flow_rt, press_rt, no_rt, baseline, detector_no, sensor_no, sensor_standard) {
        root._database().transaction(function (tx) {
            tx.executeSql(
                        'INSERT INTO test_data (ti, rhi, td, ta, rha, mode, job_id, instrument_name, airLine_name, detector_name, airbag_no, gas_conc, result, flow_rt, press_rt, no_rt,baseline, detector_no, sensor_no, sensor_standard) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [ti, rhi, td, ta, rha, mode, id, instrument_name, airLine_name, detector_name, airbag_no, gas_conc, result, flow_rt, press_rt, no_rt, baseline, detector_no, sensor_no, sensor_standard])
        })
    }

    function queryTestData(instruments, airLines, detectors, gas, ids) {
        var where = ""
        if (instruments.length > 0) {
            where += "instrument_name in (" + instruments.join(",") + ")"
        }
        if (airLines.length > 0) {
            if (where.length > 0) {
                where += " AND "
            }
            where += "airLine_name in (" + airLines.join(",") + ")"
        }

        if (detectors.length > 0) {
            if (where.length > 0) {
                where += " AND "
            }
            where += "detector_name in (" + detectors.join(",") + ")"
        }

        if (gas.length > 2) {
            if (where.length > 0) {
                where += " AND "
            }
            where += "gas_conc in (" + gas + ")"
        }

        if (ids.length > 0) {
            if (where.length > 0) {
                where += " AND "
            }

            where += "job_id in (" + ids.join(",") + ")"
        }

        if (where.length > 0) {
            console.log("sql where = " + where)
        } else {
            return []
        }

        var result = []
        root._database().transaction(function (tx) {
            var query = tx.executeSql('SELECT * FROM test_data where ' + where)
            for (var i = 0; i < query.rows.length; ++i) {
                var row = query.rows.item(i)
                result.push(row)
            }
        })
        return result
    }
}
