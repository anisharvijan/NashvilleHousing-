/*
Cleaning Data in SQL Queries
*/

Select*
FROM Portfolio.dbo.NashvilleHousing

---------Stabdardize Date Format
Select SaleDate, CONVERT(Date,SaleDate) 
FROM Portfolio.dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID]<> b.[UniqueID]
 WHERE a.PropertyAddress is NULL


 Update a
 SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
 From NashvilleHousing a
JOIN NashvilleHousing b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID]<> b.[UniqueID]
 where a.PropertyAddress is null 
 
 ------- Breaking out Address into Individual Columns(Address,City,State)


 Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
Substring (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as ADDRESS
,Substring (PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
From NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = Substring (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = Substring (PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))


------OWNERADDRESS

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'),3)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT*
FROM NashvilleHousing

------CHANGE Y AND N TO YES AND NO IN 'sold as vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldASVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 

------------------ REMOVE DUPLICATES 
WITH ROWNUMCTE AS(
SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
 PropertyAddress,SalePrice,SaleDate,LegalReference
 ORDER BY UniqueID ) row_num
 FROM NashvilleHousing
 ---ORDER BY ParcelID
 )
 SELECT *
 FROM ROWNUMCTE
 WHERE row_num>1
 ---order by PropertyAddress

 ----------Delete Unused Columns 

  


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



