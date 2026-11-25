/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Users\ASIF\Desktop\Asif Personal Work\SQL\sql-data-analytics-project\datasets\flat-files\dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Users\ASIF\Desktop\Asif Personal Work\SQL\sql-data-analytics-project\datasets\flat-files\dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Users\ASIF\Desktop\Asif Personal Work\SQL\sql-data-analytics-project\datasets\flat-files\fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


/*---			Advance Analytics			---*/

/*7.		Change Over Time Analysis Trends			*/
-- Analyze how a measure evolves over time.
-- Helps track trend and identify seasonlity in data

-- SQL Task:
-- Analyze Sales Perofrmnace Over Time
SELECT [order_date], [sales_amount]
FROM [gold].[fact_sales]
ORDER BY [order_date]

SELECT [order_date], [sales_amount]
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
ORDER BY [order_date]

SELECT [order_date], SUM([sales_amount])
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
GROUP BY [order_date]
ORDER BY [order_date]

-- CHNAGES OVER YEAR:A HIGH LEVEL OVERVIEW INSIGHTS THAT HELPS WITH STRATEGIC DECISION-MAKING
SELECT YEAR([order_date]) AS ORDER_YR, 
		SUM([sales_amount]) AS TOTAL_SALES, 
		COUNT(DISTINCT([customer_key])) AS TOTAL_CUSTOMERS,
		SUM([quantity]) AS TIOTAL_QTY
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
GROUP BY YEAR([order_date])
ORDER BY YEAR([order_date])

-- CHNAGES OVER MONTH
-- DETAILED INSIGHT TO DISCOVER SEASONLITY IN YOUR DATA
SELECT MONTH([order_date]) AS ORDER_MONTH, 
		SUM([sales_amount]) AS TOTAL_SALES, 
		COUNT(DISTINCT([customer_key])) AS TOTAL_CUSTOMERS,
		SUM([quantity]) AS TIOTAL_QTY
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
GROUP BY MONTH([order_date])
ORDER BY MONTH([order_date])

SELECT YEAR([order_date]), MONTH([order_date]) AS ORDER_MONTH, 
		SUM([sales_amount]) AS TOTAL_SALES, 
		COUNT(DISTINCT([customer_key])) AS TOTAL_CUSTOMERS,
		SUM([quantity]) AS TIOTAL_QTY
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
GROUP BY YEAR([order_date]), MONTH([order_date])
ORDER BY YEAR([order_date]), MONTH([order_date])


SELECT DATETRUNC(MONTH,[order_date]) AS ORDER_DATE,
		SUM([sales_amount]) AS TOTAL_SALES, 
		COUNT(DISTINCT([customer_key])) AS TOTAL_CUSTOMERS,
		SUM([quantity]) AS TIOTAL_QTY
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
GROUP BY DATETRUNC(MONTH,[order_date])
ORDER BY DATETRUNC(MONTH,[order_date])

-- THE PROBLEM IN THE BELOW QUERY IS THAT THEY ARE NOT SORT
SELECT FORMAT([order_date],'yyyy-MMM') AS ORDER_DATE,
		SUM([sales_amount]) AS TOTAL_SALES, 
		COUNT(DISTINCT([customer_key])) AS TOTAL_CUSTOMERS,
		SUM([quantity]) AS TIOTAL_QTY
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
GROUP BY FORMAT([order_date],'yyyy-MMM') 
ORDER BY FORMAT([order_date],'yyyy-MMM') 

SELECT FORMAT(DATETRUNC(MONTH,[order_date]),'yyyy-MMM') AS ORDER_DATE,
		SUM([sales_amount]) AS TOTAL_SALES, 
		COUNT(DISTINCT([customer_key])) AS TOTAL_CUSTOMERS,
		SUM([quantity]) AS TIOTAL_QTY
