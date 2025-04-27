use UberOperationalDataAnalysis;

/*


Problem Statement:

Uber, a global ride-sharing company, operates in many cities worldwide and relies heavily on
data to make better decisions. However, Uber faces challenges in managing its rides,
payments, drivers, and city-specific issues. To stay competitive and expand into new markets,
Uber needs to analyze its data in-depth to address problems like revenue leaks, driver
performance, and high cancellation rates. This project will use SQL to explore Uber’s
operational data and uncover key insights to improve performance and efficiency across
different cities.

Objective

The main goals of this SQL project are to:
1. Analyze Uber’s ride data to assess performance in various cities.
2. Study financial data by examining fare trends, cancellations, and payment methods.
3. Evaluate driver performance based on ride counts, ratings, and earnings.
4. Investigate the impact of dynamic pricing and cancellations on revenue.
5. Propose operational improvements using SQL queries and analysis.
6. Implement SQL-based solutions to ensure data integrity and improve query
performance.

Datasets Link: https://drive.google.com/drive/folders/1L7iBdWIJEuwoJawzbG5Bv-r4I4TfjuEo?usp=sharing

Capstone Project Questions (SQL-Based)

City-Level Performance Optimization

Which are the top 3 cities where Uber should focus more on driver recruitment based on key
metrics such as demand high cancellation rates and driver ratings?

Revenue Leakage Analysis

How can you detect rides with fare discrepancies or those marked as "completed" without any
corresponding payment?

Cancellation Analysis

What are the cancellation patterns across cities and ride categories? How do these patterns
correlate with revenue from completed rides?

Cancellation Patterns by Time of Day

Analyze the cancellation patterns based on different times of day. Which hours have the highest
cancellation rates, and what is their impact on revenue?

Seasonal Fare Variations

How do fare amounts vary across different seasons? Identify any significant trends or anomalies
in fare distributions.

Average Ride Duration by City

What is the average ride duration for each city? How does this relate to customer satisfaction?

Index for Ride Date Performance Improvement

How can query performance be improved when filtering rides by date?

View for Average Fare by City

How can you quickly access information on average fares for each city?

Trigger for Ride Status Change Logging

How can you track changes in ride statuses for auditing purposes?

View for Driver Performance Metrics

What performance metrics can be summarized to assess driver efficiency?

Index on Payment Method for Faster Querying

How can you optimize query performance for payment-related queries?
*/

/*
1. City-Level Performance Optimization

Question: Which are the top 3 cities where Uber should focus more on driver recruitment based on key metrics such as demand high cancellation rates and driver ratings?    

Assumptions:
We'll assume "demand" can be represented by the number of rides.
We need columns like city, ride_id (to count rides), status (to identify cancellations), and driver_rating from the tables.

*/
 
-- Check for missing values

-- Check missing values in City table
SELECT * FROM City
WHERE city_id IS NULL OR city_name IS NULL OR country IS NULL OR population IS NULL;

-- Check missing values in Driver table
SELECT * FROM Driver
WHERE driver_id IS NULL OR driver_name IS NULL OR avg_driver_rating IS NULL;

-- Check missing values in Payments table
SELECT * FROM Payments
WHERE payment_id IS NULL OR ride_id IS NULL OR fare IS NULL OR transaction_status IS NULL;

-- Check missing values in Rides table
SELECT * FROM Rides
WHERE ride_id IS NULL OR driver_id IS NULL OR passenger_id IS NULL OR start_time IS NULL;

-- Check duplicate city_id
SELECT city_id, COUNT(*)
FROM City
GROUP BY city_id
HAVING COUNT(*) > 1;

-- Check duplicate driver_id
SELECT driver_id, COUNT(*)
FROM Driver
GROUP BY driver_id
HAVING COUNT(*) > 1;

-- Similarly for Payments and Rides

-- Cleaning City table
DELETE FROM City
WHERE city_id IS NULL OR city_name IS NULL OR country IS NULL;

-- Cleaning Driver table
DELETE FROM Driver
WHERE driver_id IS NULL OR driver_name IS NULL;

-- Cleaning Payments table
DELETE FROM Payments
WHERE payment_id IS NULL OR ride_id IS NULL OR fare IS NULL OR transaction_status IS NULL;

-- Cleaning Rides table
DELETE FROM Rides
WHERE ride_id IS NULL OR driver_id IS NULL OR passenger_id IS NULL OR start_time IS NULL OR ride_status IS NULL;

