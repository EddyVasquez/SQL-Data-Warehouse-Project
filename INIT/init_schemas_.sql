/*
=========================================================

Create Schemas

=========================================================

Script Purpose:

The script creates three schemas
within the database: 'beta', 'gamma', 'delta' after checking IF NOT EXISTS.

WARNING:

None

=========================================================
*/

USE DataWarehouse;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'beta')
    EXEC('CREATE SCHEMA beta');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gamma')
    EXEC('CREATE SCHEMA gamma');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'delta')
    EXEC('CREATE SCHEMA delta');
GO
