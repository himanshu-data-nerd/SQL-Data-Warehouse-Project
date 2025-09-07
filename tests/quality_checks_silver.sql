/*
===================================================================================
Quality Checks
===================================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy and   
    standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in strings fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage notes:
   - Run these checks after data loading silver layer.
   - Investigate and resolve any discripancies found during the checks.
===================================================================================
*/

-----------------------------------------------------------------------------------
-- silver.crm_cust_info
-----------------------------------------------------------------------------------
--Checking for nulls and duplicates in primary key.
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


--Checking unwanted spaces
--Expectation: No results
SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

--Data Standardization and consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;		 

SELECT * FROM
silver.crm_cust_info;


-----------------------------------------------------------------------------------
-- silver.crm_prd_info
-----------------------------------------------------------------------------------
--Check for nulls or duplicates in primary key
--Expectation: No result
SELECT 
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--Check for unwanted spaces
--Expectation: No result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


--Check for NULLS or Negative numbers
--Expectation: No result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

--Data Standardization & consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

--Check for invalid Date orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-----------------------------------------------------------------------------------
-- silver.crm_sales_details
-----------------------------------------------------------------------------------
--Check for invalid dates
SELECT
	NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8;

--Check for invalid date orders
SELECT
*
FROM
silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR  sls_order_dt > sls_due_dt;


--Check data consistency : Between Sales, Quantity, Price
-->> Sales = Quantity * Price
-->> Value must not be NULL, 0, and Negative.
SELECT
*
FROM 
silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales;

--Checking again after cleaning.
SELECT DISTINCT
sls_sales AS Old_sales,
sls_quantity AS Old_quantity,
sls_price AS Old_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity* ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
	 THEN sls_sales/ NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price
FROM silver.crm_sales_details
ORDER BY sls_sales;


-----------------------------------------------------------------------------------
-- silver.erp_CUST_AZ12
-----------------------------------------------------------------------------------
--Identify Out-of-Range Dates
SELECT DISTINCT
bdate
FROM silver.erp_CUST_AZ12
WHERE BDATE < '1925-01-01' OR BDATE > GETDATE();

--Data Standardization and Consistency
SELECT DISTINCT 
gen
FROM silver.erp_CUST_AZ12;


-----------------------------------------------------------------------------------
-- silver.erp_LOC_A101
-----------------------------------------------------------------------------------
--Data Standardization & Consistency
SELECT DISTINCT 
cntry
FROM silver.erp_LOC_A101;


-----------------------------------------------------------------------------------
-- silver.erp_PX_CAT_G1V2
-----------------------------------------------------------------------------------
--Checking for unwanted spaces
SELECT * FROM silver.erp_PX_CAT_G1V2
WHERE cat != TRIM(cat);

SELECT * FROM silver.erp_PX_CAT_G1V2
WHERE subcat != TRIM(subcat);

SELECT * FROM silver.erp_PX_CAT_G1V2
WHERE maintenance != TRIM(maintenance);

--Data Standardization & Consistency
SELECT DISTINCT
cat
FROM silver.erp_PX_CAT_G1V2;

SELECT DISTINCT
subcat
FROM silver.erp_PX_CAT_G1V2;

SELECT DISTINCT
maintenance
FROM silver.erp_PX_CAT_G1V2;
