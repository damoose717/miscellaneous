SELECT 
    col1
    , col2
    , col3
    , ROUND(col2 / col3, 6) AS col4
FROM (
    SELECT 
        table1.col5 AS col1
        , CAST(SUM(table2.col6) AS FLOAT) AS col2
        , table1.col6 AS col3
    FROM table1 
    LEFT JOIN table2
    ON table1.id = table2.facts_id
    GROUP BY col1
)
WHERE col4 > 0.5
ORDER BY col4
;