FROM [gold].[fact_sales]
WHERE [order_date] IS NOT NULL
GROUP BY DATETRUNC(MONTH,[order_date])
ORDER BY DATETRUNC(MONTH,[order_date])

SELECT
    FORMAT(DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1), 'yyyy-MMM') AS ORDER_DATE,
    SUM(sales_amount) AS TOTAL_SALES,
    COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS,
    SUM(quantity) AS TOTAL_QTY
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

SELECT DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) AS Current_Month;
SELECT FORMAT(DATETRUNC(MONTH, GETDATE()), 'yyyy-MMM') AS Current_Month;



/*8.			CUMULATIVE ANALYSIS			*/
-- AGGREGATE THE DATA PROGRESSIVELY OVER TIME
-- HELPS TO UNDERSTAND WHETHER BUSINESS IS GROWING OR DECLINING

-- SQL Task:
-- CALCULATE TOAL SALES PER MONTH AND RUNNING TOTAL OF SALES OVER TIME.

-- DEFAULT WINDOW FRAME: BETWEEN UNBOUNDED PRECECDING AND CURRENT ROW
SELECT ORDER_DATE, TOTAL_SALES, SUM(TOTAL_SALES) OVER (ORDER BY ORDER_DATE) AS RUNNING_SALES
FROM 
	(
	SELECT DATETRUNC(MONTH, [order_date]) AS ORDER_DATE,
		SUM([sales_amount]) AS TOTAL_SALES
	FROM [gold].[fact_sales]
	WHERE [order_date] IS NOT NULL 
	GROUP BY DATETRUNC(MONTH, [order_date])
	) T 

-- NOW PARTIONING THE DATA FOR EACH YEAR
SELECT ORDER_DATE, TOTAL_SALES, SUM(TOTAL_SALES) OVER (PARTITION BY YEAR(ORDER_DATE) ORDER BY ORDER_DATE) AS RUNNING_SALES
FROM 
	(
	SELECT DATETRUNC(MONTH, [order_date]) AS ORDER_DATE,
		SUM([sales_amount]) AS TOTAL_SALES
	FROM [gold].[fact_sales]
	WHERE [order_date] IS NOT NULL 
	GROUP BY DATETRUNC(MONTH, [order_date])
	) T 

SELECT ORDER_DATE, TOTAL_SALES, SUM(TOTAL_SALES) OVER (ORDER BY ORDER_DATE) AS RUNNING_SALES,
		AVG(CUMULATIVE_AVG) OVER (ORDER BY ORDER_DATE) AS CUMULATIVE_AVG
FROM 
	(
	SELECT DATETRUNC(YEAR, [order_date]) AS ORDER_DATE,
		SUM([sales_amount]) AS TOTAL_SALES,
		AVG([price]) AS CUMULATIVE_AVG
	FROM [gold].[fact_sales]
	WHERE [order_date] IS NOT NULL 
	GROUP BY DATETRUNC(YEAR, [order_date])
	) T 



/*9.			PRFORMANCE ANALYSIS			*/

-- COMPARING THE CURRENT VALUE TO A TARGET VALUE
-- HELPS MEASURE SUCCESS AND COMPARE PEROFRMANCE

-- TASK:
-- ANALYZE THE YEARLY PERFORMACE OF THE PRODUCTS BY COMPARING EACH PRODUCT'S SALES TO BOTH ITS AVERAGE SALES
-- PERFORMANCE AND THE PREVIOUS YEAR'S SALES.

WITH YEARLY_PRODUCT_SALES AS (
	SELECT YEAR(F.[order_date]) AS ORDER_YEAR, P.[product_name], SUM(F.[sales_amount]) AS CURRENT_SALES
	FROM [gold].[fact_sales] AS F LEFT JOIN [gold].[dim_products] AS P ON F.[product_key] =P.[product_key]
	WHERE F.[order_date] IS NOT NULL
	GROUP BY  YEAR(F.[order_date]), P.[product_name]
	)
