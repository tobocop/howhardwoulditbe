-- This will create the catalog to attach the index to
CREATE FULLTEXT CATALOG institutionsFTS
WITH ACCENT_SENSITIVITY = OFF

-- to verify it's there
--SELECT fulltext_catalog_id, name FROM sys.fulltext_catalogs

-- This will return the primary key name on the institutions table
SELECT  i.name AS IndexName
FROM    sys.indexes AS i INNER JOIN 
        sys.index_columns AS ic ON  i.OBJECT_ID = ic.OBJECT_ID
                                AND i.index_id = ic.index_id
WHERE   i.is_primary_key = 1
	AND OBJECT_NAME(ic.OBJECT_ID) = 'institutions'

CREATE FULLTEXT INDEX ON institutions
(institutionName)
KEY INDEX [key_name]
ON institutionsFTS
WITH STOPLIST = SYSTEM

