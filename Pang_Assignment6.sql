/*
    Name: Richard Pang
    DTSC660: Data and Database Managment with SQL
    Module 8
    Assignment 6
	
*/

--------------------------------------------------------------------------------------------------------------------
--PART 1 Creating the Table and Importing the Data
--------------------------------------------------------------------------------------------------------------------
/* PART 1 - Question 1 */
--------------------------------------------------------------------------------------------------------------------
CREATE TABLE netflix (
    show_id VARCHAR(10),
    type VARCHAR(10),
    title VARCHAR(255),
    director VARCHAR(255),
    country VARCHAR(255),
    date_added DATE,
    release_year INTEGER,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in VARCHAR(255)
);
--------------------------------------------------------------------------------------------------------------------
/* PART 1 - Question 2 */
--------------------------------------------------------------------------------------------------------------------
--Write the copy statement to bring the data into the database

SET datestyle = 'ISO, MDY'; -- Replace 'ISO, MDY' with the desired datestyle 
COPY netflix
FROM 'C:\Users\Public\netflix.csv'
WITH (FORMAT CSV, HEADER);

--------------------------------------------------------------------------------------------------------------------
/* PART 1 - Question 3 */
--------------------------------------------------------------------------------------------------------------------

--view netflix table to check the CSV
SELECT * FROM netflix;

--------------------------------------------------------------------------------------------------------------------
--Part 2 (Cleaning)
--------------------------------------------------------------------------------------------------------------------
/* PART 2 - Question 1 */
--------------------------------------------------------------------------------------------------------------------

CREATE TABLE netflix_backup AS SELECT * FROM netflix;

--------------------------------------------------------------------------------------------------------------------
/* Start a new transaction */
--------------------------------------------------------------------------------------------------------------------

/* Start a new transaction to protect the database */
START TRANSACTION;

--------------------------------------------------------------------------------------------------------------------
/* PART 2 - Question 2 */
--------------------------------------------------------------------------------------------------------------------

--Add a column and call it duplicate
ALTER TABLE netflix
ADD COLUMN categories  text;

-- Copy value from show_id to duplicate column
UPDATE netflix
SET categories  = listed_in;

--------------------------------------------------------------------------------------------------------------------
/* PART 2 - Question 3 */
--------------------------------------------------------------------------------------------------------------------

/*
a. Change values so that they are correctly labeled and recognized by SQL as
NULL values
*/

--Replace director name Not Given to NULL 
UPDATE netflix
SET director = NULL
WHERE director = 'Not Given';

--------------------------------------------------------------------------------------------------------------------
/* PART 2 - Question 4 */
--------------------------------------------------------------------------------------------------------------------

--c. Remove the data containing null values
DELETE FROM netflix
WHERE country LIKE '%Not Given%';

--------------------------------------------------------------------------------------------------------------------
/* PART 2 - Question 5 */
--------------------------------------------------------------------------------------------------------------------

/* replace 's' with 'id' */
UPDATE netflix
SET show_id = REPLACE(show_id, 's', 'id');

/* keep consistent 4 digits numbers to all the ids*/
UPDATE netflix
SET show_id = CONCAT(
    LEFT(show_id, 2),
    LPAD(RIGHT(show_id, LENGTH(show_id) - 2), 4, '0')
);
--------------------------------------------------------------------------------------------------------------------
/* PART 2 - Question 6 */
--------------------------------------------------------------------------------------------------------------------

--Remove '#' from title
UPDATE netflix
SET title = SUBSTRING(title, 2)
WHERE title LIKE '#%';

--------------------------------------------------------------------------------------------------------------------
/* PART 2 - Question 7 */
--------------------------------------------------------------------------------------------------------------------

/* Exploring the duration column list mins and seasons which needs to be seperated */
-- create Minutes and Seasons Column
ALTER TABLE netflix ADD COLUMN minutes text;
ALTER TABLE netflix ADD COLUMN seasons text;

-- Update the minutes column and add "mins" text
UPDATE netflix
SET minutes = 
  CASE
    WHEN duration LIKE '% min' THEN CONCAT(SUBSTRING(duration, 1, CHAR_LENGTH(duration) - 4))
    ELSE NULL
  END
RETURNING duration,minutes ;

-- Update the seasons column and add "Season" text
UPDATE netflix
SET seasons =
  CASE
    WHEN duration LIKE '% Season' THEN CONCAT(SUBSTRING(duration, 1, CHAR_LENGTH(duration) - 7))
    WHEN duration LIKE '% Seasons' THEN CONCAT(SUBSTRING(duration, 1, CHAR_LENGTH(duration) - 8))
    ELSE NULL
  END
RETURNING duration,seasons ;

--------------------------------------------------------------------------------------------------------------------
/* COMMIT to finalize the table */
--------------------------------------------------------------------------------------------------------------------

--Looks like it is all good so we are going to run COMMIT so it commits to our table.
COMMIT;

--------------------------------------------------------------------------------------------------------------------
/* ROLLBACK to undo the changes */
--------------------------------------------------------------------------------------------------------------------

--if we made any errors we can click ROLLBACK: so the table will never change
ROLLBACK;

