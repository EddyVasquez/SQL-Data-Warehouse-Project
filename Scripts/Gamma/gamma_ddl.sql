/*
=========================================================

DDL Script: Create Gamma Tables

=========================================================

Script Purpose:

The script creates tables in the 'gamma' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'gamma' Tables.

Data Enrichment:

ADDED METADATA > Derived Column > (Conformed Key) 'prd_key_master' IN crm_sales_details Table.
ADDED METADATA > DATETIME2 > Data Warehouse Create Date > 'dwh_create_date'.
Converted Data Type INT to DATE for cst_create_date, sls_order_dt sls_ship_dt and sls_due_dt.

=========================================================
*/

USE DataWarehouse;
GO

IF OBJECT_ID('gamma.crm_cust_info', 'U') IS NOT NULL
DROP TABLE gamma.crm_cust_info;

CREATE TABLE gamma.crm_cust_info(
    cst_id INT, 
    cst_key NVARCHAR (50), 
    cst_firstname NVARCHAR (50), 
    cst_lastname NVARCHAR (50),
    cst_marital_status NVARCHAR (50), 
    cst_gndr NVARCHAR (50), 
    cst_create_date Date, -- FIXED DATA TYPE FROM INT TO DATE
    dwh_create_date DATETIME2 DEFAULT GETDATE()); -- ADDED METADATA
        
IF OBJECT_ID('gamma.crm_prd_info', 'U') IS NOT NULL
DROP TABLE gamma.crm_prd_info;

CREATE TABLE gamma.crm_prd_info(
    prd_id INT, 
    prd_key NVARCHAR (50), 
    prd_nm NVARCHAR (50), 
    prd_cost INT,
    prd_line NVARCHAR (50), 
    prd_start_dt DATETIME, 
    prd_end_dt DATETIME,
    dwh_create_date DATETIME2 DEFAULT GETDATE()); -- ADDED METADATA

IF OBJECT_ID('gamma.crm_sales_details', 'U') IS NOT NULL
DROP TABLE gamma.crm_sales_details;

CREATE TABLE gamma.crm_sales_details(
    sls_ord_num NVARCHAR (50),
    sls_prd_key	NVARCHAR (50),
    prd_key_master NVARCHAR(50),  -- ADDED DERIVED COLUMN (does NOT exist in Beta)
    sls_cust_id	INT, 
    sls_order_dt DATE, -- FIXED DATA TYPE FROM INT TO DATE
    sls_ship_dt	DATE, -- FIXED DATA TYPE FROM INT TO DATE
    sls_due_dt DATE, -- FIXED DATA TYPE FROM INT TO DATE
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()); -- ADDED METADATA

IF OBJECT_ID('gamma.erp_cust_az12', 'U') IS NOT NULL
DROP TABLE gamma.erp_cust_az12;

CREATE TABLE gamma.erp_cust_az12(
    CID	NVARCHAR (50),
    BDATE DATE,
    GEN NVARCHAR (50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()); -- ADDED METADATA

IF OBJECT_ID('gamma.erp_loc_a101', 'U') IS NOT NULL
DROP TABLE gamma.erp_loc_a101;

CREATE TABLE gamma.erp_loc_a101(
    CID	NVARCHAR (50),
    CNTRY NVARCHAR (50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()); -- ADDED METADATA

IF OBJECT_ID('gamma.erp_px_cat_g1v2', 'U') IS NOT NULL
DROP TABLE gamma.erp_px_cat_g1v2;

CREATE TABLE gamma.erp_px_cat_g1v2(
    ID NVARCHAR (50),
    CAT	NVARCHAR (50),
    SUBCAT	NVARCHAR (50),
    MAINTENANCE NVARCHAR (50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()); -- ADDED METADATA
GO

PRINT 'Gamma DDL Complete';

/* =========================================================
   GAMMA LAYER — LOAD
   Beta → Gamma (no business logic)
   ========================================================= */


TRUNCATE TABLE gamma.crm_cust_info;
GO

INSERT INTO gamma.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    TRIM(cst_key),
    TRIM(cst_firstname),
    TRIM(cst_lastname),
    TRIM(cst_marital_status),
    TRIM(cst_gndr),
    -- Convert legacy string date → DATE
    TRY_CONVERT(DATE, cst_create_date, 112)

FROM beta.crm_cust_info;
GO

PRINT 'Gamma Load: crm_cust_info Complete';


TRUNCATE TABLE gamma.crm_prd_info;
GO

INSERT INTO gamma.crm_prd_info (
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    TRIM(prd_key),
    TRIM(prd_nm),
    prd_cost,
    TRIM(prd_line),
    prd_start_dt,
    prd_end_dt
FROM beta.crm_prd_info;
GO

PRINT 'Gamma Load: crm_prd_info Complete';


TRUNCATE TABLE gamma.crm_sales_details;
GO

INSERT INTO gamma.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    prd_key_master, -- intentionally NULL
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    TRIM(sls_ord_num),
    TRIM(sls_prd_key),
    NULL AS prd_key_master,
    sls_cust_id,

    TRY_CONVERT(DATE, CAST(NULLIF(sls_order_dt, 0) AS CHAR(8)), 112),
    TRY_CONVERT(DATE, CAST(NULLIF(sls_ship_dt, 0) AS CHAR(8)), 112),
    TRY_CONVERT(DATE, CAST(NULLIF(sls_due_dt, 0) AS CHAR(8)), 112),

    sls_sales,
    sls_quantity,
    sls_price
FROM beta.crm_sales_details;
GO

PRINT 'Gamma Load: crm_sales_details Complete';

PRINT '=======================================================';
PRINT 'Gamma Load Finished Successfully';
PRINT '=======================================================';
