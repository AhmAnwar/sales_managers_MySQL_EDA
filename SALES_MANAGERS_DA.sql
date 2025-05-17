-- DATA CLEANING
-- SHOW DATASET
SELECT 
    *
FROM
    data_projects.sales_managers;
--
-- CREATE A COPY TABLE
CREATE TABLE C_SALES_MANAGERS LIKE data_projects.sales_managers;
--
-- INSERT DATA INTO THE NEW TABLE
INSERT INTO data_projects.c_sales_managers
SELECT *
FROM data_projects.sales_managers;
--
-- SHOW NEW DATASET
SELECT 
    *
FROM
    data_projects.c_sales_managers;
--
-- DROP COLUMNS
ALTER TABLE data_projects.c_sales_managers
DROP COLUMN MyUnknownColumn;
--
-- RENAME COLUMNS
ALTER TABLE data_projects.c_sales_managers
RENAME COLUMN `MyUnknownColumn_[0]` TO `Order_ID`,
RENAME COLUMN `MyUnknownColumn_[1]` TO `Date`,
RENAME COLUMN `MyUnknownColumn_[2]` TO `Product`,
RENAME COLUMN `MyUnknownColumn_[3]` TO `Price`,
RENAME COLUMN `MyUnknownColumn_[4]` TO `Quantity`,
RENAME COLUMN `MyUnknownColumn_[5]` TO `Purchase_Type`,
RENAME COLUMN `MyUnknownColumn_[6]` TO `Payment_Method`,
RENAME COLUMN `MyUnknownColumn_[7]` TO `Manager`,
RENAME COLUMN `MyUnknownColumn_[8]` TO `City`;
--
-- DROP THE UNUSEFUEL ROW
DELETE FROM data_projects.c_sales_managers 
WHERE
    Order_ID = 'Order ID';
--
-- CONVERT DATA TYPE
-- TO DATE
SELECT 
    Date, STR_TO_DATE(Date, '%m/%d/%Y') AS FORMAT_DATE
FROM
    data_projects.c_sales_managers;
--
SELECT 
    COUNT(STR_TO_DATE(Date, '%m/%d/%Y')) AS COUNT_NULL
FROM
    data_projects.c_sales_managers
WHERE
    STR_TO_DATE(Date, '%m/%d/%Y') IS NULL;
--
UPDATE data_projects.c_sales_managers 
SET 
    Date = STR_TO_DATE(Date, '%m/%d/%Y');
--
ALTER TABLE data_projects.c_sales_managers
MODIFY COLUMN Date DATE;
--
-- CONVERT TO FLOAT
-- Price & Quantity
SELECT Price, CONVERT(Price, FLOAT) AS FLOAT_PRICE, Quantity, CONVERT(Quantity, FLOAT) AS FLOAT_QUANTITY
FROM data_projects.c_sales_managers;
--
ALTER TABLE data_projects.c_sales_managers
MODIFY COLUMN Price FLOAT,
MODIFY COLUMN Quantity FLOAT;
--
-- CALCULATE NEW COLUMN CALLED Profit
ALTER TABLE data_projects.c_sales_managers
ADD COLUMN Profit FLOAT;
--
UPDATE data_projects.c_sales_managers 
SET 
    Profit = Price * Quantity;
--
-- REMOVE WHITE SPACES
UPDATE data_projects.c_sales_managers 
SET 
    Manager = TRIM(Manager);
--
UPDATE data_projects.c_sales_managers 
SET 
    Manager = REPLACE(Manager, '  ', ' ')
WHERE
    Manager LIKE '%  %';
--
UPDATE data_projects.c_sales_managers 
SET 
    Manager = REPLACE(Manager, '   ', ' ')
WHERE
    Manager LIKE '%   %';
--
-- DATA ANALYSIS PHASE
-- 1. HOW MUCH PROFIT FOR EACH MANAGER?
SELECT 
    Manager, ROUND(SUM(Profit), 2) AS SUM_PROFIT
FROM
    data_projects.c_sales_managers
GROUP BY Manager
ORDER BY SUM_PROFIT DESC;
--
-- 2. HOW MANY ORDERS FOR EACH MANAGER?
SELECT 
    Manager, COUNT(Order_ID) AS ORDERS_COUNT
FROM
    data_projects.c_sales_managers
GROUP BY Manager
ORDER BY ORDERS_COUNT DESC;
--
-- 3. HOW MUCH PROFIT FOR EACH MANAGER REGARDING TO (PRODUCT, Purchase_Type, Payment_Method)
-- & ORDERS COUNT, AVERAGE PRICE, QUANTITIES?
SELECT 
    Manager,
    Product,
    Purchase_Type,
    Payment_Method,
    ROUND(SUM(Profit), 2) AS PROFIT_SUM,
    COUNT(Order_ID) AS ORDERS_COUNT,
    ROUND(AVG(Price), 2) AS AVG_PRICE,
    ROUND(SUM(Quantity), 0) AS QUANTITY_SUM
FROM
    data_projects.c_sales_managers
GROUP BY Manager , Product , Purchase_Type , Payment_Method
ORDER BY Manager , PROFIT_SUM DESC;
--
-- 4. HOW MANY CITIES FOR EACH MANAGER THAT MAKES PROFIT?
SELECT 
    Manager, City, ROUND(SUM(Profit), 2) AS PROFIT_SUM
FROM
    data_projects.c_sales_managers
GROUP BY Manager , CITY
ORDER BY PROFIT_SUM DESC;
--
-- 5. HOW MUCH PERCENTAGE PROFIT & ORDERS OF TOTAL FOR EACH MANAGER?
SELECT 
    Manager,
    SUM(Profit) AS PROFIT_SUM,
    (SELECT 
		SUM(PROFIT) 
        FROM data_projects.c_sales_managers) AS TOTAL_PROFIT,
    (SUM(Profit) / (SELECT 
						SUM(PROFIT) 
                        FROM data_projects.c_sales_managers) * 100) AS PERCENATAGE,
    COUNT(Order_ID) AS ORDERS_COUNT,
    (SELECT 
		COUNT(Order_ID) 
        FROM data_projects.c_sales_managers) AS TOTAL_ORDERS,
    (COUNT(Order_ID) / (SELECT 
							COUNT(Order_ID) 
                            FROM data_projects.c_sales_managers)) * 100 AS ORDER_PERCENT
FROM
    data_projects.c_sales_managers
GROUP BY Manager
ORDER BY PROFIT_SUM DESC;