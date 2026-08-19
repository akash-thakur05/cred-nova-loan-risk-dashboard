-- ============================================================
-- Cred Nova : Loan Portfolio & Credit Risk Analytics Dashboard
-- Step 2: Synthetic Data Generation
-- Run AFTER create_tables.sql, in this exact order (FK dependency)
-- ============================================================

USE CreditCardRiskAnalytics;
GO

-- ------------------------------------------------------------
-- 1. Customers (1,000 rows)
-- ------------------------------------------------------------
INSERT INTO Customers (customer_id, first_name, last_name, date_of_birth, gender, phone_number, email, address_line, city, state, annual_income, employment_type, customer_since)
SELECT
    n,
    CASE (ABS(CHECKSUM(rid)) % 15)
        WHEN 0 THEN 'Rahul' WHEN 1 THEN 'Priya' WHEN 2 THEN 'Amit' WHEN 3 THEN 'Sneha'
        WHEN 4 THEN 'Vikas' WHEN 5 THEN 'Neha' WHEN 6 THEN 'Rohit' WHEN 7 THEN 'Anjali'
        WHEN 8 THEN 'Karan' WHEN 9 THEN 'Pooja' WHEN 10 THEN 'Arjun' WHEN 11 THEN 'Divya'
        WHEN 12 THEN 'Manish' WHEN 13 THEN 'Kavita' ELSE 'Suresh'
    END,
    CASE (ABS(CHECKSUM(rid)) % 10)
        WHEN 0 THEN 'Sharma' WHEN 1 THEN 'Verma' WHEN 2 THEN 'Gupta' WHEN 3 THEN 'Singh'
        WHEN 4 THEN 'Kumar' WHEN 5 THEN 'Yadav' WHEN 6 THEN 'Mishra' WHEN 7 THEN 'Chauhan'
        WHEN 8 THEN 'Agarwal' ELSE 'Tiwari'
    END,
    DATEADD(YEAR, -(22 + (ABS(CHECKSUM(rid)) % 38)), GETDATE()),
    CASE (ABS(CHECKSUM(rid)) % 2) WHEN 0 THEN 'Male' ELSE 'Female' END,
    '9' + RIGHT('000000000' + CAST(ABS(CHECKSUM(rid)) % 1000000000 AS VARCHAR), 9),
    'customer' + CAST(n AS VARCHAR) + '@gmail.com',
    CAST(n AS VARCHAR) + ' Sector ' + CAST(1 + (ABS(CHECKSUM(rid)) % 100) AS VARCHAR),
    CASE (ABS(CHECKSUM(rid)) % 6)
        WHEN 0 THEN 'Noida' WHEN 1 THEN 'Gurgaon' WHEN 2 THEN 'Delhi'
        WHEN 3 THEN 'Ghaziabad' WHEN 4 THEN 'Faridabad' ELSE 'Greater Noida'
    END,
    CASE (ABS(CHECKSUM(rid)) % 3)
        WHEN 0 THEN 'Uttar Pradesh' WHEN 1 THEN 'Haryana' ELSE 'Delhi'
    END,
    250000 + (ABS(CHECKSUM(rid)) % 30) * 50000,
    CASE (ABS(CHECKSUM(rid)) % 3)
        WHEN 0 THEN 'Salaried' WHEN 1 THEN 'Self-Employed' ELSE 'Business'
    END,
    DATEADD(DAY, -(ABS(CHECKSUM(rid)) % 1825), GETDATE())
FROM (
    SELECT n, NEWID() AS rid
    FROM (
        SELECT TOP 1000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c
    ) AS Numbers
) AS WithRandomId;
GO

-- ------------------------------------------------------------
-- 2. Credit_Cards (1,200 rows)
-- ------------------------------------------------------------
INSERT INTO Credit_Cards (card_id, customer_id, card_number, card_type, credit_limit, card_status, issue_date)
SELECT n, 1 + (ABS(CHECKSUM(rid)) % 1000),
    'XXXX-XXXX-XXXX-' + RIGHT('0000' + CAST(ABS(CHECKSUM(rid)) % 10000 AS VARCHAR), 4),
    CASE (ABS(CHECKSUM(rid)) % 3) WHEN 0 THEN 'Visa' WHEN 1 THEN 'MasterCard' ELSE 'RuPay' END,
    50000 + (ABS(CHECKSUM(rid)) % 20) * 25000,
    CASE (ABS(CHECKSUM(rid)) % 10) WHEN 0 THEN 'Blocked' WHEN 1 THEN 'Closed' ELSE 'Active' END,
    DATEADD(DAY, -(ABS(CHECKSUM(rid)) % 1800), GETDATE())
FROM (SELECT n, NEWID() AS rid FROM (SELECT TOP 1200 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c) AS Numbers) AS W;
GO

-- ------------------------------------------------------------
-- 3. Credit_Score_History (4,000 rows, ~4 per customer)
-- ------------------------------------------------------------
INSERT INTO Credit_Score_History (score_id, customer_id, score_date, credit_score)
SELECT n, 1 + ((n - 1) % 1000),
    DATEADD(MONTH, -(((n - 1) / 1000) * 3), GETDATE()),
    300 + (ABS(CHECKSUM(rid)) % 601)
FROM (SELECT n, NEWID() AS rid FROM (SELECT TOP 4000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c) AS Numbers) AS W;
GO

