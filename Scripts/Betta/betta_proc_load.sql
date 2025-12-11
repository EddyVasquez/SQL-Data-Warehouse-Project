/*
=========================================================

Stored Procedure: Load Bronze Layer (Source -> Betta)

=========================================================

Script Purpose:

This stored procedure loads data into the 'betta' schema from external .csv files.
It perfroms the following actions:

-Truncates the betta tables before loading data.
-Uses the 'BULK INSERT' command to load data from .csv files to betta tables.

Parameters:

None. This stored procedure does not accept any parameters or return any values. 

Usage Example:

  EXEC betta.load_betta;

=========================================================
*/

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
