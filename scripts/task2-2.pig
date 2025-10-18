REGISTER 'hdfs:///input/task2udf.py' USING jython AS myudf;  -- Register the UDF

-- Loading the data from all 5 CSV files and assign a variable
noc_region = LOAD 'hdfs:///input/noc_region.csv' USING PigStorage(',') AS (id:int, noc:chararray, region_name:chararray);
person_region = LOAD 'hdfs:///input/person_region.csv' USING PigStorage(',') AS (person_id:int, region_id:int);
person = LOAD 'hdfs:///input/person.csv' USING PigStorage(',') AS (id:int, full_name:chararray, gender:chararray, height:int, weight:int);
competitor_event = LOAD 'hdfs:///input/competitor_event.csv' USING PigStorage(',') AS (event_id:int, competitor_id:int, medal_id:int);
medal = LOAD 'hdfs:///input/medal.csv' USING PigStorage(',') AS (id:int, medal_name:chararray);

-- Performing necessary joins to relate all the tables
joined_data = JOIN noc_region BY id, person_region BY region_id;
joined_data = JOIN joined_data BY person_region::person_id, person BY id;
joined_data = JOIN joined_data BY person::id, competitor_event BY competitor_id;
joined_data = JOIN joined_data BY competitor_event::medal_id, medal BY id;

-- Filtering only gold and silver medals
filtered_data = FILTER joined_data BY medal::medal_name IN ('Gold', 'Silver');

-- Grouping by region name and medal type
grouped_data = GROUP filtered_data BY (noc_region::region_name, medal::medal_name);

-- Counting the number of gold and silver medals per region
medal_counts = FOREACH grouped_data GENERATE 
    FLATTEN(group) AS (Region, Medal), 
    COUNT(filtered_data) AS Count;

-- Separating counts for gold and silver
gold_counts = FILTER medal_counts BY Medal == 'Gold';
silver_counts = FILTER medal_counts BY Medal == 'Silver';

-- Grouping by region to sum gold and silver counts
final_gold = GROUP gold_counts BY Region;
final_silver = GROUP silver_counts BY Region;

-- Suming the counts for gold and silver
gold_sum = FOREACH final_gold GENERATE 
    group AS Region, 
    SUM(gold_counts.Count) AS Gold;

silver_sum = FOREACH final_silver GENERATE 
    group AS Region, 
    SUM(silver_counts.Count) AS Silver;

-- Preparing a union of gold sums and silver sums with nulls for missing values
gold_with_nulls = FOREACH gold_sum GENERATE Region, Gold, null AS Silver;
silver_with_nulls = FOREACH silver_sum GENERATE Region, null AS Gold, Silver;

-- Combining both datasets
combined_counts = UNION gold_with_nulls, silver_with_nulls;

-- Group by region to sum up the values
final_counts = GROUP combined_counts BY Region;

-- Combining results and call UDF to replace nulls with 0
result = FOREACH final_counts GENERATE 
    group AS Region, 
    myudf.NullToZero(SUM(combined_counts.Gold)) AS Gold, 
    myudf.NullToZero(SUM(combined_counts.Silver)) AS Silver;

-- Ordering by Gold in descending order, Silver in descending order, and Region in ascending order
ordered_final_counts = ORDER result BY Gold DESC, Silver DESC, Region ASC;

-- Storing the ordered output in task2-2 directory under output folder
STORE ordered_final_counts INTO 'hdfs:///output/task2-2' USING PigStorage(',');
