/*
=========================================================

DDL Script: Create Betta Tables

=========================================================

Script Purpose:

The script creates tables in the 'betta' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'betta' Tables.

=========================================================
*/

USE DataWarehouse;
GO

IF OBJECT_ID('betta.crm_cust_info', 'U') IS NOT NULL
DROP TABLE betta.crm_cust_info;

CREATE TABLE betta.crm_cust_info(
    cst_id INT, 
    cst_key NVARCHAR (50), 
    cst_firstname NVARCHAR (50), 
    cst_lastname NVARCHAR (50),
    cst_marital_status NVARCHAR (50), 
    cst_gndr NVARCHAR (50), 
    cst_create_date DATE);
        
IF OBJECT_ID('betta.crm_cprd_info', 'U') IS NOT NULL
DROP TABLE betta.crm_prd_info;

CREATE TABLE betta.crm_prd_info(
    prd_id INT, 
    prd_key NVARCHAR (50), 
    prd_nm NVARCHAR (50), 
    prd_cost INT,
    prd_line NVARCHAR (50), 
    prd_start_dt DATETIME, 
    prd_end_dt DATETIME);

IF OBJECT_ID('betta.crm_sales_details', 'U') IS NOT NULL
DROP TABLE betta.crm_sales_details;

CREATE TABLE betta.crm_sales_details(
    sls_ord_num NVARCHAR (50),
    sls_prd_key	NVARCHAR (50),
    sls_cust_id	INT,
    sls_order_dt INT,
    sls_ship_dt	INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,);

IF OBJECT_ID('betta.erp_cust_az12', 'U') IS NOT NULL
DROP TABLE betta.erp_cust_az12;

CREATE TABLE betta.erp_cust_az12(
    CID	NVARCHAR (50),
    BDATE DATE,
    GEN NVARCHAR (50));

IF OBJECT_ID('betta.erp_loc_a101', 'U') IS NOT NULL
DROP TABLE betta.erp_loc_a101;

CREATE TABLE betta.erp_loc_a101(
    CID	NVARCHAR (50),
    CNTRY NVARCHAR (50));

IF OBJECT_ID('betta.erp_px_cat_g1v2', 'U') IS NOT NULL
DROP TABLE betta.erp_px_cat_g1v2;

CREATE TABLE betta.erp_px_cat_g1v2(
    ID NVARCHAR (50),
    CAT	NVARCHAR (50),
    SUBCAT	NVARCHAR (50),
    MAINTENANCE NVARCHAR (50));
GO


CREATE OR ALTER PROCEDURE betta.load_betta AS
BEGIN
    BEGIN TRY

        PRINT '======================================================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '======================================================================================';

        PRINT '--------------------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------------------------------------------------------------------';

        PRINT '>> Truncating Table: betta.crm_cust_info';

        TRUNCATE TABLE betta.crm_cust_info;

        PRINT '>> Inserting Data Into Table: betta.crm_cust_info';

        BULK INSERT betta.crm_cust_info
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: betta.crm_prd_info';

        TRUNCATE TABLE betta.crm_prd_info;

        PRINT '>> Inserting Data Into Table: betta.crm_prd_info';

        BULK INSERT betta.crm_prd_info
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: betta.crm_sales_details';

        TRUNCATE TABLE betta.crm_sales_details;

        PRINT '>> Inserting Data Into Table: betta.crm_sales_details';

        BULK INSERT betta.crm_sales_details
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '--------------------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------------------------------------------------------------------------';

        PRINT '>> Truncating Table: betta.erp_CUST_AZ12';

        TRUNCATE TABLE betta.erp_CUST_AZ12;

        PRINT '>> Inserting Data Into Table: erp_CUST_AZ12';

        BULK INSERT betta.erp_CUST_AZ12
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: betta.erp_LOC_A101';

        TRUNCATE TABLE betta.erp_LOC_A101;

        PRINT '>> Inserting Data Into Table: erp_LOC_A101';

        BULK INSERT betta.erp_LOC_A101
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: betta.erp_PX_CAT_G1V2';

        TRUNCATE TABLE betta.erp_PX_CAT_G1V2;

        PRINT '>> Inserting Data Into Table: PX_CAT_G1V2';

        BULK INSERT betta.erp_PX_CAT_G1V2
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);
    END TRY
    BEGIN CATCH
        PRINT '======================================================================================';
        PRINT 'ERROR OCCURED DURING LOADING BETTA LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '======================================================================================';
    END CATCH
END
