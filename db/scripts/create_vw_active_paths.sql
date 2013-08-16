CREATE view [dbo].[vw_activePaths] as
select p.pathID,
p.objectPath,
ap.affiliateID,
null as virtualCurrencyID,
p.final_destination,
p.is_mobile
from affiliatesPaths ap
Inner join paths p on ap.pathID = p.pathID
WHERE p.isActive = 1
    AND ap.isActive = 1
    AND dbo.udf_getDateOnly(ISNULL(p.startDate, getDate() - 1)) <= dbo.udf_getDateOnly(GETDATE())
    AND dbo.udf_getDateOnly(ISNULL(p.endDate, GETDATE()+1)) >= dbo.udf_getDateOnly(GETDATE())
    AND dbo.udf_getDateOnly(ISNULL(ap.startDate, getDate() - 1)) <= dbo.udf_getDateOnly(GETDATE())
    AND dbo.udf_getDateOnly(ISNULL(ap.endDate, GETDATE()+1)) >= dbo.udf_getDateOnly(GETDATE())
    AND objectPath IS NOT null;
;
