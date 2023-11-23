CREATE TABLE IF NOT EXISTS test_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ti REAL NOT NULL,
    rhi REAL NOT NULL,
    td REAL NOT NULL,
    ta REAL NOT NULL,
    rha REAL NOT NULL,
    mode TEXT NOT NULL,
    id TEXT NOT NULL,
    instrument_name TEXT NOT NULL,
    airLine_name TEXT NOT NULL,
    detector_name TEXT NOT NULL,
    airbag_no TEXT NOT NULL,
    gas_conc INT NOT NULL,
    result REAL NOT NULL,
    flow_rt TEXT NOT NULL,
    pressure_rt TEXT NOT NULL,
    no_rt TEXT NOT NULL,
    detector_no TEXT NOT NULL,
    sensor_no TEXT NOT NULL,
    create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

创建基于qml LocalStorage, 数据库插入和 查询方法
