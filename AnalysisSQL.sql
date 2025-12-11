
CREATE TABLE public.df_orders(
    order_id        VARCHAR(50) PRIMARY KEY,
    order_date      DATE NOT NULL,
    ship_mode       VARCHAR(50),
    segment         VARCHAR(50),
    country         VARCHAR(100),
    city            VARCHAR(100),
    state           VARCHAR(100),
    postal_code     VARCHAR(20),
    region          VARCHAR(50),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_id      VARCHAR(50),
    quantity        INTEGER,
    discount        NUMERIC(5,2),
    sale_price      NUMERIC(10,2),
    profit          NUMERIC(10,2)
);

SELECT * FROM public.df_orders t;

--Find the top 10 Highest revenue generating products
SELECT 
	product_id,
	category, 
	SUM(sale_price) AS revenue
FROM df_orders t 
GROUP BY product_id, category 
ORDER BY revenue DESC
LIMIT 10;

--Find the top 5 highest selling products IN EACH region
WITH cte AS (
SELECT 
	product_id,
	region,
	SUM(sale_price) AS revenue
FROM df_orders t
GROUP BY product_id , region) 
SELECT * FROM (SELECT *, row_number() OVER(PARTITION BY region ORDER BY revenue DESC) AS rank_num
FROM cte) 
WHERE rank_num<=5;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
SELECT 
	EXTRACT(YEAR FROM order_date) AS order_year,
	EXTRACT(MONTH FROM order_date) AS order_month,
	SUM(sale_price) AS sales
FROM df_orders
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY order_year, order_month
)
SELECT 
	order_month,
	SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
	SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

--For each category which month had highest sales
WITH cte AS (
SELECT 
	category,
	SUM(sale_price) AS sales,
	EXTRACT(MONTH FROM order_date) AS order_month,
	EXTRACT(YEAR  FROM order_date) AS order_year
FROM df_orders
GROUP BY category, EXTRACT(MONTH FROM order_date), EXTRACT(YEAR  FROM order_date)
)
SELECT * FROM (
SELECT 
	sales,
	order_month,
	category,
	order_year,
	row_number() over(PARTITION BY category ORDER BY sales DESC) AS row_num
FROM cte)
WHERE row_num = 1;

--Which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
SELECT 
	sub_category,
	SUM(profit) AS total_profit,
	EXTRACT(YEAR FROM order_date) AS order_year
FROM df_orders
GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
)
, cte_two AS (
SELECT 
	sub_category,
	SUM(CASE WHEN order_year=2022 THEN total_profit ELSE 0 END) AS profit_2022,
	SUM(CASE WHEN order_year=2023 THEN total_profit ELSE 0 END) AS profit_2023
FROM cte
GROUP BY sub_category
)
SELECT 
	sub_category,
	profit_2023 - profit_2022 AS growth_profit
FROM cte_two
ORDER BY growth_profit DESC 
LIMIT 1;