SELECT ORDER_YEAR, [product_name], CURRENT_SALES,
	AVG(CURRENT_SALES) OVER (PARTITION BY [product_name]) AS AVG_SALES,
	CURRENT_SALES - AVG(CURRENT_SALES) OVER (PARTITION BY [product_name]) AS DIFF_AVG,
	CASE 
		WHEN CURRENT_SALES - AVG(CURRENT_SALES) OVER (PARTITION BY [product_name]) > 0 THEN 'ABOVE AVG'
		WHEN CURRENT_SALES - AVG(CURRENT_SALES) OVER (PARTITION BY [product_name]) < 0 THEN 'BELOW AVG'
		ELSE 'AVG'
	END AVG_CHNAGE,
-- YOY ANALYSIS
	LAG(CURRENT_SALES) OVER (PARTITION  BY [product_name] ORDER BY ORDER_YEAR) AS PRE_YR_SALES,
	CURRENT_SALES - LAG(CURRENT_SALES) OVER (PARTITION  BY [product_name] ORDER BY ORDER_YEAR) AS DIFF_PY,
	CASE 
		WHEN CURRENT_SALES - LAG(CURRENT_SALES) OVER (PARTITION  BY [product_name] ORDER BY ORDER_YEAR) > 0 THEN 'INCREASE'
		WHEN CURRENT_SALES - LAG(CURRENT_SALES) OVER (PARTITION  BY [product_name] ORDER BY ORDER_YEAR) < 0 THEN 'DECREASE'
		ELSE 'NO CHNAGE'
		END PY_CHANGE
FROM YEARLY_PRODUCT_SALES
ORDER BY [product_name], ORDER_YEAR	

/*10.			PART TO WHOLE PROPORTIONL			*/
-- ANALYZE HOW AN INDIVIDUAL PART IS PERFORMING COMPARED TO TEH OVERALL ALLOWING 
-- US TO UNDERSTAND WHICH CATEGORY HAS THE GREATEST IMPACT ON THE BUSINESS
-- ([MEASURES] / TOTAL[MEASURES]) * 100 

-- SQL TASK:
-- WHICH CATEGORY CONTRIBUTE THE MOST TO OVERALL SALES
WITH CATEGORY_SALES AS (
	SELECT P.[category],SUM([sales_amount]) AS TOTAL_SALES
	FROM  [gold].[fact_sales] AS F LEFT JOIN [gold].[dim_products] AS P ON F.[product_key] = P.[product_key]
	GROUP BY P.[category] )

SELECT [category], TOTAL_SALES,
	SUM(TOTAL_SALES) OVER () OVERALL_SALES,
	CONCAT(ROUND(( CAST (TOTAL_SALES AS FLOAT) /SUM(TOTAL_SALES) OVER ()) * 100,2),'%')  AS PERCENTAGE_OF_TOTAL_SALES
FROM CATEGORY_SALES
ORDER BY TOTAL_SALES DESC



/*11.			DATA SEGMENTATION			*/
-- GROUP THE ADTA BASED ON  SPECIFIC RANGE 
-- HELPS UNDERSTAND THE CORRELATION BETWEEN THE MEASURES.
-- USED: CASE WHEN STATEMENT 

-- SQL TASK:
-- SEGMEENT PRODUCTS INTO COST RANGES AND COUNT HOW MANY PRODUCTS FALL INTO EACH SEGMENT
WITH PRODUCT_SEGMENT AS (
SELECT [product_key], [product_name], [cost],
	CASE WHEN [cost] < 100 THEN 'BELOW 100'
	WHEN [cost] BETWEEN 100 AND 500 THEN '100-500'
	WHEN [cost] BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'ABOVE 1000'
	END 'COST_RANGE'
FROM [gold].[dim_products] )
SELECT  COST_RANGE, COUNT([product_key]) AS TOTAL_PRODUCTS
FROM PRODUCT_SEGMENT
GROUP BY COST_RANGE
ORDER BY TOTAL_PRODUCTS DESC 

