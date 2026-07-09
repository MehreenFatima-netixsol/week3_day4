SELECT table_name
FROM information_schema.tables
WHERE table_schema='public';
--Inspecting Tables
SELECT * FROM customer LIMIT 5;
SELECT * FROM invoice LIMIT 5;
SELECT * FROM invoice_line LIMIT 5;
SELECT * FROM track LIMIT 5;
SELECT * FROM genre LIMIT 5;
SELECT * FROM album LIMIT 5;
SELECT * FROM artist LIMIT 5;
SELECT * FROM employee LIMIT 5;
--===============Business Intelligence Pipeline==============
--TASK 01 - Build Customer Spending Profile

WITH invoice_summary AS (

    SELECT
        customer_id,
        SUM(total) AS total_spent,
        COUNT(invoice_id) AS total_invoices,
        AVG(total) AS average_invoice_value,
        COUNT(DISTINCT DATE_TRUNC('month', invoice_date)) AS purchase_months

    FROM invoice

    GROUP BY customer_id
),

track_summary AS (

    SELECT
        i.customer_id,
        COUNT(il.invoice_line_id) AS total_tracks,
        COUNT(DISTINCT t.genre_id) AS unique_genres,
        COUNT(DISTINCT ar.artist_id) AS unique_artists

    FROM invoice i

    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id

    JOIN track t
        ON il.track_id = t.track_id

    JOIN album al
        ON t.album_id = al.album_id

    JOIN artist ar
        ON al.artist_id = ar.artist_id

    GROUP BY i.customer_id
),

customer_profile AS (

    SELECT

        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,

        COALESCE(i.total_spent,0) AS total_spent,
        COALESCE(i.total_invoices,0) AS total_invoices,
        COALESCE(t.total_tracks,0) AS total_tracks,
        COALESCE(t.unique_genres,0) AS unique_genres,
        COALESCE(t.unique_artists,0) AS unique_artists,
        COALESCE(i.purchase_months,0) AS purchase_months,
        ROUND(i.average_invoice_value,2) AS average_invoice_value

    FROM customer c

    LEFT JOIN invoice_summary i
        ON c.customer_id = i.customer_id

    LEFT JOIN track_summary t
        ON c.customer_id = t.customer_id
)


--TASK 02 Customer Segmentation

,

customer_segments AS (

    SELECT
        *,

        CASE

            WHEN total_spent >= 45
                 AND total_invoices >= 6
                 AND unique_genres >= 6
                 AND unique_artists >= 10
            THEN 'Platinum'

            WHEN total_spent >= 30
                 AND total_invoices >= 4
                 AND unique_genres >= 4
            THEN 'Gold'

            WHEN total_spent >= 15
                 AND total_invoices >= 2
            THEN 'Silver'

            ELSE 'Bronze'

        END AS customer_segment

    FROM customer_profile

)

--TASK 3 - PERSONALIZED MARKETING RECOMMENDATION

,

customer_genre_counts AS (

    SELECT

        i.customer_id,
        g.genre_id,
        g.name AS genre_name,
        COUNT(*) AS purchases

    FROM invoice i

    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id

    JOIN track t
        ON il.track_id = t.track_id

    JOIN genre g
        ON t.genre_id = g.genre_id

    GROUP BY
        i.customer_id,
        g.genre_id,
        g.name
),

favorite_genres AS (

    SELECT

        customer_id,
        genre_name,
        purchases,

        ROW_NUMBER() OVER(
            PARTITION BY customer_id
            ORDER BY purchases DESC, genre_name
        ) AS rn

    FROM customer_genre_counts

),

customer_marketing AS (

    SELECT

        cs.customer_id,
        cs.first_name,
        cs.last_name,
        cs.customer_segment,
        fg.genre_name AS favorite_genre,

        CASE

            WHEN customer_segment='Platinum'
                THEN 'Early Access to New Releases'

            WHEN customer_segment='Gold'
                THEN 'Album Bundle Discounts'

            WHEN customer_segment='Silver'
                THEN 'Genre-Specific Discounts'

            ELSE 'First Purchase Coupon'

        END AS marketing_campaign

    FROM customer_segments cs

    LEFT JOIN favorite_genres fg

        ON cs.customer_id=fg.customer_id

    WHERE fg.rn=1

)

--TASK 4 - COUNTRY EXPANSION STRATEGY


,

country_metrics AS (

    SELECT

        c.country,

        SUM(i.total) AS total_revenue,

        COUNT(DISTINCT c.customer_id) AS total_customers,

        ROUND(
            SUM(i.total)/
            COUNT(DISTINCT c.customer_id),
            2
        ) AS revenue_per_customer,

        ROUND(
            AVG(i.total),
            2
        ) AS average_invoice_value,

        COUNT(DISTINCT g.genre_id) AS genre_diversity,

        COUNT(DISTINCT c.city) AS customer_diversity

    FROM customer c

    JOIN invoice i

        ON c.customer_id=i.customer_id

    JOIN invoice_line il

        ON i.invoice_id=il.invoice_id

    JOIN track t

        ON il.track_id=t.track_id

    JOIN genre g

        ON t.genre_id=g.genre_id

    GROUP BY c.country

),

