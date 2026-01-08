CREATE DATABASE ecommerce_db;
USE ecommerce_db;
CREATE TABLE ecommerce_delivery_analytics (
    order_id VARCHAR(20),
    customer_id VARCHAR(20),
    platform VARCHAR(50),
    order_time VARCHAR(20),
    delivery_time_minutes INT,
    product_category VARCHAR(100),
    order_value_inr INT,
    customer_feedback TEXT,
    service_rating INT,
    delivery_delay VARCHAR(5),
    refund_requested VARCHAR(5),
    order_status VARCHAR(20),
	payment_method VARCHAR(20)

);

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ecommerce.csv'
INTO TABLE ecommerce_delivery_analytics
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    platform,
    order_time,
    delivery_time_minutes,
    product_category,
    order_value_inr,
    customer_feedback,
    service_rating,
    delivery_delay,
    refund_requested,
	order_status,
    payment_method
);
RENAME TABLE ecommerce_delivery_analytics TO orderdetails;
SELECT * FROM orderdetails;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*1. Total number of orders*/
SELECT COUNT(*) AS total_orders
FROM orderdetails;

/*Shows how many orders were placed in total across all platforms.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*2. Total revenue from delivered orders*/
SELECT SUM(order_value_inr) AS total_revenue
FROM orderdetails
WHERE order_status = 'Delivered';

/*Tells us how much money was actually earned, considering only successfully delivered orders (not cancelled ones).*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*3. List all platforms*/
SELECT DISTINCT platform
FROM orderdetails;

/*Displays all unique food delivery platforms (like Swiggy, Zomato, etc.) present in the data.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*4. Average delivery time*/
SELECT ROUND(AVG(delivery_time_minutes),2) AS avg_delivery_time
FROM orderdetails;

/*Shows how long, on average, it takes to deliver an order.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*5. Count of cancelled orders*/
SELECT COUNT(*) AS cancelled_orders
FROM orderdetails
WHERE order_status = 'Cancelled';

/*Tells us how many orders were cancelled, helping measure order failure.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*6. Orders per platform*/
CREATE VIEW vw_orders_by_platform AS
SELECT platfplatformorm, COUNT(*) AS total_orders
FROM orderdetails
GROUP BY platform;

/*Shows how many orders each platform received, helping identify the most popular platform.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*7. Revenue per platform*/
CREATE VIEW vw_revenue_by_platform AS
SELECT platform, SUM(order_value_inr) AS revenue
FROM orderdetails
WHERE order_status = 'Delivered'
GROUP BY platform;

/*Shows how much revenue each platform generated, considering only delivered orders.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*8. Average delivery time per platform*/
CREATE VIEW vw_avg_delivery_time_platform AS
SELECT platform,
ROUND(AVG(delivery_time_minutes),2) AS avg_delivery_time
FROM orderdetails
GROUP BY platform;

/*Helps compare which platform delivers faster or slower on average.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*9. Orders by payment method*/
CREATE VIEW vw_orders_by_payment_method AS
SELECT payment_method, COUNT(*) AS total_orders
FROM orderdetails
GROUP BY payment_method;

/*Shows customer payment preferences (Cash, UPI, Card, etc.).*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*10. Order status distribution*/
CREATE VIEW vw_order_status_distribution AS
SELECT order_status, COUNT(*) AS total_orders
FROM orderdetails
GROUP BY order_status;

