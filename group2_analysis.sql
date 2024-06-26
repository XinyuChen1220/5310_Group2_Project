/*
1. "How much profit does each office make each month after accounting for all expenses?"
*/
WITH monthly_expenses AS (
    SELECT 
        office_id, 
        DATE_TRUNC('month', expense_date) AS expense_month,
        SUM(expense_amount) AS total_expenses
    FROM 
        expense
    GROUP BY 
        office_id, expense_month
),
monthly_revenues AS (
    SELECT 
        e.office_id, 
        DATE_TRUNC('month', t.time) AS revenue_month,
        SUM(t.revenues) AS total_revenues
    FROM 
        transaction t
    JOIN 
        employee e ON t.employees_id = e.employees_id
    GROUP BY 
        e.office_id, revenue_month
),
profit_calculation AS (
    SELECT 
        o.office_name,
        COALESCE(mr.revenue_month, me.expense_month) AS month,
        COALESCE(mr.total_revenues, 0) AS revenues,
        COALESCE(me.total_expenses, 0) AS expenses,
        COALESCE(mr.total_revenues, 0) - COALESCE(me.total_expenses, 0) AS profit
    FROM 
        office o
    LEFT JOIN monthly_revenues mr ON o.office_id = mr.office_id
    LEFT JOIN monthly_expenses me ON o.office_id = me.office_id AND me.expense_month = mr.revenue_month
)
SELECT 
    office_name,
    TO_CHAR(month, 'YYYY-MM') AS month,
    SUM(revenues) AS monthly_revenues,
    SUM(expenses) AS monthly_expenses,
    SUM(profit) AS monthly_profit
FROM 
    profit_calculation
GROUP BY 
    office_name, month
ORDER BY 
    office_name, month;


/*
2. "What is the average client satisfaction rating for each office, 
ordered from highest to lowest?"
*/

SELECT 
    o.office_name,
    AVG(cf.rating) AS average_rating
FROM 
    client_feedback cf
JOIN 
    employee e ON cf.employees_id = e.employees_id
JOIN 
    office o ON e.office_id = o.office_id
GROUP BY 
    o.office_name
ORDER BY 
    average_rating DESC;
	
/*
3."How many schools are there in each neighborhood, 
what's the average school rating, and what are the crime rates?
*/

SELECT 
    n.neighborhood_name,
    COUNT(s.school_id) AS number_of_schools,
    AVG(s.school_rating) AS average_school_rating,
    n.crime_rate
FROM 
    neighborhood n
JOIN 
    address a ON n.neighborhood_id = a.neighborhood_id
JOIN 
    school s ON a.address_id = s.address_id
GROUP BY 
    n.neighborhood_name, n.crime_rate
ORDER BY 
    AVG(s.school_rating) DESC,
    n.crime_rate ASC;

/*
4."What is the monthly count of listings for each property type, 
specifically for apartments, condos, single-family homes, and townhouses?"
*/

SELECT 
    p.type AS property_type,
    DATE_TRUNC('month', l.listing_date) AS month,
    COUNT(l.listing_id) AS total_listings
FROM 
    property p
JOIN 
    listing l ON p.property_id = l.property_id
WHERE 
    p.type IN ('Apartment', 'Condo', 'Single Family Home', 'TownHouse')
GROUP BY 
    property_type, month
ORDER BY 
    property_type, month;
	
/*
5. "What are the average rental and sale prices for properties in each city?"
*/

SELECT
    addr.city,
    ROUND(AVG(CASE WHEN lst.sale_type = 'Rent' THEN trans.price END)) AS average_rent_price,
    ROUND(AVG(CASE WHEN lst.sale_type = 'Sale' THEN trans.price END)) AS average_sale_price
FROM
    transaction trans
JOIN
    listing lst ON trans.listing_id = lst.listing_id
JOIN
    property prop ON lst.property_id = prop.property_id
JOIN
    address addr ON prop.address_id = addr.address_id
GROUP BY
    addr.city;

/*
6. "What is the price ratio for each transaction, along with the transaction details 
such as time, listing ID, list price, and final price?"
*/

SELECT 
    t.transaction_id,
    t.time,
    t.listing_id,
    l.list_price,
    t.price,
    (t.price / l.list_price) AS price_ratio
FROM 
    transaction t
INNER JOIN 
    listing l ON t.listing_id = l.listing_id;

/*
7."What are the top 10 employees in terms of total sales, 
including their employee IDs, names, number of sales, and total sales amount?"
*/

SELECT 
    e.employees_id,
    pi.name AS employee_name,
    COUNT(t.transaction_id) AS sales_count,
    SUM(t.price) AS total_sales
FROM 
    employee e
JOIN 
    personal_info pi ON e.personal_info_id = pi.personal_info_id
JOIN 
    transaction t ON e.employees_id = t.employees_id
GROUP BY 
    e.employees_id, pi.name
ORDER BY 
    total_sales DESC
LIMIT 10;

/*
8."What is the number of properties with each type of amenity, 
and what is the average listing price for properties with those amenities?"
*/

SELECT 
    pa.amenities,
    COUNT(pa.property_id) AS properties_with_amenity,
    AVG(l.list_price) AS average_price_of_properties_with_amenity
FROM 
    property_amenities pa
JOIN 
    property p ON pa.property_id = p.property_id
JOIN 
    listing l ON p.property_id = l.property_id
GROUP BY 
    pa.amenities
ORDER BY 
    properties_with_amenity DESC;
	