country_scores AS (

    SELECT

        *,

        ROUND(

            (total_revenue*0.40)

            +

            (revenue_per_customer*0.20)

            +

            (average_invoice_value*0.20)

            +

            (genre_diversity*2)

            +

            (customer_diversity*3)

        ,2)

        AS performance_score

    FROM country_metrics

),

country_rankings AS (

    SELECT

        *,

        RANK() OVER(

            ORDER BY performance_score DESC

        ) AS country_rank

    FROM country_scores

)


--TASK 5 - EXECUTIVE SQL REPORT

,

segment_summary AS (

    SELECT

        customer_segment,

        COUNT(*) AS total_customers,

        ROUND(SUM(total_spent),2) AS total_revenue,

        ROUND(AVG(total_spent),2) AS average_spending

    FROM customer_segments

    GROUP BY customer_segment

),

top_customer AS (

    SELECT

        customer_segment,

        first_name || ' ' || last_name AS customer_name,

        total_spent,

        ROW_NUMBER() OVER(

            PARTITION BY customer_segment

            ORDER BY total_spent DESC

        ) AS rn

    FROM customer_segments

),

segment_genre AS (

    SELECT

        cm.customer_segment,

        fg.genre_name,

        COUNT(*) AS purchases,

        ROW_NUMBER() OVER(

            PARTITION BY cm.customer_segment

            ORDER BY COUNT(*) DESC

        ) AS rn

    FROM customer_marketing cm

    JOIN favorite_genres fg

        ON cm.customer_id = fg.customer_id

    WHERE fg.rn = 1

    GROUP BY

        cm.customer_segment,
        fg.genre_name

),

employee_revenue AS (

    SELECT

        e.employee_id,

        e.first_name || ' ' || e.last_name AS employee_name,

        ROUND(SUM(i.total),2) AS revenue,

        ROW_NUMBER() OVER(

            ORDER BY SUM(i.total) DESC

        ) AS rn

    FROM employee e

    JOIN customer c

        ON e.employee_id = c.support_rep_id

    JOIN invoice i

        ON c.customer_id = i.customer_id

    GROUP BY

        e.employee_id,
        employee_name

),

artist_revenue AS (

    SELECT

        ar.artist_id,

        ar.name AS artist_name,

        ROUND(SUM(il.unit_price * il.quantity),2) AS revenue,

        ROW_NUMBER() OVER(

            ORDER BY SUM(il.unit_price * il.quantity) DESC

        ) AS rn

    FROM artist ar

    JOIN album al

        ON ar.artist_id = al.artist_id

    JOIN track t

        ON al.album_id = t.album_id

    JOIN invoice_line il

        ON t.track_id = il.track_id

    GROUP BY

        ar.artist_id,
        ar.name

),

album_revenue AS (

    SELECT

        al.album_id,

        al.title,

        ROUND(SUM(il.unit_price * il.quantity),2) AS revenue,

        ROW_NUMBER() OVER(

            ORDER BY SUM(il.unit_price * il.quantity) DESC

        ) AS rn

    FROM album al

    JOIN track t

        ON al.album_id = t.album_id

    JOIN invoice_line il

        ON t.track_id = il.track_id

    GROUP BY

        al.album_id,
        al.title

),

country_contribution AS (

    SELECT

        country,

        total_revenue,

        ROUND(

            total_revenue
            *100.0/
            SUM(total_revenue) OVER(),

            2

        ) AS revenue_percentage

    FROM country_rankings

)
SELECT

    ss.customer_segment,

    ss.total_customers,

    ss.total_revenue,

    tc.customer_name AS top_customer,

    sg.genre_name AS top_genre,

    cr.country AS best_country,

    cc.revenue_percentage,

    er.employee_name AS top_employee,

    ar.artist_name AS top_artist,

    abr.title AS top_album

FROM segment_summary ss

LEFT JOIN top_customer tc

ON ss.customer_segment = tc.customer_segment
AND tc.rn = 1

LEFT JOIN segment_genre sg

ON ss.customer_segment = sg.customer_segment
AND sg.rn = 1

CROSS JOIN (

    SELECT *

    FROM country_rankings

    WHERE country_rank = 1

) cr

CROSS JOIN (

    SELECT *

    FROM employee_revenue

    WHERE rn = 1

) er

CROSS JOIN (

    SELECT *

    FROM artist_revenue

    WHERE rn = 1

) ar

CROSS JOIN (

    SELECT *

    FROM album_revenue

    WHERE rn = 1

) abr

LEFT JOIN country_contribution cc

ON cr.country = cc.country

ORDER BY

ss.total_revenue DESC;




