-- =============================================================
-- Script:  01_load_staging.sql
-- Purpose: Load raw accepted loans CSV into staging table
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/05/2026
-- =============================================================

USE lending_club_db;

LOAD DATA LOCAL INFILE 'C:/Users/USER/Desktop/Projects/Credit Analytics/Credit-Risk-Analysis/Data/Raw/accepted_2007_to_2018Q4.csv'
INTO TABLE stg_accepted_loans
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;