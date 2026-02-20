# SQL-Data-Cleaning-and-Exploration
This project focuses on the full data pipeline process — from cleaning a messy dataset to extracting valuable business insights. I used a dataset containing information about company layoffs worldwide. The goal was to prepare the data for analysis and then identify trends regarding which industries and countries were most affected.


# Data Cleaning
The initial data was "raw" and contained several mistakes. I followed these steps to ensure the data was reliable:

1. **Creating a Staging Table**:
I created a copy of the raw data to ensure that the original records remained untouched during the cleaning process.

2. **Removing Duplicates**:
Using ROW_NUMBER() and CTEs, I identified and removed duplicate rows based on multiple columns like company, location, and date.

3. **Standardization**:
I removed unnecessary spaces from company names using TRIM. I unified industry names. I corrected spelling errors in locations and standardized country names.

4. **Date Conversion**:
I converted the date column from a text format to a proper DATE format using STR_TO_DATE to allow for time-based analysis.

5. **Handling Missing Values**:
I used a Self-Join to populate missing industry values by looking at other rows for the same company. I removed rows that were completely empty or lacked critical information about layoffs.

# Exploratory Data Analysis
With the clean data, I performed a series of queries to understand the impact of layoffs:

1. **Summary Statistics**:
I identified the maximum number of layoffs and the highest percentage of staff let go in a single day.

2. **Company "Waves"**:
I analyzed how many times a company went through a round of layoffs and calculated the time between these events using LAG() and DATEDIFF().

3. **Industry & Geography Trends**:
I grouped the data to see which industries and which countries had the highest total layoffs.

4. **Time-Series Analysis**:
I calculated a rolling total of layoffs month-over-month to visualize how the number of job cuts grew over time.

5. **Yearly Rankings**:
Using DENSE_RANK(), I identified the top 5 companies with the most layoffs for each year.

6. **Funding Impact**:
I compared the total funds raised by companies against their layoff numbers to see if there was a correlation.
