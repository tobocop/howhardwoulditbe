/****** Object:  UserDefinedFunction [dbo].[udf_calculateFuzzyDate]    Script Date: 6/24/2013 4:14:25 PM ******/
CREATE FUNCTION [dbo].[udf_calculateFuzzyDate](
	@initialDate datetime
)
RETURNS datetime
AS
BEGIN
	RETURN DATEADD(dd, (SELECT dbo.udf_getFuzzyDateValue()), @initialDate)
END;
