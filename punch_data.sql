DROP TABLE punch_data;
DROP TABLE id_translation;

CREATE TABLE punch_data (
	row_id INT
	, worked_dept CHAR(6)
	, worked_pay SMALLINT
	, employee_id VARCHAR(7)
	, punch_date VARCHAR(8)
	, punch_in_1 CHAR(8)
	, punch_out_1 CHAR(8)
	, punch_in_2 CHAR(8)
	, punch_out_2 CHAR(8)
	, punch_in_3 CHAR(8)
	, punch_out_3 CHAR(8)
	, punch_in_4 CHAR(8)
	, punch_out_4 CHAR(8)
	, amount DECIMAL(5, 2)
	, PRIMARY KEY (row_id)
);

COPY punch_data(row_id, worked_dept, worked_pay, employee_id
				, punch_date
				, punch_in_1, punch_out_1
				, punch_in_2, punch_out_2
				, punch_in_3, punch_out_3
				, punch_in_4, punch_out_4
				, amount
			   )
FROM '/tmp/PunchData.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE id_translation (
	dept_id CHAR(6)
	, store_id VARCHAR(3)
);

COPY id_translation(dept_id, store_id)
FROM '/tmp/id_translation.csv'
DELIMITER ','
CSV HEADER;

/*ALTER TABLE punch_data
ADD punch_in VARCHAR(40);

UPDATE punch_data 
SET punch_in = COALESCE(punch_in_1, '') || COALESCE(punch_in_2, '');

ALTER TABLE punch_data
ADD punch_out VARCHAR(40);*/

ALTER TABLE punch_data
ADD store_id VARCHAR(3);

UPDATE punch_data
SET store_id = id_translation.store_id
FROM id_translation
WHERE punch_data.worked_dept = id_translation.dept_id;

ALTER TABLE punch_data
ADD before_noon INT;

/*UPDATE punch_data
SET*/

SELECT employee_id
FROM punch_data
WHERE (punch_date >= '12/1/18' AND punch_date <= '12/31/18')
LIMIT 5;
