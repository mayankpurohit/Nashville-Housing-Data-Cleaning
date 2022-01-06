select * from nashville.dbo.Nashville_housing_data$;

select count(*) from nashville.dbo.Nashville_housing_data$;

select count([UniqueID ]) as uq, count(ParcelID) as pi, count(LandUse) as ls from nashville.dbo.Nashville_housing_data$

select * from INFORMATION_SCHEMA.COLUMNS;

-- change saledate text to date datatype
select cast(SaleDate as date) as sales_date_cleaned from nashville.dbo.Nashville_housing_data$;

--updating saledate datatype
update nashville.dbo.Nashville_housing_data$
set SaleDate = cast(SaleDate as date);



--populate propertyaddress column
select * from Nashville_housing_data$ where PropertyAddress is null order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, 
b.PropertyAddress, ISnull(a.PropertyAddress, b.PropertyAddress) from Nashville_housing_data$ a
join Nashville_housing_data$ b
on a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing_data$ a 
join Nashville_housing_data$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress from Nashville_housing_data$;

--spliting ProperAddress into address, city
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Nashville_housing_data$

select CHARINDEX(',',PropertyAddress) from Nashville_housing_data$;

--adding columns for newly split column values
alter table nashville.dbo.Nashville_housing_data$
add PropertySplitAddress Nvarchar(255);

alter table Nashville_housing_data$ add PropertySplitCity Nvarchar(255);

update Nashville_housing_data$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

update Nashville_housing_data$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




select OwnerAddress
from Nashville_housing_data$;

-- spliting owner address into address, city and state
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Nashville_housing_data$

select PARSENAME(replace(OwnerAddress,',','.'),3) as address_part, 
parsename(replace(OwnerAddress,',', '.'),2) as city_part, 
parsename(replace(OwnerAddress,',', '.'),1) as state_part
from Nashville_housing_data$;


ALTER TABLE Nashville_housing_data$
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_housing_data$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville_housing_data$
Add OwnerSplitCity Nvarchar(255);

Update Nashville_housing_data$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville_housing_data$
Add OwnerSplitState Nvarchar(255);

Update Nashville_housing_data$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select * from Nashville_housing_data$;

--change Y and N values to Yes and No in SoldAsVacant Column
select distinct(SoldAsVacant), count(SoldAsVacant) from Nashville_housing_data$
group by SoldAsVacant order by 2;

select SoldAsVacant, case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No' else SoldAsVacant end
from Nashville_housing_data$

update Nashville_housing_data$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end



--removing duplicate columns
WITH RowNumCTE AS(
Select *,ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
from nashville.dbo.Nashville_housing_data$ )
select * from RowNumCTE where row_num > 1 order by PropertyAddress


alter table Nashville_housing_data$ drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


select * from Nashville_housing_data$;
