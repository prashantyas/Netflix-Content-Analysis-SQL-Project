create database netflix_content_analysis;
use netflix_content_analysis;
drop table if exists netflix;
create table netflix(
	show_id	varchar(6),
	type varchar(10),	
	title varchar(150),
	director varchar(210),	
	cast varchar(1000),	
	country varchar(150),
	date_added varchar(50),
	release_year int,	
	rating varchar(10),
	duration varchar(15),	
	listed_in varchar(25),
	description varchar(250)
);

-- 15 Business Problems
-- 1. Count THe No. Of Movies VS Tv Shows

select
	type,
	count(*) as total_content
from netflix
group by type;

-- 2. Find the most commmon rating for movies and tv shows
select
	type,
    rating
from(
	select
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*) desc) as ranking
	from netflix
	group by 1,2	
) as t1
where
ranking = 1;

-- 3. List all movies released in a specific year(e.g., 2020)

select *from netflix
where
	type = 'Movie'
    and
    release_year = '2020';


-- 4. find the top 5 countries with the most content on netflix

/*select
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
    count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5
*/

WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers
    WHERE n < 10  -- adjust if you expect more than 10 countries in one row
)
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix
JOIN numbers 
    ON n <= 1 + LENGTH(country) - LENGTH(REPLACE(country, ',', ''))
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;



-- 5. Indentify The Longest Movie
select * from netflix
where
	type = 'Movie'
    and
    duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 year
SELECT *
FROM netflix
WHERE STR_TO_DATE(TRIM(date_added), '%M %e, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
limit 5;

-- 7. Find all the movies/tv shows by the director "Rajiv Chilaka";
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%' COLLATE utf8mb4_general_ci;

-- 8. List all tv shows with more than 5 season
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9. Count the number of content items in each genre
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 10  -- increase if a row can have more than 10 genres
)
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
JOIN numbers
    ON n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))
GROUP BY genre
ORDER BY total_content DESC;


-- 10. Find each year and the average no. of content release by India on netflix,
-- return top 5 year with highest avg content release

SELECT 
    YEAR(STR_TO_DATE(TRIM(date_added), '%M %e, %Y')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*) / (SELECT COUNT(*) 
                    FROM netflix 
                    WHERE country = 'India') * 100, 
        2
    ) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY year
ORDER BY avg_content_per_year DESC
LIMIT 5;

-- 11. List all movies that are documentaries
select *from netflix
where 
	listed_in like '%documentaries%';

-- 12. Find all content without a director

select *from netflix
where
	director is null;


-- 13. How many movies actor 'Salman Khan' appeared im last 10 years
select *from netflix
where cast like'%Salman Khan%'
and
release_year > extract(year from current_date) -10;


-- 14. Find the top 10 actors who have appeared in the highest no. of movies produced in india
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 20  -- increase if a movie can have more than 20 actors listed
)
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n), ',', -1)) AS actors,
    COUNT(*) AS total_content
FROM netflix
JOIN numbers
    ON n <= 1 + LENGTH(cast) - LENGTH(REPLACE(cast, ',', ''))
WHERE country LIKE '%India'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10;


