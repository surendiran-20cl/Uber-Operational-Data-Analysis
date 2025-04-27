# Project Documentation: SQL Analysis of Uber's Operational Data

## 1. Objective

Analyze Uber's operational datasets to uncover hidden patterns, solve operational challenges, detect revenue leakage, and improve database performance using advanced SQL techniques.



## 2. Dataset Description

- **City.csv** — city information (name, population, competition).
- **Driver.csv** — driver attributes (ratings, earnings).
- **Rides.csv** — ride details (start city, fare, status).
- **Payments.csv** — payment transaction records.



## 3. Methodology

- **Data Cleaning**:
  - Removed rows with NULL values in primary columns (city_id, driver_id, etc.).
  - Handled duplicates.

- **Data Analysis**:
  - City-level performance using ride demand, cancellation rates, and driver ratings.
  - Revenue leakage detection using missing payments for completed rides.
  - Cancellation analysis by city, ride category, and time of day.

- **Performance Optimization**:
  - Created indexes for faster querying.
  - Built views for quick report generation.
  - Implemented trigger for ride status change tracking.



## 4. Key Insights

- Identified top cities for urgent driver recruitment.
- Highlighted revenue loss areas due to missing payments.
- Recognized peak hours of cancellations.
- Detected seasonal variations in fares.


## 5. Performance Tuning

- Indexes created on `ride_date` and `payment_method`.
- Views for frequently accessed metrics.
- Triggers for logging sensitive status changes.



## 6. Conclusion

Through SQL-driven analysis, Uber's operational challenges can be efficiently addressed, boosting revenue, improving driver performance, and enhancing customer satisfaction.


