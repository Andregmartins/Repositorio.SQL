/*********************************************************************************************
backup_historico_mostra_caminho v0.1 (2024-11-29)
(C) 2024, André Martins

Feedback: mailto:andre.martins@gmail.com

License: 
	https://github.com/Andregmartins/Repositorio.SQL/edit/main/INDEX_IMPACT.sql
*********************************************************************************************/SELECT  sys.objects.schema_id, sys.objects.object_id, sys.objects.name
, (avg_total_user_cost * avg_user_impact) * (user_seeks + user_scans) AS Impact
,  'CREATE NONCLUSTERED INDEX IX01_'+sys.objects.name+ ' on' + sys.objects.name COLLATE DATABASE_DEFAULT + ' ( ' + IsNull(mid.equality_columns, '') + CASE WHEN mid.inequality_columns IS NULL 
                THEN ''  
    ELSE CASE WHEN mid.equality_columns IS NULL 
                    THEN ''  
        ELSE ',' END + mid.inequality_columns END + ' ) ' + CASE WHEN mid.included_columns IS NULL 
                THEN ''  
    ELSE 'INCLUDE (' + mid.included_columns + ')' END + ';' AS CreateIndexStatement
, mid.equality_columns
, mid.inequality_columns
, mid.included_columns 
    FROM sys.dm_db_missing_index_group_stats AS migs 
            INNER JOIN sys.dm_db_missing_index_groups AS mig ON migs.group_handle = mig.index_group_handle 
            INNER JOIN sys.dm_db_missing_index_details AS mid ON mig.index_handle = mid.index_handle AND mid.database_id = DB_ID() 
            INNER JOIN sys.objects WITH (nolock) ON mid.OBJECT_ID = sys.objects.OBJECT_ID 
    WHERE     (migs.group_handle IN 
        ( 
        SELECT     TOP (500) group_handle 
            FROM          sys.dm_db_missing_index_group_stats WITH (nolock) 
            ORDER BY (avg_total_user_cost * avg_user_impact) * (user_seeks + user_scans) DESC))  
        AND OBJECTPROPERTY(sys.objects.OBJECT_ID, 'isusertable')=1 
    ORDER BY 4 DESC 
