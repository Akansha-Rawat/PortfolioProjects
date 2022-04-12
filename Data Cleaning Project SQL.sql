/*
   Cleaning Data with SQL Queries
*/



 SELECT *
 FROM [dbo].[Nashville  Housing Data]
  



 -- Standardize Date Format


 SELECT SaleDateConverted, CONVERT(date,SaleDate)
 FROM [dbo].[Nashville  Housing Data]

 Update [Nashville  Housing Data]
 SET SaleDate = CONVERT(date,SaleDate)

 ALTER TABLE [dbo].[Nashville  Housing Data]
 ADD SaleDateConverted Date;

 UPDATE [dbo].[Nashville  Housing Data]
 SET SaleDateConverted = CONVERT(date,SaleDate)




 -- Populate Property Address Data


 SELECT *
 FROM [dbo].[Nashville  Housing Data]
 --WHERE PropertyAddress is null
 ORDER BY ParcelID


 SELECT x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress , ISNULL(x.PropertyAddress , y.PropertyAddress)
 FROM [dbo].[Nashville  Housing Data] x
 JOIN [dbo].[Nashville  Housing Data] y
   ON x.ParcelID = y.ParcelID
   AND x.[UniqueID ] <> y.[UniqueID ]
 WHERE x.PropertyAddress is null

UPDATE x
 SET PropertyAddress = ISNULL(x.PropertyAddress , y.PropertyAddress)
 FROM [dbo].[Nashville  Housing Data] x
 JOIN [dbo].[Nashville  Housing Data] y
   ON x.ParcelID = y.ParcelID
   AND x.[UniqueID ] <> y.[UniqueID ]c
 WHERE x.PropertyAddress is null




 -- Breaking PropertyAddress column into individual columns (Address, City, State)


 SELECT *
 FROM [dbo].[Nashville  Housing Data]

 SELECT
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
 FROM [dbo].[Nashville  Housing Data]

 ALTER TABLE [dbo].[Nashville  Housing Data]
 ADD PropertySplitAddress nvarchar(255);

 UPDATE [dbo].[Nashville  Housing Data]
 SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 )


 ALTER TABLE [dbo].[Nashville  Housing Data]
 ADD PropertySplitCity nvarchar(255);

 UPDATE [dbo].[Nashville  Housing Data]
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

 SELECT *
 FROM [dbo].[Nashville  Housing Data]


 -- A little simpler way of splitting data
 -- Breaking OwnerAddress column into individual columns (Address, City, State)
 

 SELECT
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
 FROM [dbo].[Nashville  Housing Data]


 ALTER TABLE [dbo].[Nashville  Housing Data]
 ADD OwnerSplitAddress nvarchar(255);

 UPDATE [dbo].[Nashville  Housing Data]
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


 ALTER TABLE [dbo].[Nashville  Housing Data]
 ADD OwnerSplitCity nvarchar(255);

 UPDATE [dbo].[Nashville  Housing Data]
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


 ALTER TABLE [dbo].[Nashville  Housing Data]
 ADD OwnerSplitState nvarchar(255);

 UPDATE [dbo].[Nashville  Housing Data]
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


 SELECT *
 FROM [dbo].[Nashville  Housing Data]




 -- Change Y and N to Yes and No in the column SoldAsVacant


 SELECT SoldAsVacant , COUNT(SoldAsVacant)
 FROM [dbo].[Nashville  Housing Data]
 GROUP BY SoldAsVacant
 ORDER By 2

 SELECT SoldAsVacant,
        CASE When SoldAsVacant = 'Y' Then 'Yes'
		     When SoldAsVacant = 'N' Then 'No'
			 ELSE SoldAsVacant
			 END
 FROM [dbo].[Nashville  Housing Data]

 UPDATE [dbo].[Nashville  Housing Data]
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		            When SoldAsVacant = 'N' Then 'No'
			        ELSE SoldAsVacant
			        END

 SELECT *
 FROM [dbo].[Nashville  Housing Data]




 -- Find and Remove Duplicates


 WITH RowNumCTE AS (
 SELECT *,
        ROW_NUMBER() OVER(
		                   PARTITION BY ParcelID,
						                PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										ORDER BY UniqueID
						) AS Row_num

 FROM [dbo].[Nashville  Housing Data] 
                     )

 SELECT *
 FROM RowNumCTE
 WHERE Row_num >1
 ORDER BY PropertyAddress