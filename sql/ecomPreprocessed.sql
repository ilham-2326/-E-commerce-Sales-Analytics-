CREATE DATABASE ecommerce_database;
USE ecommerce_database;
select * from ecommerce_preprocessed;
SELECT COUNT(*) FROM ecommerce_preprocessed;

-- 1:  REVENUE KPI's by the Year and Quarter - export sol as csv 
-- WHAT DOES OUR QUARTERLY PERFROMANCE LOOKS LIKE ?  
SELECT
    order_year,
    order_quarter,
    COUNT(DISTINCT order_id)                                        AS total_orders,
    ROUND(SUM(revenue), 2)                                          AS total_revenue,
    ROUND(AVG(revenue), 2)                                          AS avg_order_value,
    ROUND(SUM(revenue) / COUNT(DISTINCT customer_id), 2)            AS revenue_per_customer
FROM ecommerce_preprocessed
WHERE is_return = 0
  AND is_price_outlier = 0
GROUP BY order_year, order_quarter
ORDER BY order_year, order_quarter;
-- ==========================================================================================

-- 2: Month-over-month Revenue Growth 
-- Are we growing? which months spiked or dropped ? 
WITH monthly_revenue AS (
    SELECT
        order_year,
        order_month,
        ROUND(SUM(revenue), 2) AS revenue
    FROM ecommerce_preprocessed
    WHERE is_return = 0
      AND is_price_outlier = 0
    GROUP BY order_year, order_month
)
SELECT
    order_year,
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_year, order_month)            AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year, order_month))
        * 100.0
        / LAG(revenue) OVER (ORDER BY order_year, order_month),
    2)                                                              AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_year, order_month;

-- ==========================================================================================
#3. TOP 3 CITIES BY REVENUE WITHIN EACH REGION 
-- WHICH ARE THE STRONGEST AND WEAKEST MARKETS ? 
WITH city_revenue AS (
    SELECT
        region,
        city,
        COUNT(DISTINCT order_id)        AS total_orders,
        ROUND(SUM(revenue), 2)          AS total_revenue,
        ROUND(AVG(revenue), 2)          AS avg_order_value
    FROM ecommerce_preprocessed
    WHERE is_return = 0
      AND is_price_outlier = 0
    GROUP BY region, city
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY region ORDER BY total_revenue DESC) AS rank_in_region
    FROM city_revenue
)
SELECT *
FROM ranked
WHERE rank_in_region <= 3
ORDER BY region, rank_in_region;

-- ==========================================================================================
-- 4. which category drive revenue and, which have a return problem 
SELECT
    category,
    COUNT(CASE WHEN is_return = 0 THEN 1 END)                           AS total_sales,
    COUNT(CASE WHEN is_return = 1 THEN 1 END)                           AS total_returns,
    ROUND(
        COUNT(CASE WHEN is_return = 1 THEN 1 END) * 100.0 / COUNT(*),
    1)                                                                  AS return_rate_pct,
    ROUND(SUM(CASE WHEN is_return = 0 THEN revenue ELSE 0 END), 2)      AS gross_revenue,
    ROUND(SUM(revenue), 2)                                              AS net_revenue,
    ROUND(AVG(CASE WHEN is_return = 0 THEN rating END), 2)              AS avg_rating
FROM ecommerce_preprocessed
WHERE is_price_outlier = 0
GROUP BY category
ORDER BY net_revenue DESC;

-- ==========================================================================================
-- 5. how diff are new, returning anf VIP customers 
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id)                     AS unique_customers,
    COUNT(DISTINCT order_id)                        AS total_orders,
    ROUND(AVG(revenue), 2)                          AS avg_order_value,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(SUM(revenue) * 100.0 /
        SUM(SUM(revenue)) OVER (), 1)               AS pct_of_total_revenue,
    ROUND(AVG(customer_ltv), 2)                     AS avg_customer_ltv
FROM ecommerce_preprocessed
WHERE is_return = 0
  AND is_price_outlier = 0
GROUP BY customer_segment
ORDER BY total_revenue DESC;
-- ==========================================================================================
-- 6. Should marketing push Apple pay for VIP's? Paypal for new customers ?
SELECT
    customer_segment,
    payment_method,
    COUNT(*)                                                                AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY customer_segment),
    1)                                                                      AS pct_of_segment
FROM ecommerce_preprocessed
WHERE is_return = 0
GROUP BY customer_segment, payment_method
ORDER BY customer_segment, order_count DESC;
-- ==========================================================================================
-- 7. Do discounts actually increase what customers spend ?
SELECT
    CASE
        WHEN discount = 0       THEN 'No discount'
        WHEN discount <= 0.10   THEN '1-10%'
        WHEN discount <= 0.15   THEN '11-15%'
        ELSE                         '16-20%'
    END                                             AS discount_tier,
    COUNT(*)                                        AS total_orders,
    ROUND(AVG(quantity), 2)                         AS avg_quantity,
    ROUND(AVG(revenue), 2)                          AS avg_order_value,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    ROUND(AVG(rating), 2)                           AS avg_rating
FROM ecommerce_preprocessed
WHERE is_return = 0
  AND is_price_outlier = 0
GROUP BY discount_tier
ORDER BY avg_order_value DESC;
-- ==========================================================================================
-- 8. Group customers by their first purchase month, then track how many return in later month 
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_year || '-' || PRINTF('%02d', order_month))   AS cohort_month
    FROM ecommerce_preprocessed
    WHERE is_return = 0
    GROUP BY customer_id
),
activity AS (
    SELECT
        e.customer_id,
        fp.cohort_month,
        e.order_year || '-' || PRINTF('%02d', e.order_month)    AS activity_month
    FROM ecommerce e
    JOIN first_purchase fp ON e.customer_id = fp.customer_id
    WHERE e.is_return = 0
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    a.activity_month,
    cs.cohort_size,
    COUNT(DISTINCT a.customer_id)                                           AS active_customers,
    ROUND(COUNT(DISTINCT a.customer_id) * 100.0 / cs.cohort_size, 1)       AS retention_pct
FROM activity a
JOIN cohort_sizes cs ON a.cohort_month = cs.cohort_month
GROUP BY a.cohort_month, a.activity_month
ORDER BY a.cohort_month, a.activity_month
LIMIT 120;
