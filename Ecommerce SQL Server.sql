create database E_Commerce;
use E_Commerce;

/*Problem statement
You can analyze all the tables by describing their contents
*/

/*Problem statement
You can analyze all the tables by describing their contents
*/
-- Describe the structure of the 'customers' table
EXEC sp_columns customers;

-- Describe the structure of the 'products' table
EXEC sp_columns products;

-- Describe the structure of the 'Orders' table
EXEC sp_columns Orders;

-- Describe the structure of the 'OrderDetails' table
EXEC sp_columns OrderDetails;

/*Problem statement
Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.
*/
SELECT TOP 3 location, COUNT(customer_id) AS number_of_customers
FROM Customers
GROUP BY location
ORDER BY number_of_customers DESC;

/*Problem statement
Determine the distribution of customers by the number of orders placed. 
This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.
*/
WITH customer_segment AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS NumberOfOrders
    FROM orders
    GROUP BY customer_id
),
segmented_customers AS (
    SELECT 
        NumberOfOrders,
        COUNT(customer_id) AS CustomerCount,
        CASE
            WHEN NumberOfOrders = 1 THEN 'one-time buyer'
            WHEN NumberOfOrders BETWEEN 2 AND 4 THEN 'Occasional Shoppers'
            ELSE 'Regular customers'
        END AS customer_segment
    FROM customer_segment
    GROUP BY NumberOfOrders
)
SELECT 
    NumberOfOrders, 
    CustomerCount,
    customer_segment
FROM segmented_customers
ORDER BY NumberOfOrders;

/*Problem statement
Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
*/
SELECT 
    Product_id, 
    AVG(quantity) AS AvgQuantity, 
    SUM(quantity * price_per_unit) AS TotalRevenue
FROM 
    OrderDetails
GROUP BY 
    Product_id
HAVING 
    AVG(quantity) = 2
ORDER BY 
    TotalRevenue DESC;

/*Problem statement
For each product category, calculate the unique number of customers purchasing from it. 
This will help understand which categories have wider appeal across the customer base.
*/
select 
category, 
count(distinct customer_id) as unique_customers
from orderdetails as od
left join orders o on o.order_id=od.order_id
left join products p on p.product_id=od.product_id
group by category
order by unique_customers desc;

/*Problem statement
Analyze the month-on-month change in total sales to identify growth trends.
*/


SELECT 
    Month,
    TotalSales, 
    ROUND(((TotalSales - LAG(TotalSales) OVER (ORDER BY Month)) / LAG(TotalSales) OVER (ORDER BY Month)) * 100, 2) AS PercentChange
FROM (
    SELECT 
        FORMAT(CAST(order_date AS date), 'yyyy-MM') AS Month,
        SUM(total_amount) AS TotalSales  
    FROM orders
    GROUP BY FORMAT(CAST(order_date AS date), 'yyyy-MM')
) AS t1
ORDER BY Month;

/*Problem statement
Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
*/

WITH Currentmonthvalue AS (
    SELECT 
        FORMAT(CAST(order_date AS DATE), 'yyyy-MM') AS Month, 
        AVG(total_amount) AS AvgOrderValue
    FROM orders
    GROUP BY FORMAT(CAST(order_date AS DATE), 'yyyy-MM')
),
Previousmonthvalue AS (
    SELECT
        Month,
        AvgOrderValue,
        LAG(AvgOrderValue) OVER(ORDER BY Month) AS Previous_month_value
    FROM Currentmonthvalue
)
SELECT 
    Month, 
    AvgOrderValue,
    ROUND((AvgOrderValue - Previous_month_value), 2) AS ChangeInValue
FROM Previousmonthvalue
ORDER BY ChangeInValue DESC;

/*Problem statement
Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
*/

SELECT 
    top 5 product_id,
    COUNT(ORDER_ID ) AS SalesFrequency
FROM 
    OrderDetails
GROUP BY 
    product_id
ORDER BY 
   SalesFrequency DESC;

/*Problem statement
List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
*/

WITH TotalCustomers AS (
    SELECT COUNT(DISTINCT customer_id) AS TotalCustomerCount
    FROM Customers
),
CustomerThreshold AS (
    SELECT CEILING(0.4 * TotalCustomerCount) AS CustomerThresholdCount
    FROM TotalCustomers
),
ProductCustomerCounts AS (
    SELECT 
        od.product_id,
        COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
    FROM 
        OrderDetails od
    JOIN 
        Orders o ON od.order_id = o.order_id
    GROUP BY 
        od.product_id
),
ProductsBelowThreshold AS (
    SELECT 
        p.product_id,
        p.name,
        pc.UniqueCustomerCount
    FROM 
        Products p
    JOIN 
        ProductCustomerCounts pc ON p.product_id = pc.product_id
    JOIN 
        CustomerThreshold ct ON pc.UniqueCustomerCount < ct.CustomerThresholdCount
  )
SELECT 
    product_id,
    name,
    UniqueCustomerCount
FROM 
    ProductsBelowThreshold;

/*Problem statement
Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
*/

WITH FirstPurchases AS (
    SELECT 
        customer_id,
        MIN(cast(order_date as date)) AS first_purchase_date
    FROM 
        Orders
    GROUP BY 
        customer_id
),
MonthlyFirstPurchases AS (
    SELECT 
        format(first_purchase_date,'yyyy-MM') AS FirstPurchaseMonth,
        COUNT(DISTINCT customer_id) AS TotalNewCustomers
    FROM 
        FirstPurchases
    GROUP BY format(first_purchase_date,'yyyy-MM')
         
)
SELECT 
    FirstPurchaseMonth,
    TotalNewCustomers
FROM 
    MonthlyFirstPurchases
ORDER BY 
    FirstPurchaseMonth;

/*Problem statement
Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
*/

SELECT 
    FORMAT(CAST(ORDER_DATE AS DATE), 'yyyy-MM') AS Month, 
    SUM(total_amount) AS TotalSales
FROM 
    Orders
GROUP BY 
    FORMAT(CAST(ORDER_DATE AS DATE), 'yyyy-MM')
ORDER BY 
    TotalSales DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;



	





