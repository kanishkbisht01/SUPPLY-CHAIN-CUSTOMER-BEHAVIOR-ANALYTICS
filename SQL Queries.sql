-- 1. Main Orders Table
CREATE TABLE orders_data (
    Payment_Type VARCHAR(50),
    Days_for_shipping_real INT,
    Days_for_shipment_scheduled INT,
    Benefit_per_order DECIMAL(10,2),
    Sales_per_customer DECIMAL(10,2),
    Delivery_Status VARCHAR(50),
    Late_delivery_risk INT,
    Category_Id INT,
    Category_Name VARCHAR(100),
	Customer_City VARCHAR(100),
    Customer_Country VARCHAR(100),
    Customer_Email VARCHAR(150),
    Customer_Fname VARCHAR(100),
    Customer_Id INT,
    Customer_Lname VARCHAR(100),
    Customer_Password VARCHAR(100),
    Customer_Segment VARCHAR(50),
    Customer_State VARCHAR(100),
    Customer_Street VARCHAR(200),
    Customer_Zipcode VARCHAR(20),
	Department_Id INT,
    Department_Name VARCHAR(100),
	Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6),
	Market VARCHAR(50),
	Order_City VARCHAR(100),
    Order_Country VARCHAR(100),
    Order_Customer_Id INT,
	Order_Date TIMESTAMP,
    Order_Id INT,
	Order_Item_Cardprod_Id INT,
    Order_Item_Discount DECIMAL(10,2),
    Order_Item_Discount_Rate DECIMAL(5,2),
    Order_Item_Id INT,
    Order_Item_Product_Price DECIMAL(10,2),
    Order_Item_Profit_Ratio DECIMAL(5,2),
    Order_Item_Quantity INT,
    Sales DECIMAL(10,2),
    Order_Item_Total DECIMAL(10,2),
    Order_Profit_Per_Order DECIMAL(10,2),
	Order_Region VARCHAR(100),
    Order_State VARCHAR(100),
    Order_Status VARCHAR(50),
    Order_Zipcode VARCHAR(20),
	Product_Card_Id INT,
    Product_Category_Id INT,
    Product_Description TEXT,
    Product_Image TEXT,
    Product_Name VARCHAR(150),
    Product_Price DECIMAL(10,2),
    Product_Status VARCHAR(50),
	Shipping_Date TIMESTAMP,
    Shipping_Mode VARCHAR(50)
);
drop table orders_data;
Select * From orders_data;

ALTER TABLE orders_data 
ALTER COLUMN Order_Date TYPE TIMESTAMP;
-- 2. Web Access Logs Table (tokenized_access_logs file ke liye)
CREATE TABLE public.web_access_logs (
    product_name VARCHAR(255),
    category VARCHAR(100),
    access_date VARCHAR(100), -- Isme date aur time dono hain
    access_month VARCHAR(20),
    access_hour INT,
    department VARCHAR(100),
    ip_address VARCHAR(50),
    url TEXT
);

select * from web_access_logs;


-- Total Sales, Profit, Avg Order Value
SELECT 
    ROUND(SUM(Sales), 2)                        AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)        AS Total_Profit,
    ROUND(AVG(Sales), 2)                         AS Avg_Order_Value,
    ROUND(AVG(Late_delivery_risk) * 100, 2)      AS Late_Delivery_Pct
FROM orders_data;


--year wise sales growth
SELECT 
    EXTRACT(YEAR FROM order_date::timestamp)            AS Year,
    ROUND(SUM(sales)::numeric, 2)                       AS Total_Sales,
    ROUND(SUM(order_profit_per_order)::numeric, 2)      AS Total_Profit,
    COUNT(order_id)                                     AS Total_Orders
FROM orders_data
GROUP BY EXTRACT(YEAR FROM order_date::timestamp)
ORDER BY Year;

--Top 10 Profitable Categories
SELECT 
    Category_Name,
    ROUND(SUM(Order_Profit_Per_Order), 2)                                       AS Total_Profit,
    ROUND((SUM(Order_Profit_Per_Order) / NULLIF(SUM(Sales), 0)) * 100, 2)      AS Profit_Margin_Pct
FROM orders_data
GROUP BY Category_Name
ORDER BY Total_Profit DESC
LIMIT 10;

--Market wise Performance
SELECT 
    Market,
    ROUND(SUM(Sales), 2)                    AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)   AS Total_Profit,
    COUNT(Order_Id)                          AS Total_Orders,
    ROUND(AVG(Late_delivery_risk)*100, 2)   AS Late_Delivery_Pct
FROM orders_data
GROUP BY Market
ORDER BY Total_Sales DESC;

-- Shipping Mode vs Late Delivery
SELECT 
    Shipping_Mode,
    COUNT(*)                                AS Total_Orders,
    ROUND(AVG(Late_delivery_risk)*100, 2)   AS Late_Delivery_Pct,
    ROUND(SUM(Sales), 2)                    AS Total_Sales
FROM orders_data
GROUP BY Shipping_Mode
ORDER BY Late_Delivery_Pct DESC;


--Top 10 Customers
SELECT 
    Customer_Id,
    CONCAT(Customer_Fname, ' ', Customer_Lname)  AS Customer_Name,
    COUNT(Order_Id)                               AS Total_Orders,
    ROUND(SUM(Sales), 2)                          AS Total_Revenue
FROM orders_data
GROUP BY Customer_Id, Customer_Fname, Customer_Lname
ORDER BY Total_Revenue DESC
LIMIT 10;

