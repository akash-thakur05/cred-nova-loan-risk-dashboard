-- ============================================================
-- Cred Nova : Loan Portfolio & Credit Risk Analytics Dashboard
-- Step 3: SQL Views (pre-joined, business-logic-ready layer)
-- Run AFTER create_tables.sql and insert_data.sql
-- ============================================================

USE CreditCardRiskAnalytics;
GO

-- ------------------------------------------------------------
-- View 1: Loan Portfolio (Customer + Loan info combined)
-- ------------------------------------------------------------
CREATE VIEW vw_Loan_Portfolio AS
SELECT
    l.loan_id,
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.city,
    c.state,
    c.annual_income,
    c.employment_type,
    l.loan_type,
    l.loan_amount,
    l.interest_rate,
    l.tenure_months,
    l.disbursed_date,
    l.loan_status
FROM Loans l
JOIN Customers c ON l.customer_id = c.customer_id;
GO

-- ------------------------------------------------------------
-- View 2: EMI Repayment with DPD Buckets
-- (90+ DPD = NPA, per RBI classification norms)
-- ------------------------------------------------------------
CREATE VIEW vw_EMI_Repayment AS
SELECT
    e.emi_id,
    e.loan_id,
    l.customer_id,
    e.due_date,
    e.paid_date,
    e.emi_amount,
    e.dpd,
    e.payment_status,
    CASE
        WHEN e.dpd = 0 THEN 'Current'
        WHEN e.dpd BETWEEN 1 AND 30 THEN '1-30 DPD'
        WHEN e.dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN e.dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE '90+ DPD (NPA)'
    END AS dpd_bucket
FROM EMI_Payments e
JOIN Loans l ON e.loan_id = l.loan_id;
GO

-- ------------------------------------------------------------
-- View 3: Collections & Recovery Summary
-- LEFT JOIN used because not every collection case has a
-- matching recovery record (recovery only applies post charge-off)
-- ------------------------------------------------------------
CREATE VIEW vw_Collections_Recovery AS
SELECT
    col.collection_id,
    col.customer_id,
    col.contact_date,
    col.contact_method,
    col.outcome,
    col.amount_collected,
    r.recovery_id,
    r.charge_off_amount,
    r.recovered_amount,
    r.recovery_agency
FROM Collections col
LEFT JOIN Recovery r ON col.customer_id = r.customer_id;
GO

-- ------------------------------------------------------------
-- Verify views
-- ------------------------------------------------------------
SELECT TOP 10 * FROM vw_Loan_Portfolio;
SELECT TOP 10 * FROM vw_EMI_Repayment;
SELECT TOP 10 * FROM vw_Collections_Recovery;
GO
