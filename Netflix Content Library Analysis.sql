-- Netflix Content Library Analysis

-- 1 Netflix Content Mix: Movies vs TV Shows
-- 1 What proportion of Netflix's catalog consists of movies versus TV shows?

SELECT
    type,
    COUNT(show_id) AS total_titles,
    ROUND(100.0 * COUNT(show_id)
        / (SELECT COUNT(*) FROM netflix_titles), 1) AS pct_of_cataloge
FROM netflix_titles
GROUP BY type
ORDER BY total_titles DESC;

-- This establishes the overall composition of Netflix's content library and shows whether the platform's catalog is more heavily concentrated in movies or TV shows.


-- 2. Which Top Countries Supply the Most Content
SELECT 
    country,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE country IS NOT NULL
	AND TRIM(country) != ''
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;



-- 3: Top 10 Most Appearing Genres (searching within listed_in)
-- We search for each genre keyword using LIKE
SELECT genre, COUNT(*) AS title_count
FROM (
    SELECT 'Dramas'              AS genre FROM netflix_titles WHERE listed_in LIKE '%Dramas%'
    UNION ALL
    SELECT 'Comedies'            AS genre FROM netflix_titles WHERE listed_in LIKE '%Comedies%'
    UNION ALL
    SELECT 'Documentaries'       AS genre FROM netflix_titles WHERE listed_in LIKE '%Documentaries%'
    UNION ALL
    SELECT 'Action & Adventure'  AS genre FROM netflix_titles WHERE listed_in LIKE '%Action & Adventure%'
    UNION ALL
    SELECT 'Thrillers'           AS genre FROM netflix_titles WHERE listed_in LIKE '%Thrillers%'
    UNION ALL
    SELECT 'Horror Movies'       AS genre FROM netflix_titles WHERE listed_in LIKE '%Horror Movies%'
    UNION ALL
    SELECT 'Children & Family'   AS genre FROM netflix_titles WHERE listed_in LIKE '%Children & Family%'
    UNION ALL
    SELECT 'Romantic Movies'     AS genre FROM netflix_titles WHERE listed_in LIKE '%Romantic Movies%'
    UNION ALL
    SELECT 'Stand-Up Comedy'     AS genre FROM netflix_titles WHERE listed_in LIKE '%Stand-Up Comedy%'
    UNION ALL
    SELECT 'International Movies'AS genre FROM netflix_titles WHERE listed_in LIKE '%International Movies%'
) genre_counts
GROUP BY genre
ORDER BY title_count DESC;


-- 4. Movies vs TV Shows by Release Year
SELECT
    release_year,
    type,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY release_year, type
ORDER BY release_year, type;

-- 5. Which Ratings Dominate the Catalog?
SELECT
    rating,
    COUNT(*) AS total_titles,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 
        2
    ) AS percentage
FROM netflix_titles
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY total_titles DESC;

-- 6. Countries with the Broadest Content Variety
SELECT
    country,
    COUNT(DISTINCT type) AS content_types,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE country IS NOT NULL
	AND trim(country) !=''
GROUP BY country
HAVING COUNT(DISTINCT type) = 2
ORDER BY total_titles DESC;      

-- 7. Which Directors Have the Most Netflix Titles?
SELECT
    director,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE director IS NOT NULL
	AND TRIM(director) != ''
GROUP BY director
ORDER BY total_titles DESC
LIMIT 10;

-- 8. How Quickly Is Netflix Adding New Content?
 -- : Movies vs TV Shows Added Per Year
SELECT
    SUBSTR(date_added, LENGTH(date_added) - 3, 4)         AS year_added,
    SUM(CASE WHEN type = 'Movie'   THEN 1 ELSE 0 END)     AS movies_added,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END)     AS tv_shows_added,
    COUNT(show_id)                                         AS total_added
FROM netflix_titles
WHERE date_added IS NOT NULL
  AND TRIM(date_added) != ''
GROUP BY year_added
ORDER BY year_added ASC;

-- 9: Titles with Missing Director Information
SELECT
    type,
    COUNT(show_id)     AS titles_without_director
FROM netflix
WHERE director IS NULL
   OR TRIM(director) = ''
GROUP BY type
ORDER BY titles_without_director DESC;

-- Also check total missing as a % of library
SELECT
    COUNT(*)           AS total_missing_director,
    ROUND(100.0 * COUNT(*)
        / (SELECT COUNT(*) FROM netflix_titles), 1) AS pct_of_library
FROM netflix_titles
WHERE director IS NULL
   OR TRIM(director) = '';

-- 10: Categorise Content by Audience Type
SELECT
    CASE
        WHEN rating IN ('G','PG','TV-G','TV-PG','TV-Y','TV-Y7','TV-Y7-FV')
            THEN 'Family-Friendly'
        WHEN rating IN ('PG-13','TV-14')
            THEN 'Teen'
        WHEN rating IN ('R','TV-MA','NC-17')
            THEN 'Mature'
        ELSE 'Unrated / Other'
    END AS audience_category,
    type,
    COUNT(show_id)                            AS total_titles,
    ROUND(100.0 * COUNT(show_id)
        / (SELECT COUNT(*) FROM netflix_titles), 1)  AS pct_of_category
FROM netflix_titles
GROUP BY audience_category, type
ORDER BY total_titles DESC;


-- Titles released from 2017 onwards
SELECT
    release_year,
    type,
    COUNT(show_id)    AS total_titles
FROM netflix_titles
WHERE release_year >= 2017
GROUP BY release_year, type
ORDER BY release_year DESC, total_titles DESC;


-- All content produced in India (country contains 'India')
SELECT
    type,
    COUNT(show_id)    AS total_titles,
    MIN(release_year) AS earliest_release,
    MAX(release_year) AS latest_release
FROM netflix_titles
WHERE country LIKE '%India%'
GROUP BY type
ORDER BY total_titles DESC;


-- Find titles that mention 'love' in the description
-- Change the keyword to search for any theme
SELECT
    type,
    title,
    release_year,
    listed_in,
    description
FROM netflix_titles
WHERE description LIKE '%love%'
ORDER BY release_year DESC
LIMIT 20;
