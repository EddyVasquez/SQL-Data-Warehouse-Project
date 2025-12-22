/*
=========================================================

Stored Procedure: Load Gamma Layer (Source -> Beta)

=========================================================

Script Purpose:

This stored procedure loads data into the 'gamma' schema from beta layer raw data

-Truncates the gamma tables before loading data.

Parameters:

None. This stored procedure does not accept any parameters or return any values. 

Usage Example:

  EXEC gama.load_gama;

=========================================================
*/

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

