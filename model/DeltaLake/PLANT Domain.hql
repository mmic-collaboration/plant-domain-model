CREATE SCHEMA IF NOT EXISTS `PLANT_Domain`;

CREATE TABLE `PLANT_Domain`.Sensor (
    `sensor_id` int NOT NULL PRIMARY KEY,
    `station_id` int,
    `sensor_type` string,
    `Sensor_Configuration` int
);

CREATE TABLE IF NOT EXISTS `PLANT_Domain`.`Sensor_Configuration` (id int NOT NULL PRIMARY KEY);

CREATE TABLE `PLANT_Domain`.`Sensor_Event` (
    `sensor_event_id` int NOT NULL PRIMARY KEY,
    `sensor_id` int NOT NULL,
    `sensor_event_type_id` int,
    `sensor_event_timestamp` timestamp,
    `batch_number` string,
    `bottle_id` tinyint,
    `sensor_event_extension` int NOT NULL
);

CREATE TABLE IF NOT EXISTS `PLANT_Domain`.`sensor_event_extension` (id int NOT NULL PRIMARY KEY);

CREATE TABLE `PLANT_Domain`.`Alarm_Code` (
    `alarm_code_id` tinyint NOT NULL PRIMARY KEY COMMENT 'The unique Digital Membership assigned identifier',
    `alarm_code_number` string COMMENT 'a short description of the alarm code, typically displayed to the user via the ui of the control software',
    `alarm_warning_message` string COMMENT 'a short description of the alarm code, typically displayed to the user via the ui of the control software',
    `alarm_condition` string COMMENT 'the condition or conditions which resulted in this alarm',
    `alarm_colour` string NOT NULL COMMENT 'A colour to indicate the severity of the triggered alarm, with the recovery action:\n - RED - Machine Stop, Clear fault condition and trigger reset/restart\n - YELLOW - Machine Paused, Remove hold condition, machine will resume automatic control.\n - WHITE - Information, n/a\n - BLUE - Low Materials Warning, Replenish material stock\n\nRef: FS01 Data Specification, CPI, martin.keane@cpi-uk.com',
    `alarm_code__standard_recovery_action` string COMMENT 'a short description of the action required in response to this alarm',
    `alarm_code_type` string,
    `alarm_code_station_type` string NOT NULL
) COMMENT 'Alarm codes are defined by CPI as part of the Digital Membership Architecture for Medicines Manufacturing.  They describe the different failure conditions that can occur during medicines manufacturing process, their relative severity (or \'colour\'), and the required recovery action.\n\nAlarm codes have been consolidated from a number of sources, including equipment manufacturers.  It is envisaged that this list will continue to evolve as the requirements are better understood.\n\nThe full list of Digital Membership Alarm Codes is currently defined in the PLANT Domain reference data:\n- https://github.com/mmic-collaboration/plant-domain-model/tree/development/reference-data';

CREATE TABLE `PLANT_Domain`.`Alarm_Sensor_Event` (
    `sensor_event_id` int NOT NULL PRIMARY KEY,
    `alarm_code_id` tinyint NOT NULL,
    status string,
    `custom_message` string,
    acknowledged boolean COMMENT 'Describes the state of an alarm.\nref: OPC-UA=10000-Part9 (v1.05.03)'
);

CREATE TABLE `PLANT_Domain`.`Sensor_Event_Type` (
    `sensor_event_type_id` int NOT NULL PRIMARY KEY,
    `sensor_event_type_name` string NOT NULL,
    `sensor_event_type_description` string
);

CREATE TABLE `PLANT_Domain`.`Equipment_Node` (
    `equipment_node_id` int NOT NULL PRIMARY KEY,
    `equipment_id` int,
    state string NOT NULL COMMENT 'The station state captures the lifecycle of a station:\n\n1. The transition from “Available” to “Running” occurs when a Station Start Request is received from either the local HMI or the Machine Level SCADA.\n2. The transition from “Running” to “In Cycle” occurs when the machine is in the “Running” state and the machine is in auto mode.\n3. The transition from “In Cycle” to “Fault” occurs when a “red” alarm becomes active.\n4. The transition from “Fault” to “In Cycle” occurs when all “red” alarms have been cleared.\n\nRef: FS01 Data Specification, CPI, martin.keane@cpi-uk.com\n',
    `station_short_code` string,
    `equipment_asset_number` string,
    `equipment_model` string,
    manufacturer string
);

CREATE TABLE `PLANT_Domain`.Cycle (
    `cycle_id` tinyint NOT NULL PRIMARY KEY,
    `sensor_event_id` int NOT NULL,
    `cycle_start_timestamp` timestamp NOT NULL,
    `cycle_result` boolean NOT NULL,
    `cycle_result_code` int NOT NULL,
    `cycle_end_timestamp` timestamp NOT NULL
);

ALTER TABLE `PLANT_Domain`.Sensor
ADD CONSTRAINT `fk_Sensor_Configuration_id_to_Sensor_Sensor_Configuration` FOREIGN KEY (`Sensor Configuration`) REFERENCES `PLANT_Domain`.Sensor_Configuration(id);

ALTER TABLE `PLANT_Domain`.Sensor_Event
ADD CONSTRAINT `fk_sensor_event_extension_id_to_Sensor_Event_sensor_event_extension` FOREIGN KEY (`sensor event extension`) REFERENCES `PLANT_Domain`.sensor_event_extension(id);

ALTER TABLE `PLANT_Domain`.Sensor_Event
ADD CONSTRAINT `fk_Sensor_Event_sensor_id_to_Sensor_sensor_id` FOREIGN KEY (`sensor id`) REFERENCES `PLANT_Domain`.Sensor(`sensor id`);

ALTER TABLE `PLANT_Domain`.Sensor_Event_Type
ADD CONSTRAINT `fk_Process_Event_Type_sensor_event_type_id_to_Sensor_Event_sensor_event_type_id` FOREIGN KEY (`sensor event type id`) REFERENCES `PLANT_Domain`.Sensor_Event(`sensor event type id`);

ALTER TABLE `PLANT_Domain`.Alarm_Code
ADD CONSTRAINT `fk_Alarm_Code_alarm_code_id_to_Alarm_alarm_code_id` FOREIGN KEY (`alarm code id`) REFERENCES `PLANT_Domain`.Alarm_Sensor_Event(`alarm code id`);

ALTER TABLE `PLANT_Domain`.Alarm_Sensor_Event
ADD CONSTRAINT `fk_Alarm_sensor_event_id_to_Sensor_Event_sensor_event_id` FOREIGN KEY (`sensor event id`) REFERENCES `PLANT_Domain`.Sensor_Event(`sensor event id`);

ALTER TABLE `PLANT_Domain`.Sensor
ADD CONSTRAINT `fk_Sensor_station_id_to_Station_station_id` FOREIGN KEY (`station id`) REFERENCES `PLANT_Domain`.Equipment_Node(`equipment node id`);

ALTER TABLE `PLANT_Domain`.Cycle
ADD CONSTRAINT `New_Relationship` FOREIGN KEY (`sensor event id`) REFERENCES `PLANT_Domain`.Sensor_Event(`sensor event id`);