/*
9."What is the average number of days properties remain on the market 
for rent and for sale in each neighborhood?"
*/
	
SELECT
    n.neighborhood_name,
    ROUND(AVG(CASE WHEN lst.sale_type = 'Rent' THEN EXTRACT(day FROM AGE(trans.time, lst.listing_date)) END)) AS average_days_on_market_rent,
    ROUND(AVG(CASE WHEN lst.sale_type = 'Sale' THEN EXTRACT(day FROM AGE(trans.time, lst.listing_date)) END)) AS average_days_on_market_sale
FROM
    transaction trans
JOIN
    listing lst ON trans.listing_id = lst.listing_id
JOIN
    property p ON lst.property_id = p.property_id
JOIN
    address a ON p.address_id = a.address_id
JOIN
    neighborhood n ON a.neighborhood_id = n.neighborhood_id
GROUP BY
    n.neighborhood_name
ORDER BY
    n.neighborhood_name;

/*
10.
"Who are the clients that have completed more than two transactions, 
including their IDs, names, total number of transactions, and total amount spent?"
*/

SELECT 
    c.clients_id,
    pi.name AS client_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.price) AS total_spent
FROM 
    client c
JOIN 
    personal_info pi ON c.personal_info_id = pi.personal_info_id
JOIN 
    transaction t ON c.clients_id = t.clients_id
GROUP BY 
    c.clients_id, pi.name
HAVING 
    COUNT(t.transaction_id) > 2
ORDER BY 
    transaction_count DESC;
	


/*
11. "Which properties are currently listed but have not yet been sold or rented?"
*/

SELECT 
    p.property_id,
    p.type,
    p.description,
    l.list_price,
    l.listing_date
FROM 
    listing l
LEFT JOIN 
    transaction t ON l.listing_id = t.listing_id
JOIN 
    property p ON l.property_id = p.property_id
WHERE 
    t.listing_id IS NULL;
	

SELECT*FROM transaction


/*
12. "What is yearly revenue growth by office?"
*/

WITH yearly_revenues AS (
    SELECT 
        e.office_id,
        EXTRACT(year FROM t.time) AS year,
        SUM(t.revenues) AS total_revenue
    FROM 
        transaction t
    JOIN 
        employee e ON t.employees_id = e.employees_id
    GROUP BY 
        e.office_id, year
)
SELECT 
    o.office_name,
    a.year,
    a.total_revenue AS revenue_this_year,
    b.total_revenue AS revenue_last_year,
    (a.total_revenue - b.total_revenue) / b.total_revenue * 100 AS growth_percentage
FROM 
    yearly_revenues a
JOIN 
    yearly_revenues b ON a.office_id = b.office_id AND a.year = b.year + 1
JOIN 
    office o ON a.office_id = o.office_id
ORDER BY 
    o.office_name, a.year;


/*
13. "What is customer retention rate by sale type and year?"
*/
WITH client_transactions AS (
    SELECT
        clients_id,
        lst.sale_type,
        EXTRACT(year FROM t.time) AS transaction_year,
        COUNT(*) AS transactions
    FROM
        transaction t
    JOIN
        listing lst ON t.listing_id = lst.listing_id
    GROUP BY
        clients_id, lst.sale_type, transaction_year
),
yearly_client_summary AS (
    SELECT
        clients_id,
        sale_type,
        transaction_year,
        transactions,
        LAG(transactions) OVER (PARTITION BY clients_id, sale_type ORDER BY transaction_year) AS previous_year_transactions
    FROM
        client_transactions
),
retention_analysis AS (
    SELECT
        sale_type,
        transaction_year,
        COUNT(*) AS total_clients,
        COUNT(*) FILTER (WHERE previous_year_transactions > 0 AND transactions > 0) AS retained_clients,
        ROUND(COUNT(*) FILTER (WHERE previous_year_transactions > 0 AND transactions > 0)::numeric / COUNT(*) * 100, 2) AS retention_rate
    FROM
        yearly_client_summary
    GROUP BY
        sale_type, transaction_year
)
SELECT 
    sale_type,
    transaction_year,
    total_clients,
    retained_clients,
    retention_rate
FROM 
    retention_analysis
ORDER BY 
    sale_type, transaction_year DESC;

/*
14. "What is the most popular property type by year and sale type?"
*/

SELECT 
    p.type AS property_type,
    EXTRACT(year FROM t.time) AS transaction_year,
    lst.sale_type,
    COUNT(*) AS transaction_count
FROM 
    transaction t
JOIN 
    listing lst ON t.listing_id = lst.listing_id
JOIN 
    property p ON lst.property_id = p.property_id
GROUP BY 
    property_type, transaction_year, lst.sale_type
ORDER BY 
    transaction_year DESC, lst.sale_type, transaction_count DESC;
	

/*
15. "What is the average days to close the listing for the agents?"
*/
SELECT 
    e.employees_id,
    pi.name AS employee_name,
    o.office_name,
    ROUND(AVG(EXTRACT(day FROM AGE(t.time, l.listing_date))), 1) AS average_days_to_close
FROM 
    transaction t
JOIN 
    listing l ON t.listing_id = l.listing_id
JOIN 
    employee e ON t.employees_id = e.employees_id
JOIN 
    personal_info pi ON e.personal_info_id = pi.personal_info_id
JOIN 
    office o ON e.office_id = o.office_id
GROUP BY 
    e.employees_id, pi.name, o.office_name
ORDER BY 
    average_days_to_close;


