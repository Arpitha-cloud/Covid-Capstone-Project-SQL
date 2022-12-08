/*
Cleaning data using SQL queries
*/
Select *
From CapstoneProject.dbo.NashvilleHousing

--standardizing date fromat

Select saleDateConverted, CONVERT(Date,SaleDate)
From CapstoneProject.dbo.NashvilleHousing

Update CapstoneProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data
Select *
From CapstoneProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From CapstoneProject.dbo.NashvilleHousing a
JOIN CapstoneProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From CapstoneProject.dbo.NashvilleHousing a
JOIN CapstoneProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From CapstoneProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From CapstoneProject.dbo.NashvilleHousing

ALTER TABLE CapstoneProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update CapstoneProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE CapstoneProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update CapstoneProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From CapstoneProject.dbo.NashvilleHousing

Select OwnerAddress
From CapstoneProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From CapstoneProject.dbo.NashvilleHousing

ALTER TABLE CapstoneProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update CapstoneProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE CapstoneProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update CapstoneProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE CapstoneProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update CapstoneProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From CapstoneProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From CapstoneProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From CapstoneProject.dbo.NashvilleHousing

Update CapstoneProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-------
-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From CapstoneProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From CapstoneProject.dbo.NashvilleHousing

----------------------------


-- Delete Unused Columns

Select *
From CapstoneProject.dbo.NashvilleHousing

ALTER TABLE CapstoneProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------