-- ------------------------------------------------------------
-- 4. Loans (600 rows)
-- ------------------------------------------------------------
INSERT INTO Loans (loan_id, customer_id, loan_type, loan_amount, interest_rate, tenure_months, disbursed_date, loan_status)
SELECT n, 1 + (ABS(CHECKSUM(rid)) % 1000),
    CASE (ABS(CHECKSUM(rid)) % 4) WHEN 0 THEN 'Personal' WHEN 1 THEN 'Auto' WHEN 2 THEN 'Home' ELSE 'Business' END,
    100000 + (ABS(CHECKSUM(rid)) % 40) * 50000,
    8 + (ABS(CHECKSUM(rid)) % 10),
    CASE (ABS(CHECKSUM(rid)) % 4) WHEN 0 THEN 12 WHEN 1 THEN 24 WHEN 2 THEN 36 ELSE 60 END,
    DATEADD(DAY, -(ABS(CHECKSUM(rid)) % 1500), GETDATE()),
    CASE (ABS(CHECKSUM(rid)) % 10) WHEN 0 THEN 'Default' WHEN 1 THEN 'Closed' ELSE 'Active' END
FROM (SELECT n, NEWID() AS rid FROM (SELECT TOP 600 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c) AS Numbers) AS W;
GO

-- ------------------------------------------------------------
-- 5. EMI_Payments (6,000 rows, ~10 per loan)
-- ------------------------------------------------------------
INSERT INTO EMI_Payments (emi_id, loan_id, due_date, paid_date, emi_amount, dpd, payment_status)
SELECT n, 1 + ((n - 1) % 600),
    DATEADD(MONTH, -(((n - 1) / 600)), GETDATE()),
    CASE WHEN (ABS(CHECKSUM(rid)) % 10) < 8 THEN DATEADD(DAY, (ABS(CHECKSUM(rid)) % 5), DATEADD(MONTH, -(((n - 1) / 600)), GETDATE())) ELSE NULL END,
    5000 + (ABS(CHECKSUM(rid)) % 15) * 1000,
    CASE WHEN (ABS(CHECKSUM(rid)) % 10) < 8 THEN (ABS(CHECKSUM(rid)) % 5) ELSE 30 + (ABS(CHECKSUM(rid)) % 90) END,
    CASE WHEN (ABS(CHECKSUM(rid)) % 10) < 8 THEN 'Paid' WHEN (ABS(CHECKSUM(rid)) % 10) = 8 THEN 'Partial' ELSE 'Missed' END
FROM (SELECT n, NEWID() AS rid FROM (SELECT TOP 6000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c) AS Numbers) AS W;
GO

-- ------------------------------------------------------------
-- 6. Collections (1,200 rows)
-- ------------------------------------------------------------
INSERT INTO Collections (collection_id, customer_id, contact_date, contact_method, outcome, amount_collected)
SELECT n, 1 + (ABS(CHECKSUM(rid)) % 1000),
    DATEADD(DAY, -(ABS(CHECKSUM(rid)) % 365), GETDATE()),
    CASE (ABS(CHECKSUM(rid)) % 4) WHEN 0 THEN 'Call' WHEN 1 THEN 'SMS' WHEN 2 THEN 'Email' ELSE 'Letter' END,
    CASE (ABS(CHECKSUM(rid)) % 3) WHEN 0 THEN 'Promise to Pay' WHEN 1 THEN 'No Response' ELSE 'Disputed' END,
    CASE WHEN (ABS(CHECKSUM(rid)) % 3) = 0 THEN 1000 + (ABS(CHECKSUM(rid)) % 10) * 500 ELSE 0 END
FROM (SELECT n, NEWID() AS rid FROM (SELECT TOP 1200 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c) AS Numbers) AS W;
GO

-- ------------------------------------------------------------
-- 7. Recovery (250 rows)
-- ------------------------------------------------------------
INSERT INTO Recovery (recovery_id, customer_id, charge_off_amount, recovery_date, recovered_amount, recovery_agency)
SELECT n, 1 + (ABS(CHECKSUM(rid)) % 1000),
    20000 + (ABS(CHECKSUM(rid)) % 30) * 5000,
    DATEADD(DAY, -(ABS(CHECKSUM(rid)) % 300), GETDATE()),
    (ABS(CHECKSUM(rid)) % 15000),
    CASE (ABS(CHECKSUM(rid)) % 3) WHEN 0 THEN 'ARC Recovery Agency' WHEN 1 THEN 'Legal Recovery Partners' ELSE 'Internal Recovery Team' END
FROM (SELECT n, NEWID() AS rid FROM (SELECT TOP 250 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c) AS Numbers) AS W;
GO

-- ------------------------------------------------------------
-- 8. Calendar (900 rows, ~2.5 years of daily dates)
-- ------------------------------------------------------------
INSERT INTO Calendar (calendar_date, day_name, month_name, month_number, quarter, year)
SELECT d, DATENAME(WEEKDAY, d), DATENAME(MONTH, d), MONTH(d), DATEPART(QUARTER, d), YEAR(d)
FROM (
    SELECT DATEADD(DAY, n - 1, '2024-01-01') AS d
    FROM (SELECT TOP 900 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.objects a CROSS JOIN sys.objects b) AS Numbers
) AS Dates;
GO

-- ------------------------------------------------------------
-- Verify row counts
-- ------------------------------------------------------------
SELECT 'Customers' AS TableName, COUNT(*) AS RowCount FROM Customers
UNION ALL SELECT 'Credit_Cards', COUNT(*) FROM Credit_Cards
UNION ALL SELECT 'Credit_Score_History', COUNT(*) FROM Credit_Score_History
UNION ALL SELECT 'Loans', COUNT(*) FROM Loans
UNION ALL SELECT 'EMI_Payments', COUNT(*) FROM EMI_Payments
UNION ALL SELECT 'Collections', COUNT(*) FROM Collections
UNION ALL SELECT 'Recovery', COUNT(*) FROM Recovery
UNION ALL SELECT 'Calendar', COUNT(*) FROM Calendar;
GO
