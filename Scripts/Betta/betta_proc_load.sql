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

