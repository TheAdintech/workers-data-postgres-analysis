-- import_data.sql

\copy Workers_data FROM 'C:/path/to/workers_data.csv' DELIMITER ',' CSV HEADER;

-- Sanity checks after import
SELECT COUNT(*) FROM Workers_data;
SELECT * FROM Workers_data LIMIT 5;