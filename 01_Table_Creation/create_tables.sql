-- ============================================================
-- Cred Nova : Loan Portfolio & Credit Risk Analytics Dashboard
-- Step 1: Database & Table Creation
-- ============================================================

CREATE DATABASE CreditCardRiskAnalytics;
GO

USE CreditCardRiskAnalytics;
GO

-- ------------------------------------------------------------
-- 1. Customers (Independent table)
-- ------------------------------------------------------------
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10),
    phone_number VARCHAR(15),
    email VARCHAR(100),
    address_line VARCHAR(150),
    city VARCHAR(50),
    state VARCHAR(50),
    annual_income DECIMAL(12,2),
    employment_type VARCHAR(30),
    customer_since DATE
);
GO

-- ------------------------------------------------------------
-- 2. Credit_Cards (Depends on Customers)
-- ------------------------------------------------------------
CREATE TABLE Credit_Cards (
    card_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    card_number VARCHAR(20),
    card_type VARCHAR(20),
    credit_limit DECIMAL(12,2),
    card_status VARCHAR(20),
    issue_date DATE
);
GO

-- ------------------------------------------------------------
-- 3. Credit_Score_History (Depends on Customers)
-- ------------------------------------------------------------
CREATE TABLE Credit_Score_History (
    score_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    score_date DATE,
    credit_score INT
);
GO

-- ------------------------------------------------------------
-- 4. Loans (Depends on Customers)
-- ------------------------------------------------------------
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    loan_type VARCHAR(30),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    tenure_months INT,
    disbursed_date DATE,
    loan_status VARCHAR(20)
);
GO

-- ------------------------------------------------------------
-- 5. EMI_Payments (Depends on Loans)
-- ------------------------------------------------------------
CREATE TABLE EMI_Payments (
    emi_id INT PRIMARY KEY,
    loan_id INT FOREIGN KEY REFERENCES Loans(loan_id),
    due_date DATE,
    paid_date DATE NULL,
    emi_amount DECIMAL(12,2),
    dpd INT,
    payment_status VARCHAR(20)
);
GO

-- ------------------------------------------------------------
-- 6. Collections (Depends on Customers)
-- ------------------------------------------------------------
CREATE TABLE Collections (
    collection_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    contact_date DATE,
    contact_method VARCHAR(20),
    outcome VARCHAR(30),
    amount_collected DECIMAL(12,2)
);
GO

-- ------------------------------------------------------------
-- 7. Recovery (Depends on Customers)
-- ------------------------------------------------------------
CREATE TABLE Recovery (
    recovery_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    charge_off_amount DECIMAL(12,2),
    recovery_date DATE,
    recovered_amount DECIMAL(12,2),
    recovery_agency VARCHAR(100)
);
GO

-- ------------------------------------------------------------
-- 8. Calendar (Independent table)
-- Note: The final Power BI model uses a DAX-generated Calendar
-- table instead, but this SQL version was used during early
-- development and is kept here for reference/completeness.
-- ------------------------------------------------------------
CREATE TABLE Calendar (
    calendar_date DATE PRIMARY KEY,
    day_name VARCHAR(15),
    month_name VARCHAR(15),
    month_number INT,
    quarter INT,
    year INT
);
GO

-- ------------------------------------------------------------
-- Verify all tables were created successfully
-- ------------------------------------------------------------
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