--Order Status Breakdown
SELECT 
    Order_Status,
    COUNT(*)                                            AS Total_Orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM orders_data
GROUP BY Order_Status
ORDER BY Total_Orders DESC;

--Department wise Profit
SELECT 
    Department_Name,
    ROUND(SUM(Sales), 2)                    AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)   AS Total_Profit,
    COUNT(Order_Id)                          AS Total_Orders
FROM orders_data
GROUP BY Department_Name
ORDER BY Total_Profit DESC;


--TABLE 2 — web_access_logs

--Top 10 Most Viewed Products
SELECT 
    product_name,
    COUNT(*) AS Total_Views
FROM web_access_logs
GROUP BY product_name
ORDER BY Total_Views DESC
LIMIT 10;

--Category wise Traffic
SELECT 
    category,
    COUNT(*) AS Total_Views
FROM web_access_logs
GROUP BY category
ORDER BY Total_Views DESC;

--Peak Hours
SELECT 
    access_hour,
    COUNT(*) AS Total_Visits
FROM web_access_logs
GROUP BY access_hour
ORDER BY Total_Visits DESC;

--Month wise Traffic
SELECT 
    access_month,
    COUNT(*) AS Total_Visits
FROM web_access_logs
GROUP BY access_month
ORDER BY Total_Visits DESC;

--Department wise Views
SELECT 
    department,
    COUNT(*) AS Total_Views
FROM web_access_logs
GROUP BY department
ORDER BY Total_Views DESC;

--Unique Visitors
SELECT 
    COUNT(DISTINCT ip_address) AS Unique_Visitors
FROM web_access_logs;

--Most Active IPs
SELECT 
    ip_address,
    COUNT(*) AS Total_Visits
FROM web_access_logs
GROUP BY ip_address
ORDER BY Total_Visits DESC
LIMIT 10;

--Hour + Category What was seen at what time?
SELECT 
    access_hour,
    category,
    COUNT(*) AS Total_Views
FROM web_access_logs
GROUP BY access_hour, category
ORDER BY Total_Views DESC
LIMIT 15;


--INNER JOIN (Which products were viewed on the website and also purchased?")
SELECT 
    o.product_name,
    o.category_name,
    COUNT(w.product_name)                       AS Total_Views,
    ROUND(SUM(o.sales)::numeric, 2)             AS Total_Sales,
    ROUND(SUM(o.order_profit_per_order)::numeric, 2) AS Total_Profit
FROM orders_data o
INNER JOIN web_access_logs w
    ON o.product_name = w.product_name
GROUP BY o.product_name, o.category_name
ORDER BY Total_Sales DESC
LIMIT 10;


--LEFT JOIN — High Views Low Sales
-- Ye products zyada dekhe gaye par kum bike — yahan marketing karo!
SELECT 
    w.product_name,
    w.category,
    COUNT(w.product_name)                           AS Total_Views,
    ROUND(COALESCE(SUM(o.sales), 0)::numeric, 2)   AS Total_Sales
FROM web_access_logs w
LEFT JOIN orders_data o
    ON w.product_name = o.product_name
GROUP BY w.product_name, w.category
ORDER BY Total_Views DESC, Total_Sales ASC
LIMIT 10;


--Category — Views + Profit
SELECT 
    o.category_name,
    COUNT(w.product_name)                           AS Total_Views,
    ROUND(SUM(o.sales)::numeric, 2)                 AS Total_Sales,
    ROUND(SUM(o.order_profit_per_order)::numeric, 2) AS Total_Profit
FROM orders_data o
INNER JOIN web_access_logs w
    ON o.category_name = w.category
GROUP BY o.category_name
ORDER BY Total_Profit DESC;

--Department — Traffic vs Revenue
SELECT 
    w.department,
    COUNT(w.product_name)                           AS Total_Views,
    ROUND(SUM(o.sales)::numeric, 2)                 AS Total_Sales,
    ROUND(SUM(o.order_profit_per_order)::numeric, 2) AS Total_Profit
FROM web_access_logs w
LEFT JOIN orders_data o
    ON w.product_name = o.product_name
GROUP BY w.department
ORDER BY Total_Views DESC;


--Peak Hours 
SELECT 
    w.access_hour,
    COUNT(w.product_name)                           AS Total_Views,
    ROUND(SUM(o.sales)::numeric, 2)                 AS Total_Sales,
    COUNT(DISTINCT o.order_id)                       AS Total_Orders
FROM web_access_logs w
LEFT JOIN orders_data o
    ON w.product_name = o.product_name
GROUP BY w.access_hour
ORDER BY Total_Sales DESC;

--Month — Views vs Sales Trend
SELECT 
    w.access_month,
    COUNT(w.product_name)                           AS Total_Views,
    ROUND(SUM(o.sales)::numeric, 2)                 AS Total_Sales
FROM web_access_logs w
LEFT JOIN orders_data o
    ON w.product_name = o.product_name
GROUP BY w.access_month
ORDER BY Total_Sales DESC;

--Market wise (Which product is popular where?)
SELECT 
    o.market,
    o.product_name,
    COUNT(w.product_name)                           AS Total_Views,
    ROUND(SUM(o.sales)::numeric, 2)                 AS Total_Sales
FROM orders_data o
INNER JOIN web_access_logs w
    ON o.product_name = w.product_name
GROUP BY o.market, o.product_name
ORDER BY Total_Sales DESC
LIMIT 15;