/* GROUP CUSTOMERS INTO 3 SGMENT BASED ON THEIR SPENDING BEHAVIOUR
	- VIP : CUSTOMER WITH ATLEAST 12 MONTHS OF HISTORY AND SPENDING MORE THAN $5,000.
	- REGULAR: CUSTOMER WITH ATLEAST 12 MONTHS OF HISTORY AND SPENDING $5,000 OR LESS.
	- NEW: CUSTOMERS WITH LIFE SPAN LESS THAN 12 MONTHS.
AND FIND TH TOTAL NUO. OF CUSTOMERS BY EACH GROUP
*/
WITH CUSTOMER_SPENDING AS (
SELECT C.[customer_key], SUM(F.[sales_amount]) AS TOTAL_SPENDING,
	MIN([order_date]) AS FIRST_ORDER, MAX([order_date]) AS LAST_ORDER,
	DATEDIFF(MONTH, MIN([order_date]), MAX([order_date])) AS LIFE_SPAN
FROM [gold].[fact_sales] F LEFT JOIN [gold].[dim_customers] C ON F.[customer_key] = C.[customer_key]
GROUP BY C.[customer_key] )
SELECT CUSTOMER_SEGMENT, COUNT([customer_key]) AS TOTAL_CUSTOMERS
FROM (
	SELECT [customer_key],
		CASE WHEN LIFE_SPAN > 12 AND TOTAL_SPENDING > 5000 THEN 'VIP'
			 WHEN LIFE_SPAN >= 12 AND TOTAL_SPENDING <= 5000 THEN 'REGULAR'
		ELSE 'NEW'
		END CUSTOMER_SEGMENT
	FROM CUSTOMER_SPENDING ) T
GROUP BY CUSTOMER_SEGMENT
ORDER BY TOTAL_CUSTOMERS DESC



/*12.			BUILD CUSTOMER REPORT			*/
/* 
=====================================================================================
CUSTOMER REPORT
=====================================================================================
PURPOSE: 
		- THIS REPORT CONSOLIDATES KEY CUSTOMER METRICS AND BEHAVIOURS
HIGHLIGHTS: 
	1.GATHERS ESSENTIAL FILED SUCH AS NAMES, AGES, TRANSCTION DETAILS 
	2. SEGMENTS CUSTOMERS INTO CATEGORIES (VIP, REGULAR, NEW) AND AGE GROUPS
	3. AGGREGATE CUSTOMERS-LEVEL METRICS: 
		- TOTAL ORDER
		- TOTAL SALES
		- TOTAL QUANTITY PURCHASE 
		- LIFESPAN (IN MONTHS)
	4. CALCULATE VALUABLE KPI'S
		- RECENCY (MONTH SINCE LAST ORDER)
		- AVERAGE ORDER VALUE
		- AVERAGE MONTHLY SPEND
*/
/* ------------------------------------------------------------------------------------------
1) BASE QUERY: RETRIEVES CORE COLUMN FROM  TABLES
------------------------------------------------------------------------------------------ */

CREATE VIEW gold.report_customers AS
WITH BASE_QUERY AS (
-- 1) BASE QUERY: RETRIEVES CORE COLUMN FROM  TABLES
SELECT F. [order_number], F.[product_key], F.[order_date], F.[sales_amount] , F.[quantity],
		C.[customer_key] , C.[customer_number], C.[first_name], C.[last_name], CONCAT(C.[first_name],' ', C.[last_name]) AS CUSTOMER_NAME, 
		C.[birthdate], DATEDIFF(YEAR,  C.[birthdate], '2024-01-01') AS AGE
