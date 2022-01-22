-- ================================
-- Create Backup Device Template
-- ================================
use master
go

--Crea dispositivo de almacenamiento
EXEC sp_addumpdevice 'disk', 'AdventureWorksBackupDevice',   
'D:\BACKUPS\BAK\AdventureWorksDevice.bak';  
GO

--Ver los dispositivos de backup del servidor
SELECT      *
FROM        sys.backup_devices
GO

--Crear el primer backup
BACKUP DATABASE AdventureWorks2019 
 TO AdventureWorksBackupDevice  
   WITH FORMAT, INIT, NAME = N'AdventureWorks Full Backup' ;  
GO  