/*Shows how orders are split between Delivered, Cancelled, etc.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*11. Delivery delay percentage*/
CREATE VIEW vw_delivery_delay_kpi AS
SELECT
ROUND(SUM(CASE WHEN delivery_delay = 'Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2)
AS delayed_percentage
FROM orderdetails;

/*Tells what percentage of orders were delayed, a key service quality KPI.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*12. Delivery speed classification*/
SELECT order_id,
CASE
    WHEN delivery_time_minutes <= 20 THEN 'Fast'
    WHEN delivery_time_minutes BETWEEN 21 AND 40 THEN 'Moderate'
    ELSE 'Slow'
END AS delivery_speed
FROM orderdetails;

/*Categorizes each order as:
Fast (≤ 20 mins)
Moderate (21–40 mins)
Slow (> 40 mins)
This makes delivery performance easier to analyze.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*13. Orders by delivery speed*/
CREATE VIEW vw_delivery_speed_distribution AS
SELECT
CASE
    WHEN delivery_time_minutes <= 20 THEN 'Fast'
    WHEN delivery_time_minutes BETWEEN 21 AND 40 THEN 'Moderate'
    ELSE 'Slow'
END AS delivery_speed,
COUNT(*) AS total_orders
FROM orderdetails
GROUP BY delivery_speed;

/*Shows how many orders fall under Fast, Moderate, and Slow deliveries.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*14. High-value vs low-value orders*/
SELECT
CASE
    WHEN order_value_inr >= 500 THEN 'High Value'
    ELSE 'Low Value'
END AS order_category,
COUNT(*) AS total_orders
FROM orderdetails
GROUP BY order_category;

/*Splits orders into:
High Value (₹500 or more)
Low Value (below ₹500)
Helps understand customer spending behavior.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*15. Refund request rate*/
SELECT
ROUND(SUM(CASE WHEN refund_requested='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2)
AS refund_rate
FROM orderdetails;
SELECT platform,
ROUND(AVG(delivery_time_minutes),2) AS avg_delivery_time
FROM orderdetails
GROUP BY platform
HAVING AVG(delivery_time_minutes) >
       (SELECT AVG(delivery_time_minutes) FROM orderdetails);
       
/*Shows what percentage of orders requested a refund, indicating dissatisfaction.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*16. Platforms with above-average delivery time*/
SELECT platform,
ROUND(AVG(delivery_time_minutes),2) AS avg_delivery_time
FROM orderdetails
GROUP BY platform
HAVING AVG(delivery_time_minutes) >
       (SELECT AVG(delivery_time_minutes) FROM orderdetails);
       
/*Identifies platforms that are slower than the overall average, highlighting performance issues.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*17. Platforms with below-average ratings*/
SELECT platform,
ROUND(AVG(service_rating),2) AS avg_rating
FROM orderdetails
GROUP BY platform
HAVING AVG(service_rating) <
       (SELECT AVG(service_rating) FROM orderdetails);
       
/*Shows platforms whose customer ratings are worse than average, signaling service quality problems.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*18. High-risk orders (Delayed + Low Rating)*/
SELECT order_id, platform, delivery_delay, service_rating
FROM orderdetails
WHERE delivery_delay='Yes'
AND service_rating <= 2;

/*Finds orders that were:
Delayed
Poorly rated (≤ 2)
These are critical customer experience failures.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*19. Cancellation rate per platform*/
CREATE VIEW vw_cancellation_rate_platform AS
SELECT platform,
ROUND(SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END)*100.0/COUNT(*),2)
AS cancellation_rate
FROM orderdetails
GROUP BY platform;

/*Shows what percentage of orders get cancelled on each platform.
High values mean operational or customer issues.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*20. Average rating: delayed vs non-delayed*/
CREATE VIEW vw_rating_by_delivery_delay AS
SELECT delivery_delay,
ROUND(AVG(service_rating),2) AS avg_rating
FROM orderdetails
GROUP BY delivery_delay;

/*Compares customer satisfaction between:
Delayed deliveries
On-time deliveries
Helps prove that delays impact ratings.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*21. Platform performance classification*/
SELECT platform,
CASE
    WHEN AVG(service_rating) >= 4 THEN 'Excellent'
    WHEN AVG(service_rating) BETWEEN 3 AND 3.9 THEN 'Average'
    ELSE 'Poor'
END AS performance_category
FROM orderdetails
GROUP BY platform;

/*Classifies platforms as:
Excellent (rating ≥ 4)
Average (3–3.9)
Poor (< 3)
Makes performance evaluation simple and visual.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*22. Peak ordering hour*/
CREATE VIEW vw_peak_order_hours AS
SELECT SUBSTRING_INDEX(order_time,':',1) AS order_hour,
COUNT(*) AS total_orders
FROM orderdetails
GROUP BY order_hour
ORDER BY total_orders DESC;

/*Identifies which hour of the day has the most orders (rush hour).
Useful for staffing and planning.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*23. Avg delivery time by order hour*/
SELECT SUBSTRING_INDEX(order_time,':',1) AS order_hour,
ROUND(AVG(delivery_time_minutes),2) AS avg_delivery_time
FROM orderdetails
GROUP BY order_hour;

/*Shows how delivery speed changes by time of day, helping spot peak-hour delays.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*24. Customer dissatisfaction drivers*/
SELECT platform,
COUNT(*) AS poor_experience_orders
FROM orderdetails
WHERE service_rating <= 2
OR refund_requested='Yes'
GROUP BY platform;

/*Counts bad experiences per platform based on:
Low ratings
Refund requests
Helps identify which platforms cause the most complaints.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*25. Operational efficiency score*/
SELECT platform,
ROUND(
    (AVG(service_rating) * 100) / AVG(delivery_time_minutes),
2) AS efficiency_score
FROM orderdetails
GROUP BY platform;

/*Combines customer rating and delivery speed into one metric.
Higher score =
Faster delivery
Better customer satisfaction
Used to rank platform efficiency.*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