FROM [gold].[fact_sales] F LEFT JOIN [gold].[dim_customers] C ON F.[customer_key] = C.[customer_key]
WHERE F.[order_date] IS NOT NULL ),
CUSTOMER_AGGREGATION AS (
-- 2. SEGMENTS CUSTOMERS INTO CATEGORIES (VIP, REGULAR, NEW) AND AGE GROUPS
SELECT CUSTOMER_KEY, CUSTOMER_NUMBER, CUSTOMER_NAME, AGE,
	COUNT(DISTINCT ORDER_NUMBER) AS TOTAL_ORDERS,
	SUM(SALES_AMOUNT) AS TOTAL_SALES,
	SUM(QUANTITY) AS TOTAL_QUANTITY,
	COUNT(DISTINCT PRODUCT_KEY) AS  TOTAL_PRODUCTS, MAX(ORDER_DATE) AS LAST_ORDER_DATE, 
	DATEDIFF(MONTH, MIN(ORDER_DATE), MAX(ORDER_DATE)) AS LIFE_SPAN
FROM BASE_QUERY
GROUP BY CUSTOMER_KEY, CUSTOMER_NUMBER, CUSTOMER_NAME, AGE ) 
SELECT CUSTOMER_KEY, CUSTOMER_NUMBER, CUSTOMER_NAME, AGE, 
-- - RECENCY (MONTH SINCE LAST ORDER) 
DATEDIFF(MONTH, LAST_ORDER_DATE , GETDATE()) AS RECENCY ,
	CASE WHEN AGE < 20 THEN 'UNDER 20'
	WHEN AGE BETWEEN 20 AND 29 THEN '20-29' 
	WHEN AGE BETWEEN 30 AND 39 THEN '30-39' 
	WHEN AGE BETWEEN 40 AND 49 THEN '40-49' 
	ELSE  '50 & ABOVE'
	END AS AGE_GROUP,
	CASE WHEN LIFE_SPAN > 12 AND TOTAL_SALES > 5000 THEN 'VIP'
			 WHEN LIFE_SPAN >= 12 AND TOTAL_SALES <= 5000 THEN 'REGULAR'
		ELSE 'NEW'
		END CUSTOMER_SEGMENT,TOTAL_SALES,LIFE_SPAN,
	TOTAL_ORDERS,
-- AVERAGE ORDER VALUE (AOV): TOTAL SALES/ TOTAL NR.	 OF ORDERS
	CASE WHEN TOTAL_SALES = 0 THEN 0 
	ELSE TOTAL_SALES / TOTAL_ORDERS 
	END AS AOV,
	TOTAL_QUANTITY, TOTAL_PRODUCTS, LAST_ORDER_DATE,
-- AVERAGE MONTHLY SPEND: TOTAL SALES / NR OF MONTHS
CASE WHEN LIFE_SPAN = 0 THEN TOTAL_SALES
ELSE TOTAL_SALES/LIFE_SPAN
END AS AVG_MNTHLY_SPEND
FROM CUSTOMER_AGGREGATION

-- USE THE ABOVE QUERY AS VIEW AND THEN 
-- READY TO CREATE DAHSBOARD USING POWER BI 
-- QUICKLY GENERATE REPORT 
-- IN TOP OF VIEW WRITE QUERY TO GENEARTE INSIHGHTS



/*12.			BUILD PRODUCT REPORT			*/

