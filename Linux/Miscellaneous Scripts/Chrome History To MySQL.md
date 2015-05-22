I haven't run this since early 2014 so I don't know if this still applies or not. I had a situation where I needed a full dump of a Chrome users history without opening the browser and editing the history myself. I obtained the "History" file of Chrome which is just a sqlite database. I ran this on a linux box that had sqlite 3 installed

```
sqlite3 History .dump | grep -v "BEGIN TRANSACTION;" | grep -v "COMMIT;" | perl -pe 's/INSERT INTO \"(.*)\" VALUES/INSERT INTO `\1` VALUES/' > mysql.txt
sed -i 's/INTEGER/INT/g' mysql.txt
```

That gave me a syntatically correct SQL file that I could directly import into MySQL. I could then run the following queries to extract web history in a reportable format

```
SELECT
    current_path,
    target_path,
    FROM_UNIXTIME(start_time / 10000000) AS start_time,
    CASE
        WHEN end_time = 0 THEN "N/A"
        ELSE FROM_UNIXTIME(end_time / 10000000)
    END AS end_time,
    opened,
    total_bytes / 1048576 AS MB
FROM
    downloads


SELECT
    url,
    title,
    (SELECT COUNT(*) FROM visits AS V WHERE V.url = U.id) AS visits,
    CASE
        WHEN last_visit_time = 0 THEN "N/A"
        ELSE FROM_UNIXTIME(last_visit_time / 10000000)
    END AS last_visit,
    CASE hidden
        WHEN 0 THEN "No"
        WHEN 1 THEN "Yes"
    END AS Deleted
FROM
    urls AS U


SELECT
    lower_term,
    term,
    U.url,
    CASE
        WHEN last_visit_time = 0 THEN "N/A"
        ELSE FROM_UNIXTIME(last_visit_time / 10000000)
    END AS "When"
FROM
    keyword_search_terms AS KST
    LEFT JOIN urls AS U
        ON U.id = KST.url_id
```
