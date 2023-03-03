USE housing;

SELECT 
    *
FROM
    nashville;

SELECT 
    SaleDate1, CAST(SaleDate AS DATE)
FROM
    nashville;

ALTER TABLE nashville
ADD saleDate1 DATE;

UPDATE nashville 
SET 
    saleDate = CAST(SaleDate AS DATE);

SELECT 
    *
FROM
    nashville
WHERE
    PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress1
FROM
    nashville a
        JOIN
    nashville b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;

UPDATE nashville a
        JOIN
    nashville b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;

SELECT 
    SUBSTRING(PropertyAddress,
        1,
        POSITION(',' IN PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        POSITION(',' IN PropertyAddress) + 1,
        LENGTH(PropertyAddress)) AS Address
FROM
    nashville;

ALTER TABLE nashville
ADD PropertySplitAddress nvarchar(255);
UPDATE nashville 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        POSITION(',' IN PropertyAddress) - 1);

ALTER TABLE nashville
ADD PropertySplitCity nvarchar(255);
UPDATE nashville 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        POSITION(',' IN PropertyAddress) + 1,
        LENGTH(PropertyAddress));

SELECT 
    SUBSTRING(OwnerAddress,
        1,
        POSITION(',' IN OwnerAddress) - 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1) AS Address,
    SUBSTRING(OwnerAddress,
        - 2,
        POSITION(',' IN OwnerAddress) - 1) AS Address
FROM
    nashville;

ALTER TABLE nashville
ADD OwnerSplitAddress nvarchar(255);
UPDATE nashville 
SET 
    OwnerSplitAddress = SUBSTRING(OwnerAddress,
        1,
        POSITION(',' IN OwnerAddress) - 1);

ALTER TABLE nashville
ADD OwnerSplitCity nvarchar(255);
UPDATE nashville 
SET 
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);

ALTER TABLE nashville
ADD OwnerSplitState nvarchar(255);
UPDATE nashville 
SET 
    OwnerSplitState = SUBSTRING(OwnerAddress,
        - 2,
        POSITION(',' IN OwnerAddress) - 1);

SELECT 
    *
FROM
    nashville;

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    nashville
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    nashville;

UPDATE nashville 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
;
        
        
#Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	row_number() OVER (
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                UniqueID
                ) row_num
FROM nashville
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS(
SELECT *,
	row_number() OVER (
    PARTITION BY ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                UniqueID
                ) row_num
FROM nashville
)
DELETE 
FROM nashville using nashville join RowNumCTE on nashville.PropertyAddress = RowNumCTE.PropertyAddress
WHERE row_num > 1;

SELECT 
    *
FROM
    nashville;

#Delete Unused Columns

ALTER TABLE nashville
DROP COLUMN OwnerAddress, DROP COLUMN TaxDistrict, DROP COLUMN PropertyAddress, DROP COLUMN SaleDate1;

SELECT 
    *
FROM
    nashville;