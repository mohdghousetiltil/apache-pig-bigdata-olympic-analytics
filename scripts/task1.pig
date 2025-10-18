-- here we are loading data from 5 CSV files
noc_region = LOAD 'hdfs:///input/noc_region.csv' USING PigStorage(',') AS (id:int, noc:chararray, region_name:chararray);
person_region = LOAD 'hdfs:///input/person_region.csv' USING PigStorage(',') AS (person_id:int, region_id:int);
person = LOAD 'hdfs:///input/person.csv' USING PigStorage(',') AS (id:int, full_name:chararray, gender:chararray, height:int, weight:int);
competitor_event = LOAD 'hdfs:///input/competitor_event.csv' USING PigStorage(',') AS (event_id:int, competitor_id:int, medal_id:int);
medal = LOAD 'hdfs:///input/medal.csv' USING PigStorage(',') AS (id:int, medal_name:chararray);

-- To join all the tables I performed necessary joins
joined_data = JOIN noc_region BY id, person_region BY region_id;
joined_data = JOIN joined_data BY person_region::person_id, person BY id;
joined_data = JOIN joined_data BY person::id, competitor_event BY competitor_id;
joined_data = JOIN joined_data BY competitor_event::medal_id, medal BY id;

-- used FILTER to extract only the rows where medal is Gold
gold_medals = FILTER joined_data BY medal::medal_name == 'Gold';

-- Grouping by region name to count gold medals per region
grouped_by_region = GROUP gold_medals BY noc_region::region_name;
gold_count = FOREACH grouped_by_region GENERATE group AS Region, COUNT(gold_medals) AS Gold;

-- Ordering the count of gold medals in descending order and region name in ascending order
ordered_gold_count = ORDER gold_count BY Gold DESC, Region ASC;

-- Storing the output in task1 directory under output folder
STORE ordered_gold_count INTO 'hdfs:///output/task1' USING PigStorage(',');
