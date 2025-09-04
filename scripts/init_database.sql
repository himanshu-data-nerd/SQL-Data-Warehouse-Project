/*
-----------------------------------------------------------------------------
Create Database and Schemas
------------------------------------------------------------------------------
Script Purpose:
  This script creates a new database named 'DataWarehouse'.
  The script sets up three schemas within the database: 'bronze', 'silver', 'gold'.
*/
USE master;

-- Create Database DataWarehouse-- 
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

--Create Schemas--
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