/*
Project Question 1:
City-Level Performance Optimization

Question:

Which are the top 3 cities where Uber should focus more on driver recruitment based on key metrics such as demand, high cancellation rates, and driver ratings?

 Beginner Plan:
High Demand ➔ Cities with highest number of rides.

High Cancellation Rate ➔ Cities where more rides got cancelled.

Driver Ratings ➔ Cities where driver ratings are low.

We will combine all 3 metrics carefully.


1. Find ride demand and cancellation rate by city:

*/

-- Step 1: Get total rides and cancelled rides per city
-- Get total rides and cancelled rides per start_city
SELECT 
    r.start_city,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_rides,
    ROUND(
        (SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS cancellation_rate_percentage
FROM 
    rides r
GROUP BY 
    r.start_city;

/*
Step 2: Driver ratings city-wise:
Since driver table has city_id, but no city name directly —
We need to join driver ➔ city ➔ city_name.
*/

-- Average driver rating per city
SELECT 
    c.city_name,
    ROUND(AVG(d.avg_driver_rating), 2) AS avg_driver_rating
FROM 
    driver d
JOIN 
    city c ON d.city_id = c.city_id
GROUP BY 
    c.city_name;


-- Step 3: Combine demand, cancellations, ratings based on city_name:
-- Combine ride stats and driver stats based on city_name


WITH RideStats AS (
    SELECT 
        r.start_city AS city_name,
        COUNT(*) AS total_rides,
        SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_rides,
        ROUND(
            (SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
            2
        ) AS cancellation_rate_percentage
    FROM 
        rides r
    GROUP BY 
        r.start_city
),
DriverStats AS (
    SELECT 
        c.city_name,
        ROUND(AVG(d.avg_driver_rating), 2) AS avg_driver_rating
    FROM 
        driver d
    JOIN 
        city c ON d.city_id = c.city_id
    GROUP BY 
        c.city_name
)

SELECT TOP 3
    rs.city_name,
    rs.total_rides,
    rs.cancellation_rate_percentage,
    ds.avg_driver_rating
FROM 
    RideStats rs
LEFT JOIN 
    DriverStats ds ON rs.city_name = ds.city_name
ORDER BY 
    rs.total_rides DESC, 
    rs.cancellation_rate_percentage DESC, 
    ds.avg_driver_rating ASC;

-- Question 2: Revenue Leakage Analysis
-- How can you detect rides with fare discrepancies or those marked as "completed" without any corresponding payment?
-- Step : Find rides marked 'Completed' but no payment recorded

SELECT 
    r.ride_id,
    r.start_city,
    r.fare,
    p.payment_id,
    p.fare AS payment_amount
FROM 
    rides r
LEFT JOIN 
    payments p ON r.ride_id = p.ride_id
WHERE 
    r.ride_status = 'Completed'
    AND (p.payment_id IS NULL OR p.fare = 0);

	/*
	Explanation:
Join rides and payments by ride_id.

Focus only on rides that have status 'Completed'.

If no payment_id or amount = 0 ➔ It’s a revenue leakage.
	*/

/*
Question 3: Cancellation Analysis
What are the cancellation patterns across cities and ride categories? 
How do these patterns correlate with revenue from completed rides?
*/

-- Step : Cancellation patterns by city and ride category (dynamic pricing)

SELECT 
    r.start_city,
    r.dynamic_pricing AS ride_category,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_rides,
    ROUND(
        (SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS cancellation_rate_percentage,
    SUM(CASE WHEN r.ride_status = 'Completed' THEN r.fare ELSE 0 END) AS completed_ride_revenue
FROM 
    rides r
GROUP BY 
    r.start_city, r.dynamic_pricing
ORDER BY 
    cancellation_rate_percentage DESC;

/*Explanation:
Grouped by start_city and dynamic_pricing (which acts like ride category).

Find number of total rides, cancelled rides, cancellation percentage, and total revenue from completed rides.

Helps Uber target high cancellation areas.

 Question 4: Cancellation Patterns by Time of Day
Which hours have the highest cancellation rates, and what is their impact on revenue?
*/

-- Step : Analyze cancellation by hour of the day

SELECT 
    DATEPART(HOUR, r.start_time) AS ride_hour,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_rides,
    ROUND(
        (SUM(CASE WHEN r.ride_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS cancellation_rate_percentage,
    SUM(CASE WHEN r.ride_status = 'Completed' THEN r.fare ELSE 0 END) AS revenue_from_completed
FROM 
    rides r
GROUP BY 
    DATEPART(HOUR, r.start_time)
ORDER BY 
    cancellation_rate_percentage DESC;

/*
Explanation:
Use DATEPART(HOUR, start_time) to extract the hour part.

See which hour had the most cancellations.

Check revenue during each hour.
*/

-- Question 5: Seasonal Fare Variations
-- How do fare amounts vary across different seasons? Identify significant trends.


-- Step : Seasonal fare analysis using ride_date

SELECT 
    CASE 
        WHEN MONTH(r.ride_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(r.ride_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(r.ride_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(r.ride_date) IN (9, 10, 11) THEN 'Fall'
    END AS season,
    ROUND(AVG(r.fare), 2) AS average_fare
FROM 
    rides r
WHERE 
    r.ride_status = 'Completed'
GROUP BY 
    CASE 
        WHEN MONTH(r.ride_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(r.ride_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(r.ride_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(r.ride_date) IN (9, 10, 11) THEN 'Fall'
    END
ORDER BY 
    average_fare DESC;

	/*
Explanation:
Categorize months into seasons.

Average fare per season for completed rides.

Helps Uber in seasonal pricing.

Question 6: Average Ride Duration by City
What is the average ride duration for each city?
*/

-- Step : Average ride duration per city

SELECT 
    r.start_city,
    ROUND(AVG(DATEDIFF(MINUTE, r.start_time, r.end_time)), 2) AS average_ride_duration_minutes
FROM 
    rides r
WHERE 
    r.ride_status = 'Completed'
GROUP BY 
    r.start_city
ORDER BY 
    average_ride_duration_minutes DESC;


/*
Explanation:
Use DATEDIFF(MINUTE, start_time, end_time) to calculate ride durations.

Average by city.
*/
-- Question 7: Index for Ride Date Performance Improvement
-- How can query performance be improved when filtering rides by date?


-- Step : Create index on ride_date for faster filtering

CREATE INDEX idx_ride_date
ON rides (ride_date);


/*
Explanation:
Creating an index on ride_date makes date-based filtering much faster.
*/

-- Question 8: View for Average Fare by City
--How can you quickly access information on average fares for each city?


-- Step : Create a view for average fare per city

CREATE VIEW vw_AverageFareByCity AS
SELECT 
    r.start_city,
    ROUND(AVG(r.fare), 2) AS average_fare
FROM 
    rides r
WHERE 
    r.ride_status = 'Completed'
GROUP BY 
    r.start_city;

	select * from vw_AverageFareByCity;
/*
Explanation:
Now you can just SELECT * FROM vw_AverageFareByCity anytime.
*/

-- Question 9: Trigger for Ride Status Change Logging
--How can you track changes in ride statuses for auditing purposes?


-- Step : Create a table to log status changes

CREATE TABLE ride_status_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    ride_id UNIQUEIDENTIFIER,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at DATETIME DEFAULT GETDATE()
);

select * from ride_status_log;
-- Create trigger to log status changes

CREATE TRIGGER trg_RideStatusChange
ON rides
AFTER UPDATE
AS
BEGIN
    INSERT INTO ride_status_log (ride_id, old_status, new_status)
    SELECT 
        inserted.ride_id,
        deleted.ride_status AS old_status,
        inserted.ride_status AS new_status
    FROM 
        inserted
    INNER JOIN 
        deleted ON inserted.ride_id = deleted.ride_id
    WHERE 
        inserted.ride_status <> deleted.ride_status; -- '<> '--> not equal to
END;

select * from trg_RideStatusChange;
/*
 Explanation:
Every time ride_status is changed, a new log is inserted into ride_status_log table.
*/

-- Question 10: View for Driver Performance Metrics
-- What performance metrics can be summarized to assess driver efficiency?


-- Step : Create a view for driver performance

CREATE VIEW vw_DriverPerformance AS
SELECT 
    d.driver_id,
    d.driver_name,
    d.avg_driver_rating,
    d.total_rides,
    d.total_earnings,
    ROUND((CAST(d.total_earnings AS FLOAT) / NULLIF(d.total_rides, 0)), 2) AS avg_earning_per_ride
FROM 
    driver d;

	select * from vw_DriverPerformance;
/*
 Explanation:
Now you can quickly monitor driver performance metrics.
*/

--  Question 11: Index on Payment Method for Faster Querying
-- How can you optimize query performance for payment-related queries?


-- Step : Create index on payment method

CREATE INDEX idx_payment_method
ON payments (payment_method);

-- Explanation:
-- Improves speed when filtering or aggregating payments by payment method (like card, cash, wallet).


/*
Summary:

This project analyzed Uber's operational data using SQL Server to improve performance, optimize revenue, 
understand cancellations, and driver efficiency across cities. Data cleaning, optimization (indexes, views, triggers), and 
deep analysis have been performed.
*/