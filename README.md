# Music Store Business Intelligence Pipeline (PostgreSQL)

## Project Overview

This project demonstrates how SQL can be used to solve real-world Business Intelligence (BI) problems using the Music Store (Chinook) PostgreSQL database. Instead of writing isolated SQL queries, the solution is designed as a complete analytical pipeline where each stage builds upon the previous one using chained Common Table Expressions (CTEs).

The project applies advanced SQL concepts such as multi-level CTEs, window functions, conditional aggregation, CASE statements, ranking functions, joins, and business KPI calculations to generate meaningful business insights and support data-driven decision making.

---

# Objectives

The pipeline addresses the following business problems:

- Build comprehensive customer spending profiles.
- Segment customers into business categories.
- Recommend personalized marketing campaigns.
- Evaluate countries for future market expansion.
- Produce an executive-level business intelligence report.

---

# Technologies Used

- PostgreSQL
- SQL
- pgAdmin 4

---

# SQL Concepts Implemented

- Common Table Expressions (CTEs)
- Chained CTE Pipeline
- INNER JOIN
- LEFT JOIN
- Aggregate Functions
- Conditional Aggregation
- CASE WHEN
- Window Functions
- ROW_NUMBER()
- RANK()
- GROUP BY
- ORDER BY
- Business KPI Calculations
- Revenue Analysis

---

# Task 1 – Customer Spending Profile

A reusable customer profile was created containing the following business metrics:

- Total Amount Spent
- Total Invoices
- Total Tracks Purchased
- Number of Unique Genres Purchased
- Number of Unique Artists Purchased
- Number of Purchase Months
- Average Invoice Value

The customer profile serves as the foundation for all subsequent tasks, ensuring that calculations are performed only once and reused throughout the pipeline.

---

# Task 2 – Customer Segmentation

## Segmentation Logic and Justification

Customers were segmented using multiple business metrics instead of relying solely on total spending. The segmentation considers:

- Total amount spent
- Purchase frequency (number of invoices)
- Genre diversity
- Artist diversity

The segmentation strategy is based on the assumption that valuable customers are not only high spenders but also loyal customers who purchase frequently and explore a diverse range of music.

### Customer Segments

### Platinum

Customers with:

- Highest total spending
- High purchase frequency
- Wide genre diversity
- High artist diversity

These customers represent the most valuable and loyal customer base.

---

### Gold

Customers with:

- High spending
- Consistent purchasing behaviour
- Moderate music diversity

These customers contribute significantly to overall revenue and have strong retention potential.

---

### Silver

Customers with:

- Moderate spending
- Occasional purchases
- Average diversity in music preferences

These customers represent an opportunity for growth through targeted promotions.

---

### Bronze

Customers with:

- Low spending
- Few purchases
- Limited music diversity

These customers are suitable candidates for acquisition and re-engagement campaigns.

---

# Task 3 – Marketing Recommendation Strategy

The favorite genre of every customer was determined using the ROW_NUMBER() window function.

Each customer was assigned a personalized marketing campaign based on both their customer segment and purchasing behavior.

### Marketing Campaigns

| Customer Segment | Marketing Campaign |
|-----------------|--------------------|
| Platinum | Early Access to New Releases |
| Gold | Album Bundle Discounts |
| Silver | Genre-Specific Discounts |
| Bronze | First Purchase Coupons |

This strategy aims to maximize customer retention while increasing customer lifetime value through personalized promotions.

---

# Task 4 – Country Ranking Methodology

To identify potential expansion markets, a Country Performance Score was developed using multiple business KPIs.

The following metrics were considered:

- Total Revenue
- Total Customers
- Average Revenue per Customer
- Average Invoice Value
- Genre Diversity
- Customer Diversity

A weighted scoring model was created to evaluate each country's business potential.

### Scoring Formula

```
Performance Score =
(40% × Total Revenue)
+ (20% × Revenue per Customer)
+ (20% × Average Invoice Value)
+ (Genre Diversity Weight)
+ (Customer Diversity Weight)
```

Countries were ranked using the SQL `RANK()` window function.

The top-ranked countries represent the strongest candidates for future business expansion because they combine strong revenue generation with a diverse and active customer base.

---

# Task 5 – Executive SQL Report

The final executive dashboard summarizes the complete business analysis and includes:

- Customer Segment Summary
- Revenue by Customer Segment
- Top Customer in Each Segment
- Top Genre in Each Segment
- Best Performing Country
- Revenue Contribution by Country
- Top Employee by Revenue
- Top Artist by Revenue
- Top Album by Revenue

The executive report reuses previously created CTEs instead of recalculating metrics, resulting in a clean and maintainable SQL pipeline.

---

# Actionable Business Recommendations

### 1. Reward Platinum Customers

Provide early access to exclusive releases, loyalty rewards, and premium memberships to maximize retention of the highest-value customers.

---

### 2. Increase Gold Customer Retention

Offer album bundles and personalized recommendations to encourage Gold customers to transition into the Platinum segment.

---

### 3. Re-engage Lower Value Customers

Introduce discounts, coupons, and seasonal promotions to increase purchase frequency among Silver and Bronze customers.

---

### 4. Expand into High-Ranking Countries

Prioritize future investments in the top-performing countries identified by the country performance score, focusing marketing resources where customer engagement and revenue potential are strongest.

---

### 5. Promote High-Revenue Artists and Albums

Feature top-performing artists and albums more prominently in marketing campaigns, homepage recommendations, and promotional playlists to increase sales and customer engagement.

---

# Challenges Faced and Solutions

## Challenge 1

Building multiple analytical queries without repeating calculations.

### Solution

A chained CTE pipeline was developed so each stage reused previous results instead of recalculating metrics.

---

## Challenge 2

Determining customer segments using multiple business factors.

### Solution

A CASE statement was implemented that considered spending, purchase frequency, genre diversity, and artist diversity to create meaningful customer segments.

---

## Challenge 3

Identifying each customer's favorite genre.

### Solution

The ROW_NUMBER() window function was used to rank genres by purchase frequency for every customer, allowing the most frequently purchased genre to be selected.

---

## Challenge 4

Creating a meaningful country ranking instead of relying solely on total revenue.

### Solution

Multiple business KPIs were combined into a weighted Country Performance Score to provide a more balanced evaluation of market potential.

---

## Challenge 5

Maintaining readability in a long SQL script.

### Solution

The project was structured into logical stages using descriptive CTEs and comments, resulting in a reusable and maintainable Business Intelligence pipeline.

---

# Key Learning Outcomes

Through this project, the following SQL and analytical skills were strengthened:

- Designing reusable SQL pipelines
- Writing complex chained CTEs
- Using window functions for ranking and analysis
- Applying CASE statements for business segmentation
- Calculating business KPIs
- Building executive dashboards using SQL
- Translating business problems into analytical SQL solutions
- Producing maintainable and scalable SQL code

---

# Deliverables

- `business_intelligence_pipeline.sql`
- `README.md`
- Customer Segmentation Screenshot
- Country Ranking Screenshot
- Executive Dashboard Screenshot
- Successful SQL Pipeline Execution Screenshot

---

# Conclusion

This project demonstrates how advanced SQL can be applied to solve practical Business Intelligence problems. By organizing the solution as a reusable SQL pipeline, the analysis remains efficient, maintainable, and scalable. The generated insights support customer segmentation, targeted marketing, strategic market expansion, and executive decision-making, showcasing the role of SQL in real-world business analytics.

---

# Author

#### Mehreen Fatima
