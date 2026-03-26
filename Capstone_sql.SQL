--- 1 
SELECT 
    Ticker_Symbol, AVG(Net_Income) AS avg_net_income
FROM
    fundamentals
GROUP BY Ticker_Symbol
ORDER BY avg_net_income DESC
LIMIT 3;

-- 2

with t as 
(SELECT 
    Ticker_Symbol, 
    For_Year, 
    Total_Revenue,
    LAG(Total_Revenue) OVER (ORDER BY For_Year) as Previous_year
FROM
    fundamentals
where Ticker_Symbol = 'AAL')

select Ticker_Symbol, 
    For_Year, 
    Total_Revenue,
    Previous_year,
   round(((Total_Revenue - Previous_year)/ Previous_year)*100,2) as YOY_Growth
    from t;
   

-- 3
SELECT 
    For_year,
    ticker_symbol,
    Profit_Margin,
    Net_Income,
    Total_Revenue
FROM
    fundamentals
where Profit_Margin < 0;

-- 4
SELECT 
    ticker_symbol, AVG(Quick_Ratio) AS AVG
FROM
    fundamentals
GROUP BY Ticker_Symbol
HAVING AVG < 1;

-- 5
SELECT 
    Ticker_Symbol,
    For_Year,
    Research_and_Development,
    AVG(Research_and_Development) OVER (PARTITION BY Ticker_Symbol
        ORDER BY For_Year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Rolling_3Yr_Avg_RD
FROM fundamentals;

-- 6
SELECT *
FROM (
    SELECT 
        Ticker_Symbol,
        For_Year,
        Capital_Expenditures,
        LAG(Capital_Expenditures,1) OVER (
            PARTITION BY Ticker_Symbol ORDER BY For_Year
        ) AS Prev1,
        LAG(Capital_Expenditures,2) OVER (
            PARTITION BY Ticker_Symbol ORDER BY For_Year
        ) AS Prev2
    FROM fundamentals
) as t
WHERE Prev2 < Prev1
AND Prev1 < Capital_Expenditures;

-- 7
SELECT 
    For_Year,
    SUM(Total_Liabilities) AS Total_Liabilities_All
FROM fundamentals
GROUP BY For_Year
ORDER BY Total_Liabilities_All DESC
LIMIT 5;

-- 8
SELECT 
    Ticker_Symbol,
    For_Year,
    Net_Cash_Flow_Operating
FROM (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY Ticker_Symbol
               ORDER BY Net_Cash_Flow_Operating DESC
           ) AS rn
    FROM fundamentals
) t
WHERE rn = 1;

-- 9
SELECT 
    Ticker_Symbol,
    AVG(Earnings_Per_Share) AS Avg_EPS
FROM fundamentals
WHERE Total_Equity > 5000000000
AND Operating_Margin > 0.10
GROUP BY Ticker_Symbol;

--  10
SELECT 
(COUNT(*) * SUM(Research_And_Development * Net_Income) -
SUM(Research_And_Development) * SUM(Net_Income))
/
SQRT((COUNT(*) * SUM(POWER(Research_And_Development,2))
-
POWER(SUM(Research_And_Development),2))
*
(COUNT(*) * SUM(POWER(Net_Income,2))
-
POWER(SUM(Net_Income),2))) AS Correlation
FROM fundamentals
WHERE Ticker_Symbol = 'AAL';