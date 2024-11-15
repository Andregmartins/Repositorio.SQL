/*********************************************************************************************
backup_historico_mostra_caminho v0.1 (2024-11-13)
(C) 2024, André Martins

Feedback: mailto:andre.martins@gmail.com

License: 
	https://github.com/Andregmartins/Repositorio.SQL/edit/main/INDEX_IMPACT.sql
*********************************************************************************************/

Use MSDB
	go

	SELECT  
	   msdb.dbo.backupset.database_name,  
	   msdb.dbo.backupset.backup_start_date,  
	   msdb.dbo.backupset.backup_finish_date, 
	   msdb.dbo.backupset.user_name,
	   CASE msdb..backupset.type  
		   WHEN 'D' THEN 'Database'  
		   WHEN 'L' THEN 'Log'  
			 WHEN 'I' THEN 'Differential'
			 WHEN 'F' THEN 'Filegroup'
	   END AS backup_type,  
	   msdb.dbo.backupmediafamily.physical_device_name,
	   cast (msdb.dbo.backupset.compressed_backup_size/1024/1024/1024 as decimal (5,2)) as [compressed_size in GB]
	   FROM   msdb.dbo.backupmediafamily  
	   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
	WHERE msdb.dbo.backupset.database_name = 'Nome da base'
		  --msdb.dbo.backupset.backup_start_date > '2024-11-11 00:00:00.000' and msdb.dbo.backupset.backup_finish_date < '2024-11-13 23:59:00.000'-- Restringe por data
		and 
		  msdb..backupset.type in ('D','I','L','F')-- Valida os difentes tipos de arquivos
	ORDER BY  
	   msdb.dbo.backupset.backup_finish_date desc