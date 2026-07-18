CREATE SCHEMA IF NOT EXISTS raw;

CREATE SCHEMA IF NOT EXISTS staging;

CREATE SCHEMA IF NOT EXISTS analytics; 

CREATE TABLE raw.equipment ( 
 Equipment_id TEXT,
Tool_name VARCHAR(50),
Tool_Type TEXT,
Area TEXT, 
Install_date_ DATE 
); 

CREATE TABLE raw.codes (
Failure_code VARCHAR(50), 
Failure_catogory TEXT,
Failure_description TEXT
);

CREATE TABLE raw.maintenance_codes(
event_id VARCHAR(50),
equipment_id VARCHAR(50),
failure_code VARCHAR(50),
technician_id VARCHAR(50),
event_date DATE,
downtime_minutes INT,
repair_minutes INT
); 

CREATE TABLE raw.techs(
technician_id VARCHAR(50),
technician_name TEXT,
shift TEXT,
Experience_years INT
);

select count(*)
from raw.codes

select count(*)
from raw.codes

select * 
from raw.equipment 

select count(*)
from raw.equipment


select *
from raw.techs

select count(*)
from raw.techs 

select * 
from raw.maintenance_codes

select count(*) 
from raw.maintenance_codes

select * 
from raw.codes 
where failure_code is null

select *
from raw.equipment 
where equipment_id is null

select * 
from raw.maintenance_codes
where event_id is null

select *
from raw.techs
where technician_id is null


create table staging.codes as 
select * 
from raw.codes

select * 
from staging.codes

select count(*)
from staging.codes

create table staging.equipment as 
select *
from raw.equipment 

select * 
from staging.equipment 

select count (*)
from staging.equipment 

create table staging.maintenance_codes as 
select *



from raw.maintenance_codes 

select *
from staging.maintenance_codes

select count(*)
from staging.maintenance_codes

create table staging.techs as 
select *
from raw.techs

select *
from staging.techs

select count(*)
from staging.techs 

select * 
from raw.equipment 
limit 5

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'raw';


SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'maintenance_codes'; 

  SELECT *
FROM raw.equipment;

SELECT
    equipment_id,
    COUNT(*)
FROM raw.equipment
GROUP BY equipment_id
HAVING COUNT(*) > 1;

SELECT *
FROM raw.equipment
WHERE tool_name IS NULL
   OR tool_type IS NULL
   OR area IS NULL
   OR install_date_ IS NULL;

   SELECT *
FROM raw.equipment
WHERE TRIM(tool_name) = ''
   OR TRIM(tool_type) = ''
   OR TRIM(area) = '';

   SELECT
    technician_id,
    COUNT(*)
FROM raw.techs
GROUP BY technician_id
HAVING COUNT(*) > 1;


SELECT *
FROM raw.techs
WHERE technician_name IS NULL
   OR shift IS NULL
   OR experience_years IS NULL;

   SELECT *
FROM raw.techs
WHERE TRIM(technician_name) = '';

SELECT *
FROM raw.techs
WHERE experience_years < 0
   OR experience_years > 50; 

CREATE VIEW analytics.equipment_downtime AS
SELECT
    e.tool_name,
    e.tool_type,
    e.area,
    SUM(mc.downtime_minutes) AS total_downtime,
    COUNT(mc.event_id) AS total_failures
FROM raw.maintenance_codes mc
JOIN raw.equipment e
    ON mc.equipment_id = e.equipment_id
GROUP BY
    e.tool_name,
    e.tool_type,
    e.area; 

CREATE OR REPLACE VIEW analytics.technician_performance AS

SELECT
    t.technician_name,
    t.shift,
    t.experience_years,
    COUNT(mc.event_id) AS repairs_completed,
    AVG(mc.repair_minutes) AS avg_repair_time,
    SUM(mc.repair_minutes) AS total_repair_time,
    SUM(mc.downtime_minutes) AS total_downtime_handled

FROM raw.maintenance_codes mc

JOIN raw.techs t
    ON mc.technician_id = t.technician_id

GROUP BY
    t.technician_name,
    t.shift,
    t.experience_years;

CREATE OR REPLACE VIEW analytics.failure_analysis AS
SELECT
    failure_code,
    COUNT(*) AS occurrences,
    AVG(repair_minutes) AS avg_repair_time,
    SUM(downtime_minutes) AS total_downtime
FROM raw.maintenance_codes
GROUP BY
    failure_code; 

CREATE OR REPLACE VIEW analytics.area_performance AS
SELECT
    e.area,
    COUNT(mc.event_id) AS maintenance_events,
    SUM(mc.downtime_minutes) AS total_downtime,
    AVG(mc.repair_minutes) AS avg_repair_time
FROM raw.equipment e
JOIN raw.maintenance_codes mc
    ON e.equipment_id = mc.equipment_id
GROUP BY
    e.area; 

	CREATE OR REPLACE VIEW analytics.tool_type_summary AS
SELECT
    e.tool_type,
    COUNT(mc.event_id) AS maintenance_events,
    SUM(mc.downtime_minutes) AS total_downtime,
    AVG(mc.repair_minutes) AS avg_repair_time
FROM raw.equipment e
JOIN raw.maintenance_codes mc
    ON e.equipment_id = mc.equipment_id
GROUP BY
    e.tool_type;

	CREATE OR REPLACE VIEW analytics.technician_workload AS
SELECT
    t.technician_name,
    COUNT(mc.event_id) AS maintenance_events
FROM raw.techs t
JOIN raw.maintenance_codes mc
    ON t.technician_id = mc.technician_id
GROUP BY
    t.technician_name;
	
	CREATE OR REPLACE VIEW analytics.monthly_maintenance AS
SELECT
    DATE_TRUNC('month', event_date) AS month,
    COUNT(event_id) AS maintenance_events,
    SUM(downtime_minutes) AS total_downtime,
    AVG(repair_minutes) AS avg_repair_time
FROM raw.maintenance_codes
GROUP BY DATE_TRUNC('month', event_date)
ORDER BY month;