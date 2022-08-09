/*

Cleaning Data in SQL Queries

*/

Select * 
From PortfolioProject..NashvilleHousing

----------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------

--Breaking Out Address Into Individual Columns (Address, City, State) Using SUBSTRING

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select *
FROM PortfolioProject..NashvilleHousing


--Breaking Out Address Into Individual Columns (Address, City, State) Using PARSENAME


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
FROM PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing



UPDATE PortfolioProject..NashvilleHousing
SET SoldASVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END



------------------------------------------------------------------------------------------------------

-- Checking Duplicates before removing Duplicates


WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY	 UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
)

Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Remove Duplicates


WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY	 UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
)

DELETE 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



------------------------------------------------------------------------------

--Delete Unused Columns

Select * 
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate