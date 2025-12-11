/*
=========================================================

Stored Procedure: Load Bronze Layer (Source -> Betta)

=========================================================

Script Purpose:

This stored procedure loads data into the 'betta' schema from external .csv files.
It perfroms the following actions:

-Truncates the beta tables before loading data.
-Uses the 'BULK INSERT' command to load data from .csv files to beta tables.

Parameters:

None. This stored procedure does not accept any parameters or return any values. 

Usage Example:

  EXEC beta.load_beta;

=========================================================
*/

CREATE OR ALTER PROCEDURE beta.load_betta AS
BEGIN
    BEGIN TRY

        PRINT '======================================================================================';
        PRINT 'Loading Betta Layer';
        PRINT '======================================================================================';

        PRINT '--------------------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------------------------------------------------------------------';

        PRINT '>> Truncating Table: beta.crm_cust_info';

        TRUNCATE TABLE beta.crm_cust_info;

        PRINT '>> Inserting Data Into Table: beta.crm_cust_info';

        BULK INSERT beta.crm_cust_info
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: beta.crm_prd_info';

        TRUNCATE TABLE beta.crm_prd_info;

        PRINT '>> Inserting Data Into Table: beta.crm_prd_info';

        BULK INSERT beta.crm_prd_info
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: beta.crm_sales_details';

        TRUNCATE TABLE beta.crm_sales_details;

        PRINT '>> Inserting Data Into Table: beta.crm_sales_details';

        BULK INSERT beta.crm_sales_details
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '--------------------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------------------------------------------------------------------------';

        PRINT '>> Truncating Table: beta.erp_CUST_AZ12';

        TRUNCATE TABLE beta.erp_CUST_AZ12;

        PRINT '>> Inserting Data Into Table: erp_CUST_AZ12';

        BULK INSERT beta.erp_CUST_AZ12
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: beta.erp_LOC_A101';

        TRUNCATE TABLE beta.erp_LOC_A101;

        PRINT '>> Inserting Data Into Table: erp_LOC_A101';

        BULK INSERT beta.erp_LOC_A101
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);

        PRINT '>> Truncating Table: beta.erp_PX_CAT_G1V2';

        TRUNCATE TABLE beta.erp_PX_CAT_G1V2;

        PRINT '>> Inserting Data Into Table: PX_CAT_G1V2';

        BULK INSERT beta.erp_PX_CAT_G1V2
        FROM 'C:\SQLData\DWH_Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK);
    END TRY
    BEGIN CATCH
        PRINT '======================================================================================';
        PRINT 'ERROR OCCURED DURING LOADING BETA LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '======================================================================================';
    END CATCH
END
