-- ============================================================================
-- PIZZA SALES ANALYTICS - SQL QUERIES
-- ============================================================================
-- This file contains SQL queries for analyzing pizza sales data
-- Database: Pizza Sales Database
-- Tables: orders, order_details, pizzas, pizza_types
-- ============================================================================


-- ----------------------------------------------------------------------------
-- TABLE CREATION
-- ----------------------------------------------------------------------------

-- Create orders table to store order information
-- CREATE TABLE orders (
--     order_id INT NOT NULL,
--     order_date DATE NOT NULL,
--     order_time TIME NOT NULL,
--     PRIMARY KEY(order_id)
-- );


-- ============================================================================
-- BASIC METRICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 1: Total Number of Orders
-- ----------------------------------------------------------------------------
-- Retrieve the total number of orders placed

SELECT COUNT(*) 
FROM orders;


-- ----------------------------------------------------------------------------
-- Query 2: Total Revenue Calculation
-- ----------------------------------------------------------------------------
-- Calculate the total revenue generated from pizza sales

SELECT ROUND(SUM(p.price * o.quantity), 2) AS Total_Revenue 
FROM pizzas AS p 
JOIN order_details AS o 
    ON p.pizza_id = o.pizza_id;


-- ----------------------------------------------------------------------------
-- Query 3: Highest Priced Pizza
-- ----------------------------------------------------------------------------
-- Identify the highest-priced pizza

SELECT t.name, p.price
FROM pizzas p
JOIN pizza_types t
    ON p.pizza_type_id = t.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- ============================================================================
-- PRODUCT ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 4: Top 5 Most Ordered Pizzas
-- ----------------------------------------------------------------------------
-- List the top 5 most ordered pizza types along with their quantities

SELECT t.name, SUM(o.quantity) AS total 
FROM pizza_types AS t 
JOIN pizzas AS p 
    ON t.pizza_type_id = p.pizza_type_id
JOIN order_details AS o 
    ON o.pizza_id = p.pizza_id 
GROUP BY t.name 
ORDER BY total DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- Query 5: Most Common Pizza Size
-- ----------------------------------------------------------------------------
-- Identify the most common pizza size ordered

SELECT quantity, COUNT(order_details_id) 
FROM order_details
GROUP BY quantity;


-- ----------------------------------------------------------------------------
-- Query 6: Category-wise Order Quantity
-- ----------------------------------------------------------------------------
-- Join the necessary tables to find the total quantity of each pizza category ordered

SELECT t.category, SUM(o.quantity) AS Total_Quantity 
FROM pizza_types AS t 
JOIN pizzas AS p 
    ON t.pizza_type_id = p.pizza_type_id 
JOIN order_details AS o 
    ON o.pizza_id = p.pizza_id
GROUP BY t.category 
ORDER BY Total_Quantity;


-- ============================================================================
-- TIME-BASED ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 7: Orders Distribution by Hour
-- ----------------------------------------------------------------------------
-- Determine the distribution of orders by hour of the day

SELECT HOUR(order_time) AS Hour_Count, COUNT(order_id) AS order_count
FROM orders 
GROUP BY Hour_Count;


-- ============================================================================
-- CATEGORY ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 8: Category-wise Pizza Distribution
-- ----------------------------------------------------------------------------
-- Join relevant tables to find the category-wise distribution of pizzas

SELECT category, COUNT(pizza_type_id) AS Pizza_count 
FROM pizza_types 
GROUP BY category;


-- ----------------------------------------------------------------------------
-- Query 9: Average Daily Pizza Orders
-- ----------------------------------------------------------------------------
-- Group the orders by date and calculate the average number of pizzas ordered per day

WITH order_count AS (
    SELECT o.order_date, SUM(d.quantity) AS order_quantity
    FROM orders AS o 
    JOIN order_details AS d 
        ON o.order_id = d.order_id
    GROUP BY o.order_date
)
SELECT ROUND(AVG(order_quantity), 0) AS Per_day_Pizza
FROM order_count;


-- ============================================================================
-- REVENUE ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 10: Top 3 Pizzas by Revenue
-- ----------------------------------------------------------------------------
-- Determine the top 3 most ordered pizza types based on revenue

SELECT t.name, ROUND(SUM(p.price * d.quantity), 0) AS revenue 
FROM pizza_types AS t
JOIN pizzas AS p 
    ON t.pizza_type_id = p.pizza_type_id 
JOIN order_details AS d 
    ON d.pizza_id = p.pizza_id 
GROUP BY t.name 
ORDER BY revenue DESC 
LIMIT 3;


-- ----------------------------------------------------------------------------
-- Query 11: Revenue Percentage by Category
-- ----------------------------------------------------------------------------
-- Calculate the percentage contribution of each pizza type to total revenue

WITH Total_Sales AS (
    SELECT ROUND(SUM(p.price * d.quantity), 2) AS total_revenue
    FROM pizzas p
    JOIN order_details d 
        ON p.pizza_id = d.pizza_id
)
SELECT 
    t.category,
    ROUND(SUM(p.price * d.quantity) * 100.0 / ts.total_revenue, 2) AS revenue_percent
FROM pizza_types t
JOIN pizzas p 
    ON t.pizza_type_id = p.pizza_type_id
JOIN order_details d 
    ON d.pizza_id = p.pizza_id
CROSS JOIN Total_Sales ts
GROUP BY t.category, ts.total_revenue
ORDER BY revenue_percent DESC;


-- ----------------------------------------------------------------------------
-- Query 12: Cumulative Revenue Over Time
-- ----------------------------------------------------------------------------
-- Analyze the cumulative revenue generated over time

SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cumlative_revenue
FROM (
    SELECT o.order_date, SUM(p.price * d.quantity) AS revenue 
    FROM order_details AS d
    JOIN pizzas AS p 
        ON d.pizza_id = p.pizza_id 
    JOIN orders AS o 
        ON o.order_id = d.order_id 
    GROUP BY o.order_date
) AS sales;


-- ============================================================================
-- ADVANCED ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 13: Top 3 Pizzas by Revenue per Category
-- ----------------------------------------------------------------------------
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

SELECT category, name, ROUND(revenue, 2)
FROM (
    SELECT category, name, revenue, 
           RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn 
    FROM (
        SELECT t.category, t.name, SUM(p.price * d.quantity) AS revenue 
        FROM pizza_types AS t 
        JOIN pizzas AS p 
            ON t.pizza_type_id = p.pizza_type_id 
        JOIN order_details AS d 
            ON d.pizza_id = p.pizza_id 
        GROUP BY t.category, t.name
    ) AS a
) AS b
WHERE rn <= 3;


-- ============================================================================
-- END OF QUERIES
-- ============================================================================