/* 
=====================================================================================
PRODUCT REPORT
=====================================================================================
PURPOSE: 
		- THIS REPORT CONSOLIDATES KEY PRODUCT METRICS AND BEHAVIOURS
HIGHLIGHTS: 
	1.GATHERS ESSENTIAL FILED SUCH AS PRODUCT, CATEGORY, SUBCATEGORY AND COST 
	2. SEGMENTS PRODUCTS BY  REVENUE TO IDENTIFY HIGH-PERFORMERS, MID-RANGE OR LOW-PERFORMERS
	3. AGGREGATE PRODUCT-LEVEL METRICS: 
		- TOTAL ORDER
		- TOTAL SALES
		- TOTAL QUANTITY SOLD 
		- TOTAL CUSTOMERS (UNIQUE)
		- LIFE SPAN IN MOMTHS
	4. CALCULATE VALUABLE KPI'S
		- RECENCY (MONTH SINCE LAST SALE)
		- AVERAGE ORDER REVENUE (AOR)
		- AVERAGE MONTHLY REVENUE
*/
CREATE VIEW gold.report_products AS 
WITH BASE_QUERY2 AS (
/* --------------------------------------------------------------------------------------------------------
1) BASE QUERY: RETRIEVES CORE COLUMNS FROM FACT_SALES AND DIM_PRODUCTS
--------------------------------------------------------------------------------------------------------*/
    SELECT 
        F.[order_date],
        P.[product_key],
        P.[product_name],
        P.[product_number],
        P.[category_id],
        P.[category],
        P.[subcategory],
        P.[cost],
        F.[sales_amount],
        F.[customer_key],
        F.[order_number],
        F.[quantity],

        CASE 
            WHEN F.[sales_amount] < 100 THEN 'BELOW 100'
            WHEN F.[sales_amount] BETWEEN 100 AND 500 THEN '100-500'
            WHEN F.[sales_amount] BETWEEN 501 AND 1000 THEN '501-1000'
            ELSE 'ABOVE 1000'
        END AS PRD_SEGMENT

    FROM [gold].[fact_sales] F
    LEFT JOIN [gold].[dim_products] P 
        ON F.[product_key] = P.[product_key]
    WHERE F.[order_date] IS NOT NULL
),

PRODUCT_AGGREGATION AS (
/* --------------------------------------------------------------------------------------------------------
2) PRODUCT AGGREGATION: SUMMARIZE KEY METRICS AT THE PRODUCT LEVEL 
--------------------------------------------------------------------------------------------------------*/
    SELECT 
        [product_key],
        [product_name],
        [category],
        [subcategory],
        [cost],

        DATEDIFF(MONTH, MIN([order_date]), MAX([order_date])) AS LIFE_SPAN,
        MAX([order_date]) AS LAST_SALE_DATE,

        COUNT(DISTINCT [order_number]) AS TOTAL_ORDERS,
        COUNT(DISTINCT [customer_key]) AS TOTAL_CUSTOMERS,

        SUM([sales_amount]) AS TOTAL_SALES,
        SUM([quantity]) AS TOTAL_QTY_SOLD,

        ROUND(
            AVG(CAST([sales_amount] AS FLOAT) / NULLIF([quantity], 0)), 1
        ) AS AVG_SELLING_PRICE

    FROM BASE_QUERY2

    GROUP BY 
        [product_key],
        [product_name],
        [category],
        [subcategory],
        [cost]
)
/* --------------------------------------------------------------------------------------------------------
3) FINAL QUERY  COMBINE ALL PRODUCTS RESULTS INTO ONE OUTPUT
--------------------------------------------------------------------------------------------------------*/
SELECT 
    [product_key],
    [product_name],
    [category],
    [subcategory],
    [cost],
    LAST_SALE_DATE,

    DATEDIFF(MONTH, LAST_SALE_DATE, '2025-01-01') AS RECENCY_IN_MONTHS,

    CASE 
        WHEN TOTAL_SALES > 50000 THEN 'HIGH-PERFORMER'
        WHEN TOTAL_SALES >= 10000 THEN 'MID-RANGE'
        ELSE 'LOW-PERFORMER'
    END AS PRODUCT_SEGMENT,

    LIFE_SPAN,
    TOTAL_ORDERS,
    TOTAL_SALES,
    TOTAL_QTY_SOLD,
    TOTAL_CUSTOMERS,
    AVG_SELLING_PRICE,

    CASE 
        WHEN TOTAL_ORDERS = 0 THEN 0
        ELSE TOTAL_SALES / TOTAL_ORDERS
    END AS AVG_ORDER_REVENUE

FROM PRODUCT_AGGREGATION 
