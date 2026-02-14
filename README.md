# Pizza Sales Analytics 🍕

A comprehensive SQL analysis project examining pizza sales data to uncover business insights and customer ordering patterns.

## Project Overview

This project dives into a pizza restaurant's sales data to answer critical business questions. The analysis covers everything from basic sales metrics to advanced revenue trends, helping understand what drives the business and where opportunities lie.

## Database Structure

The project works with four main tables:
- **orders** - Captures order transactions with dates and times
- **order_details** - Links pizzas to orders with quantities
- **pizzas** - Contains pizza variants with pricing
- **pizza_types** - Stores pizza categories and names

## Analysis Questions & Approach

### 1. Total Orders Count
**Question:** How many orders have we received?

```sql
select count(*) from orders;
```

A straightforward count to understand overall order volume. This baseline metric helps gauge business scale.

---

### 2. Revenue Calculation
**Question:** What's our total revenue from pizza sales?

```sql
select round(sum(p.price * o.quantity), 2) Total_Revenue 
from pizzas as p 
join order_details as o 
on p.pizza_id = o.pizza_id;
```

I'm multiplying the price of each pizza by its order quantity across all transactions. The join brings together pricing info with actual orders to get the complete revenue picture.

---

### 3. Premium Pizza Identification
**Question:** Which pizza has the highest price?

```sql
select t.name, p.price
from pizzas p
join pizza_types t
on p.pizza_type_id = t.pizza_type_id
order by p.price desc
limit 1;
```

Finding the most expensive pizza on the menu. This helps identify premium offerings and understand the high end of our product range.

---

### 4. Top Sellers Analysis
**Question:** What are our 5 most popular pizzas by quantity sold?

```sql
select t.name, sum(o.quantity) as total 
from pizza_types as t 
join pizzas as p 
on t.pizza_type_id = p.pizza_type_id
join order_details as o 
on o.pizza_id = p.pizza_id 
group by t.name 
order by total desc
limit 5;
```

I'm aggregating all orders to see which pizzas customers love most. This is gold for inventory planning and marketing focus.

---

### 5. Size Preferences
**Question:** What pizza sizes do customers order most frequently?

```sql
select quantity, count(order_details_id) 
from order_details
group by quantity;
```

Understanding size preferences helps with dough preparation and portion planning.

---

### 6. Category Performance
**Question:** How do different pizza categories perform in terms of quantity ordered?

```sql
select t.category, sum(o.quantity) as Total_Quantity 
from pizza_types as t 
join pizzas as p 
on t.pizza_type_id = p.pizza_type_id 
join order_details as o 
on o.pizza_id = p.pizza_id
group by t.category 
order by Total_Quantity;
```

Breaking down sales by category (like Classic, Veggie, Supreme, etc.) reveals which styles resonate with customers.

---

### 7. Peak Hours Analysis
**Question:** When do we get the most orders throughout the day?

```sql
select hour(order_time) as Hour_Count, count(order_id) as order_count
from orders 
group by Hour_Count;
```

Extracting the hour from order times shows our busiest periods. Critical for staff scheduling and resource allocation.

---

### 8. Category Distribution
**Question:** How many different pizza types do we have in each category?

```sql
select category, count(pizza_type_id) as Pizza_count 
from pizza_types 
group by category;
```

This shows menu diversity across categories and helps balance our offerings.

---

### 9. Daily Average Orders
**Question:** On average, how many pizzas do we sell per day?

```sql
with order_count as (
    select o.order_date, sum(d.quantity) as order_quantity
    from orders as o 
    join order_details as d 
    on o.order_id = d.order_id
    group by o.order_date
)
select round(avg(order_quantity), 0) as Per_day_Pizza
from order_count;
```

Using a CTE to first calculate daily totals, then averaging them. This smooths out fluctuations and gives a reliable daily target.

---

### 10. Revenue Leaders
**Question:** Which 3 pizzas bring in the most money?

```sql
select t.name, round(sum(p.price * d.quantity), 0) as revenue 
from pizza_types as t
join pizzas as p 
on t.pizza_type_id = p.pizza_type_id 
join order_details as d 
on d.pizza_id = p.pizza_id 
group by t.name 
order by revenue desc 
limit 3;
```

Revenue matters more than just quantity sold. A higher-priced pizza with moderate sales might outperform a cheaper bestseller.

---

### 11. Revenue Contribution by Category
**Question:** What percentage of total revenue does each category contribute?

```sql
WITH Total_Sales AS (
    SELECT ROUND(SUM(p.price * d.quantity), 2) AS total_revenue
    FROM pizzas p
    JOIN order_details d 
    ON p.pizza_id = d.pizza_id
)
SELECT 
    t.category,
    ROUND(SUM(p.price * d.quantity) * 100.0 / ts.total_revenue, 2) 
        AS revenue_percent
FROM pizza_types t
JOIN pizzas p 
    ON t.pizza_type_id = p.pizza_type_id
JOIN order_details d 
    ON d.pizza_id = p.pizza_id
CROSS JOIN Total_Sales ts
GROUP BY t.category, ts.total_revenue
ORDER BY revenue_percent DESC;
```

First calculating total revenue, then finding each category's share. This reveals which categories are really driving the business financially.

---

### 12. Cumulative Revenue Trend
**Question:** How has our revenue grown day by day over time?

```sql
select order_date,
sum(revenue) over(order by order_date) as cumlative_revenue
from
(select o.order_date, sum(p.price * d.quantity) as revenue 
from order_details as d
join pizzas as p 
on d.pizza_id = p.pizza_id 
join orders as o 
on o.order_id = d.order_id 
group by o.order_date) as sales;
```

Using a window function to create a running total of revenue. This shows growth trajectory and helps spot trends or anomalies.

---

### 13. Top Performers by Category
**Question:** What are the top 3 revenue-generating pizzas within each category?

```sql
select category, name, round(revenue, 2)
from
(select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rn 
from
(select t.category, t.name, sum(p.price * d.quantity) as revenue 
from pizza_types as t 
join pizzas as p 
on t.pizza_type_id = p.pizza_type_id 
join order_details as d 
on d.pizza_id = p.pizza_id 
group by t.category, t.name) as a) as b
where rn <= 3;
```

This nested query uses ranking within partitions to find category champions. It's about understanding winners in each segment rather than just overall.

---

## Key Insights

The queries progress from basic metrics to sophisticated analysis:
- Start with volume and revenue fundamentals
- Move into product and timing patterns
- End with advanced revenue analytics and comparative performance

This structure helps build a complete picture of the business, from what's happening to why it matters.

## Technologies Used

- SQL (MySQL/PostgreSQL compatible)
- Window Functions for advanced analytics
- CTEs for readable complex queries
- Aggregate functions and joins for data integration

## Getting Started

1. Set up your database with the four tables mentioned
2. Load your pizza sales data
3. Run queries sequentially to build understanding
4. Modify queries based on your specific business questions

## Business Value

This analysis helps answer questions like:
- Which products should we promote?
- When should we schedule more staff?
- What menu items can we optimize or remove?
- How is our business trending over time?
- Where should we focus our marketing budget?

## Future Enhancements

- Customer segmentation analysis
- Seasonal trend identification
- Profit margin analysis by product
- Predictive modeling for demand forecasting
- Geographic sales analysis (if location data available)

---

**Note:** This project demonstrates practical SQL skills including joins, aggregations, window functions, CTEs, and data analysis techniques applicable to real-world business scenarios.

*Feel free to adapt this analysis framework for any food service business looking to understand their sales patterns and optimize operations.*
