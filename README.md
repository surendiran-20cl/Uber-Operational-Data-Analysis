# Uber Operational Data Analysis using SQL Server

##  Project Overview

This project analyzes Uber's rides, payments, drivers, and city operations using SQL Server.  
The aim is to uncover insights to optimize driver recruitment, detect revenue leaks, understand cancellations, and improve operational efficiency.



##  Technologies Used

- SQL Server Management Studio (SSMS)
- SQL (DDL, DML, CTEs, Indexes, Views, Triggers)



##  Problem Statement

Uber faces challenges in managing rides, payments, drivers, and city-specific operations. This project uses SQL-based analysis to:

- Optimize driver recruitment
- Detect revenue leakage
- Analyze cancellation patterns
- Improve database performance



##  Dataset Details

- **City.csv** - City-level details (population, market competition)
- **Driver.csv** - Driver details (ratings, earnings)
- **Rides.csv** - Ride transactions (start city, fare, status)
- **Payments.csv** - Payment details (amount, method)



##  Key SQL Operations Performed

- Data Cleaning: Handling missing values and duplicates
- City-Level Performance Optimization
- Revenue Leakage Detection
- Cancellation Analysis (by city, ride category, time of day)
- Seasonal Fare Variation Analysis
- Ride Duration Study
- Performance Optimization:
  - Created Indexes on `ride_date` and `payment_method`
  - Views for fast access to average fare and driver metrics
  - Trigger for logging ride status changes



##  Project Structure

| File | Description |
|:-----|:------------|
| `City.csv` | City data |
| `Driver.csv` | Driver data |
| `Payments.csv` | Payments for rides |
| `Rides.csv` | Ride transactions |
| `Analysis of Uber's Operartional Data.sql` | Full SQL code for analysis |
| `README.md` | Project documentation |
| `CONTRIBUTING.md` | Guidelines for contributions |



##  How to Run

1. Set up SQL Server.
2. Create tables and load data from CSV files.
3. Run the SQL scripts in order.
4. Analyze the results in SSMS.



##  Contributions

Contributions are welcome!  
Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines.



##  Contact

For any queries, feel free to reach out at: `surendiran.shanmuga@gmail.com`


