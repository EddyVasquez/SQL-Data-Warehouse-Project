USE DataWarehouse;
GO

/* =================================================================

   GAMMA LOAD - CUSTOMERS

   Quality Check 1: Business Logic Normalization
   Quality Check 3: Identity Resolution via ROW_NUMBER

   ================================================================= */

PRINT 'Gamma Load: crm_cust_info';

TRUNCATE TABLE gamma.crm_cust_info;

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
    cst_key,
    cst_firstname,
    cst_lastname,
    CASE
        WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
        WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
        ELSE 'N/A'
    END,
    CASE
        WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
        WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
        ELSE 'N/A'
    END,
    cst_create_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id
               ORDER BY cst_create_date DESC, cst_key DESC
           ) AS rn
    FROM beta.crm_cust_info
) t
WHERE rn = 1;

/* =================================================================

   GAMMA LOAD — PRODUCTS

   QC1: Business Logic Normalization
   QC2: Temporal Reconstruction (non-fabricated)
   QC3: Identity Resolution

   ================================================================= */

PRINT 'Gamma Load: crm_prd_info';

TRUNCATE TABLE gamma.crm_prd_info;

WITH prd_clean AS (
    SELECT
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt
    FROM beta.crm_prd_info
),
prd_timeline AS (
    SELECT
        *,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) AS next_start_dt
    FROM prd_clean
),
prd_resolved AS (
    SELECT
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        CASE
            WHEN prd_line = 'R' THEN 'Road'
            WHEN prd_line = 'M' THEN 'Mountain'
            WHEN prd_line = 'S' THEN 'Standard'
            WHEN prd_line = 'T' THEN 'Touring'
            ELSE 'UNKNOWN'
        END AS prd_line,
        prd_start_dt,
        CASE
            WHEN next_start_dt IS NOT NULL
             AND next_start_dt > prd_start_dt
            THEN DATEADD(day, -1, next_start_dt)
            ELSE NULL
        END AS prd_end_dt,
        ROW_NUMBER() OVER (PARTITION BY prd_key
            ORDER BY prd_start_dt DESC, prd_id DESC
        ) AS rn
    FROM prd_timeline
)

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
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM prd_resolved
WHERE rn = 1;

/* =================================================================

   GAMMA LOAD — SALES

   QC1: Business Logic Normalization
   QC2: Temporal Validation (non-fabricated)
   QC3: Identity Resolution

   ================================================================= */

PRINT 'Gamma Load: crm_sales_details';

/* =================================================================
-- Step 0: Clear Traget Table
==================================================================== */

TRUNCATE TABLE gamma.crm_sales_details;

/* =================================================================
-- Step 1: Normalize & Clean Sales Data (No joins)
==================================================================== */

WITH sales_clean AS (
    SELECT
        sls_ord_num,
        sls_prd_key,   -- legacy suffix
        sls_cust_id,
        TRY_CONVERT(
            DATE,
            CAST(NULLIF(sls_order_dt, 0) AS CHAR(8)),
            112
        ) AS sls_order_dt,

        TRY_CONVERT(
            DATE,
            CAST(NULLIF(sls_ship_dt, 0) AS CHAR(8)),
            112
        ) AS sls_ship_dt,

        TRY_CONVERT(
            DATE,
            CAST(NULLIF(sls_due_dt, 0) AS CHAR(8)),
            112
        ) AS sls_due_dt,

        sls_sales,
        sls_quantity,
        sls_price
    FROM beta.crm_sales_details
),

/* ===================================================================

-- Step 2: Resolve Master Product Key / Normalize dimension side ONCE)

NOTE — Product Key Resolution (Gamma Layer)

Legacy sales records store a product key suffix (sls_prd_key).
Gamma resolves this to the current master product key using a suffix
match against active product records (prd_end_dt IS NULL).

This logic assumes:
- One active product per legacy suffix
- No overlapping active product versions

If multiple active products match the same suffix, one will be selected
arbitrarily and later de-duplicated via ROW_NUMBER().
Definitive enforcement occurs in downstream layers.

======================================================================*/

sales_with_product_resolution AS (
    SELECT
        s.sls_ord_num,
        s.sls_prd_key,
        s.sls_cust_id,
        s.sls_order_dt,
        s.sls_ship_dt,
        s.sls_due_dt,
        s.sls_sales,
        s.sls_quantity,
        s.sls_price,

        -- Master product key resolution
        p.prd_key AS prd_key_master

    FROM sales_clean s
    LEFT JOIN gamma.crm_prd_info p
        ON p.prd_key LIKE '%' + s.sls_prd_key
        AND p.prd_end_dt IS NULL
),

/* =================================================================
-- Step 3: Identity Resolution (de-duplication)
==================================================================== */

sales_deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY
                sls_ord_num,
                sls_prd_key,
                sls_cust_id
            ORDER BY sls_order_dt DESC, sls_prd_key DESC
        ) AS rn
    FROM sales_with_product_resolution
)

/* =================================================================
-- Step 4: Insert Into Gamma
==================================================================== */

INSERT INTO gamma.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    prd_key_master,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
    
)
SELECT
    sls_ord_num,
    sls_prd_key,
    prd_key_master,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
    
FROM sales_deduped
WHERE rn = 1;

PRINT 'Gamma Load: crm_sales_details Complete';

/* ==========================================================

   POST-LOAD VALIDATION / ACTIVATE 

   ========================================================== */

SELECT COUNT(*) AS gamma_cust_count FROM gamma.crm_cust_info;
SELECT COUNT(*) AS gamma_prd_count FROM gamma.crm_prd_info;
SELECT COUNT(*) AS gamma_sales_count FROM gamma.crm_sales_details;

SELECT TOP (5) * FROM gamma.crm_cust_info ORDER BY cst_id DESC;
SELECT TOP (5) * FROM gamma.crm_prd_info ORDER BY prd_id DESC;
SELECT TOP (5) * FROM gamma.crm_sales_details ORDER BY sls_ord_num DESC;
