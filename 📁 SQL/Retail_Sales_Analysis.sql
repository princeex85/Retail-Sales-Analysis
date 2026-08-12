/*
====================================================
Project: Retail Sales Performance & Profitability Analysis
Author: Prince
Tools: MySQL 8.0
Dataset: Engineered_Superstore
====================================================

Objective:
Analyze sales, profitability, customer behavior,
regional performance, and product performance
using SQL.

*/

/*
====================================================
TABLE OF CONTENTS

1. Sales Performance Analysis
2. Profitability Analysis
3. Customer Analysis
4. Window Function Analysis
5. Business Classification
6. Advanced SQL Analysis

====================================================
*/

/*====================================================
SECTION 1 : SALES PERFORMANCE ANALYSIS
====================================================*/

/*====================================================
Business Question 1
Top 10 Products by Sales

Objective:
Identify the products generating the highest revenue.
====================================================*/
SELECT Product_Name, SUM(Sales) as Sales_ FROM sales_data
GROUP BY  Product_Name ORDER BY SUM(Sales) DESC LIMIT 10;

/*====================================================
Business Question 2
Monthly Sales Trend

Objective:
Analyze monthly sales performance to identify seasonal
trends and peak revenue periods.
====================================================*/
SELECT MONTH(Order_Date) as month_,YEAR(Order_Date) as year_,SUM(Sales) as sale_
FROM sales_data
GROUP BY MONTH(Order_Date),YEAR(Order_Date)
ORDER BY YEAR(Order_Date), MONTH(Order_Date) ;

/*====================================================
Business Question 3
Category Performance

Objective:
Determine which product categories contribute the
highest sales and profit.
====================================================*/
SELECT Category, SUM(Sales) AS sales_, SUM(Profit) AS profit_
FROM sales_data GROUP BY Category
ORDER BY SUM(Sales) DESC, SUM(Profit) DESC;

/*====================================================
Business Question 4
Sub-Category Performance

Objective:
Identify the highest revenue-generating sub-categories
to understand detailed product performance.
====================================================*/
SELECT Sub_Category, SUM(Sales) AS sales_
FROM sales_data GROUP BY Sub_Category
ORDER BY SUM(Sales) DESC;

/*====================================================
SECTION 2 : PROFITABILITY ANALYSIS
====================================================*/

/*====================================================
Business Question 5
State-wise Profitability

Objective:
Identify the most profitable states to support
regional expansion and investment decisions.
====================================================*/
SELECT State,SUM(Profit) AS profit_
FROM sales_data GROUP BY State
ORDER BY SUM(Profit) DESC;

/*====================================================
Business Question 6
City-wise Profitability

Objective:
Analyze profit across cities to identify the
best-performing local markets.
====================================================*/
SELECT City,SUM(Profit) AS profit_
FROM sales_data GROUP BY City
ORDER BY SUM(Profit) DESC;

/*====================================================
Business Question 7
High Sales but Low Profit Products

Objective:
Identify products that generate high sales but
low profitability for pricing and cost analysis.
====================================================*/
SELECT Product_Name, SUM(Sales) as Sales_,Sum(Profit) AS profit_ FROM sales_data
GROUP BY  Product_Name
HAVING SUM(Profit)<500
 ORDER BY SUM(Sales) DESC;
 
/*====================================================
Business Question 8
Discount Impact on Profit

Objective:
Evaluate how different discount levels affect
overall profitability.
====================================================*/
 SELECT Discount, AVG(Profit) AS avg_profit, COUNT(*) AS Number_of_orders FROM sales_data
 GROUP BY Discount
 ORDER BY Discount DESC;
 
 /*====================================================
SECTION 3 : CUSTOMER ANALYSIS
====================================================*/

 /*====================================================
Business Question 9
Customer Segment Analysis

Objective:
Determine which customer segment contributes the
highest sales and profit.
====================================================*/
 SELECT Segment, SUM(Sales) AS sales_, SUM(Profit) AS profit_
 FROM sales_data GROUP BY Segment
 ORDER BY SUM(Sales) DESC,SUM(Profit) DESC;
 
 /*====================================================
Business Question 10
Top Customers by Sales

Objective:
Identify the highest revenue-generating customers
to support customer retention strategies.
====================================================*/
 SELECT Customer_Name, SUM(Sales) AS sales_ FROM sales_data
 GROUP BY Customer_Name
 ORDER BY SUM(Sales) DESC LIMIT 10;
 
 /*====================================================
Business Question 11
Regional Performance

Objective:
Compare sales and profit across different regions
to evaluate overall regional performance.
====================================================*/
 SELECT Region, SUM(Sales) AS sales_,SUM(Profit) AS profit_ FROM sales_data
 GROUP BY Region
 ORDER BY SUM(Sales) DESC,SUM(Profit) DESC;
 
/*====================================================
SECTION 4 : ADVANCED SQL ANALYSIS
(Window Functions)
====================================================*/
 
 /*====================================================
Business Question 12
Rank Cities by Sales

Objective:
Rank cities according to total sales using
window functions.
====================================================*/
 SELECT City, SUM(Sales) AS sales_,
 RANK() OVER(ORDER BY SUM(Sales) DESC ) AS Sales_Rank
