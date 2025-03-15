SELECT * FROM walmart LIMIT 10;

SELECT COUNT(*) from walmart;

SELECT payment_method,count(*)
from walmart
group by payment_method;

SELECT 
	COUNT(DISTINCT "Branch") 
FROM walmart;

SELECT MIN(quantity) from walmart;

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold

SELECT payment_method,count(invoice_id) as no_of_transaction,SUM(quantity) as  no_of_qty_sold
from walmart
group by 1;

-- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING


WITH CTE AS (
SELECT "Branch", category, ROUND(AVG(rating)::numeric,2),
RANK() OVER(PARTITION BY "Branch" ORDER BY AVG(rating) DESC) AS Rank
FROM WALMART
GROUP BY "Branch", category)
SELECT * FROM CTE
WHERE rank=1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions

WITH CTE AS (
    SELECT 
        "Branch", 
        TO_CHAR(TO_DATE("date", 'DD/MM/YY'), 'Day') AS day_name, 
        COUNT(*) AS no_of_payments,
        RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY "Branch", day_name
)
SELECT * 
FROM CTE 
WHERE rank = 1;

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT payment_method, SUM(quantity) as no_of_quantity
from walmart
group by 1;

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT "City", category,ROUND(AVG(rating)::numeric,2) as average_rating, MIN(rating) as min_rating, MAX(rating) as max_rating
from walmart
group by "City",category;

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT category, ROUND(SUM(total)::NUMERIC,2) AS total_revenue, ROUND(SUM(total*profit_margin)::NUMERIC,2) as total_profit
from walmart
group by category;


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH CTE AS (SELECT "Branch", payment_method,Count(*) as no_of_payment,
RANK() OVER(PARTITION BY "Branch" ORDER BY Count(*) DESC) AS Rank
FROM walmart
GROUP BY "Branch",payment_method)
SELECT * FROM CTE
WHERE rank=1;

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT 
    "Branch",
    CASE
        WHEN EXTRACT(HOUR FROM "time"::TIME) < 12 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM "time"::TIME) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS Shift,
    COUNT(*) AS no_of_invoices
FROM walmart
GROUP BY "Branch", Shift
ORDER BY "Branch", no_of_invoices DESC;

-- Shift with highest sales for each branch

WITH CTE AS (SELECT 
    "Branch",
    CASE
        WHEN EXTRACT(HOUR FROM "time"::TIME) < 12 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM "time"::TIME) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS "Shift",
    COUNT(*) AS no_of_invoices,
	RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY "Branch", "Shift"
ORDER BY "Branch", no_of_invoices DESC)
SELECT * FROM CTE where rank=1;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year
--to current year (e.g., 2022 to 2023)
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

WITH revenue_2022
AS
(
	SELECT 
		"Branch",
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 
	GROUP BY 1
),
revenue_2023
AS
(

	SELECT 
		"Branch",
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT 
	ls."Branch",
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls."Branch" = cs."Branch"
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5
