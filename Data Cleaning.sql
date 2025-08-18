
-- Cleaning data in SQL queries
SELECT * FROM analystdb.housing;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
SELECT 
    SaleDate,
    DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%d/%m/%Y') AS SaleDateFormatted
FROM analystdb.housing;

ALTER TABLE analystdb.housing
ADD SaleDateFormatted DATE;

UPDATE analystdb.housing
SET SaleDateFormatted = STR_TO_DATE(LEFT(SaleDate, 8), '%Y%m%d')
WHERE SaleDate REGEXP '^[0-9]{8}-';

UPDATE analystdb.housing
SET SaleDateFormatted = STR_TO_DATE(SaleDate, '%M %e, %Y')
WHERE SaleDate REGEXP '^[A-Za-z]';

SELECT SaleDate FROM analystdb.housing;
SELECT SaleDateFormatted FROM analystdb.housing;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking Address into individual Columns (Address, City, State)
SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS Address
FROM analystdb.housing;

ALTER TABLE analystdb.housing
ADD PropertySplitAddress NVARCHAR(255);
UPDATE housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE analystdb.housing
ADD PropertySplitCity NVARCHAR(255);
UPDATE analystdb.housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress));

SELECT PropertySplitCity FROM analystdb.housing;
SELECT PropertySplitAddress FROM analystdb.housing;

SELECT
	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM analystdb.housing;

ALTER TABLE analystdb.housing
ADD OwnerSplitAddress VARCHAR(255);
UPDATE analystdb.housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE analystdb.housing
ADD OwnerSplitCity VARCHAR(255);
UPDATE analystdb.housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE analystdb.housing
ADD OwnerSplitState VARCHAR(255);
UPDATE analystdb.housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT * FROM analystdb.housing;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM analystdb.housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM analystdb.housing;

UPDATE analystdb.housing 
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete unused columns
SELECT * FROM analystdb.housing;

ALTER TABLE analystdb.housing
DROP COLUMN OwnerAddress;

ALTER TABLE analystdb.housing
DROP COLUMN PropertyAddress;

ALTER TABLE analystdb.housing
DROP COLUMN SaleDate;

ALTER TABLE analystdb.housing
RENAME COLUMN SaleDateFormatted TO SaleDate;