FROM sales_data
GROUP BY City;

/*====================================================
Business Question 13
Rank Products by Profit

Objective:
Rank products based on total profit using
DENSE_RANK().
====================================================*/
 SELECT Product_Name, SUM(Profit) AS profit_,
 DENSE_RANK() OVER(ORDER BY SUM(Profit) DESC ) AS Profit_Rank
FROM sales_data
GROUP BY Product_Name;

/*====================================================
Business Question 14
Top Product in Each Category

Objective:
Identify the highest-selling product within
each product category.
====================================================*/
WITH product_table AS ( SELECT Category,Product_name, SUM(Sales) AS sales_,
     ROW_NUMBER() OVER (PARTITION BY `Category` ORDER BY SUM(Sales) DESC) AS Category_Sales_Rank
    FROM sales_data
    GROUP BY Category, product_name
)
SELECT Category,product_name,sales_,
    Category_Sales_Rank
FROM product_table
WHERE Category_Sales_Rank = 1;
/*====================================================
Business Question 15
Running Total of Monthly Sales

Objective:
Calculate cumulative monthly sales to
analyze revenue growth over time.
====================================================*/
WITH month_table AS(
SELECT MONTH(Order_Date) as month_, SUM(Sales) as sales_
FROM sales_data GROUP BY MONTH(Order_Date))
SELECT month_,sales_,
SUM(sales_) OVER(ORDER BY month_) AS Running_Total
FROM month_table;

/*====================================================
Business Question 16
Previous Month Sales Comparison

Objective:
Compare each month's sales with the
previous month's sales using LAG().
====================================================*/
SELECT MONTH(Order_Date) as month_, SUM(Sales) as sales_,
LAG(SUM(Sales))OVER(ORDER BY MONTH(Order_Date)) AS previous_month
FROM sales_data
GROUP BY  MONTH(Order_Date);

/*====================================================
Business Question 17
Month-over-Month Sales Growth

Objective:
Calculate the percentage growth in sales
compared to the previous month.
====================================================*/
WITH month_table AS(
SELECT MONTH(Order_Date) as month_, SUM(Sales) as sales_,
LAG(SUM(Sales))OVER(ORDER BY MONTH(Order_Date)) AS previous_month
FROM sales_data
GROUP BY  MONTH(Order_Date))
SELECT month_,previous_month, sales_,
ROUND((sales_-previous_month)/previous_month*100,2) AS MoM_Growth
FROM month_table
ORDER BY month_;

/*====================================================
SECTION 5 : BUSINESS CLASSIFICATION
====================================================*/

/*====================================================
Business Question 18
Profit Classification

Objective:
Classify transactions into profit categories
using CASE statements for business reporting.
====================================================*/
SELECT Product_Name,Sales,Profit,
    CASE WHEN Profit < 0 THEN 'Loss'
        WHEN Profit BETWEEN 0 AND 100 THEN 'Low Profit'
        WHEN Profit BETWEEN 100 AND 500 THEN 'Medium Profit'
        ELSE 'High Profit' END AS Profit_Category
        FROM sales_data;
 
/*====================================================
Business Question 19
Discount Classification

Objective:
Categorize transactions based on discount
levels using CASE statements.
====================================================*/
SELECT Product_Name,Discount,
    CASE WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.20 THEN 'Low Discount'
        WHEN Discount <= 0.50 THEN 'Medium Discount'
        ELSE 'High Discount' END AS Discount_Category FROM sales_data;
 
/*====================================================
SECTION 6 : ADVANCED SQL (CTE & SUBQUERY)
====================================================*/
 
/*====================================================
Business Question 20
Products Above Average Sales

Objective:
Identify products whose total sales exceed
the average product sales using a subquery.
====================================================*/
WITH sales_table AS (SELECT
Product_Name,SUM(Sales) AS Total_Sales FROM sales_data
GROUP BY Product_Name)
SELECT Product_Name,Total_Sales FROM sales_table
WHERE Total_Sales > (
    SELECT AVG(Total_Sales)
    FROM sales_table)
ORDER BY Total_Sales DESC;


/*====================================================
Business Question 21
Top 5 Customers in Each Segment

Objective:
Identify the highest-value customers within
each customer segment.
====================================================*/

WITH customer_table AS (
SELECT Segment,
       Customer_Name,
       SUM(Sales) AS sales_,
       ROW_NUMBER() OVER(
       PARTITION BY Segment
       ORDER BY SUM(Sales) DESC) AS Sales_Rank
FROM sales_data
GROUP BY Segment, Customer_Name
)

SELECT Segment,
       Customer_Name,
       sales_,
       Sales_Rank
FROM customer_table
WHERE Sales_Rank <= 5;


/*====================================================
End of SQL Analysis

Project:
Retail Sales Performance & Profitability Analysis

Tools Used:
MySQL 8.0

Topics Covered:
✔ Aggregations
✔ Window Functions
✔ CASE Statements
✔ CTEs
✔ Subqueries
✔ Business Analysis

====================================================*/s