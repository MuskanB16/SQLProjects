-- Cleaning Data In SQL
SELECT *
FROM PortfolioProject.dbo.NashvilleData

--Strandardizing Date Format

UPDATE NashVilleData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleData
ADD SaleDateConverted DATE


UPDATE NashVilleData
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populating Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleData a
JOIN PortfolioProject.dbo.NashvilleData b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleData a
JOIN PortfolioProject.dbo.NashvilleData b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress IS NULL

-- Breaking Out Address into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleData

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) AS CITY

FROM PortfolioProject.dbo.NashvilleData

ALTER TABLE NashvilleData
ADD SplitAddress Nvarchar(255)


UPDATE NashVilleData
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleData
ADD PropertyCity Nvarchar(255)


UPDATE NashVilleData
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))

--Changing Y to Yes and N to NO in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleData
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleData

UPDATE NashvilleData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


-- Removing Duplicates

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) AS row_num
FROM PortfolioProject.dbo.NashvilleData
)

DELETE
FROM RowNumCTE
WHERE row_num>1

-- Deleting Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleData

ALTER TABLE PortfolioProject.dbo.NashvilleData 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleData 
DROP COLUMN SaleDate