/****** Object:  UserDefinedFunction [dbo].[udf_getDateOnly]    Script Date: 6/24/2013 4:46:47 PM ******/
CREATE FUNCTION [dbo].[udf_getDateOnly](
	@dateToConvert datetime
)
RETURNS DATETIME
AS
BEGIN
	RETURN CONVERT(DATETIME, CONVERT(VARCHAR, @dateToConvert,101))
END;