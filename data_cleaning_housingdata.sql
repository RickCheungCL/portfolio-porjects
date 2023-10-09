Select *
From Housing

--DATE
Select SaleDate, CONVERT(Date,SaleDate)
From Housing

Update housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Housing
Add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted, CONVERT(Date,SaleDate)
From Housing

--Address Data

Select PropertyAddress
From Housing

--Where PropertyAddress is NULL
--Fill null with same property address
Select a.ParcelID , a.PropertyAddress,b.ParcelID , b.PropertyAddress  ,isNULL(a.PropertyAddress,b.PropertyAddress)
From Housing a
Join Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET propertyAddress = isNULL(a.PropertyAddress,b.PropertyAddress)
From Housing a
Join Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
--Fixed Null in Property Address


--doing Normal Form in property Address :splitting city and address

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2
From Housing


ALTER TABLE Housing
Add PropertyAddressSplit Nvarchar(255);

Update housing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing 
Add PropertyAddressCity Nvarchar(255);
Update housing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



--Parsename to do NF
Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Housing



ALTER TABLE Housing
Add OwnerAddressSplit Nvarchar(255);
ALTER TABLE Housing 
Add OwnerAddressCity Nvarchar(255);
ALTER TABLE Housing 
Add OwnerAddressState Nvarchar(255);



--Update Y / N to YES / NO because Y/N is some typing mistake
Update housing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update housing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update housing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
From Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
From Housing

Update Housing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END


--Remove Duplicates
With RowNumCTE AS(
Select * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID) row_num

from Housing
)

Select *  
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
--DELETE  
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress



--Delete Unused columns

Select * from housing

Alter table housing
drop column OwnerAddress, TaxDistrict,PropertyAddress,SaleDate

Select * from Housing

