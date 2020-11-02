DROP TABLE data_analyst_assessment;

CREATE TABLE data_analyst_assessment (
	setup_id VARCHAR(4)
	, platform VARCHAR(7)
	, row_type VARCHAR(14)
	, timestamp TIMESTAMP
	, model CHAR(6)
	, step VARCHAR(23)
	, duration NUMERIC(17,3)
	, rating NUMERIC(2,1)
);

COPY data_analyst_assessment(setup_id
							 , platform
							 , row_type
							 , timestamp
							 , model
							 , step
							 , duration
							 , rating
							)
FROM '/tmp/data_analyst_assessment.csv'
DELIMITER ','
CSV HEADER;

SELECT ROUND(AVG(setup_duration), 3)
FROM 
	(SELECT 
	 	SUM(duration) AS setup_duration
	 	, string_agg(step, ', ') AS list_of_steps
	 FROM data_analyst_assessment
	 GROUP BY setup_id)
AS subq
WHERE list_of_steps LIKE 'setup_complete';

