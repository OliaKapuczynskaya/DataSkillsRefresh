-- Cleaning Data in SQL Queries
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing 

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate, 23)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate, 23)

SELECT SaleDate, SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data - self join

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress,1)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1) + 1, LEN(PropertyAddress))

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END

--SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
--FROM NashvilleHousing
--GROUP BY SoldAsVacant

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH doubles AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) as row_num

FROM NashvilleHousing
)

DELETE FROM doubles 
WHERE row_num > 1

--SELECT * 
--FROM doubles
--WHERE row_num = 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * 
FROM NashvilleHousing