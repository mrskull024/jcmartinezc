--######################################################################################
--Inciso B):
--Crea un dispositivo de backups múltiples para la base de datos Adventureworks.
--######################################################################################

--Para crear dispositivos se debe usar la BD master
USE master
GO

--Crea dispositivo de almacenamiento para la base de datos Adventure Works
EXEC sp_addumpdevice 'disk', 'AWorksDevice',   
'D:\BD2\BACKUP\AWBackupDevice.bak';  --Ruta donde se almacenan los backups
GO

--Ver los dispositivos de backup del servidor
SELECT      *
FROM        sys.backup_devices
GO

--Crear el primer backup
BACKUP DATABASE AdventureWorks2019 
 TO AWorksDevice  
   WITH FORMAT, INIT, NAME = N'AdventureWorks Full Backup' ;  
GO  
--######################################################################################
--Inciso C):
--Crea una rutina que asigne nombres de backups únicos y haz que ejecute 4 backups 
--sobre el dispositivo de backup creado en el punto anterior.
--######################################################################################

--Crea Backups sin formatearlo y sin reiniciar su contenido
BACKUP DATABASE AdventureWorks2019 
 TO AWorksDevice  
   WITH DIFFERENTIAL, NAME = N'AdventureWorks Diferential Backup 1' ;  
GO 

--Añadimos una tabla con datos de prueba para crear el 3er backup
USE AdventureWorks2019
CREATE TABLE dbo.TablaPrueba
(
	DemoID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ColumnaUno NVARCHAR(600),
	Columna2 BIGINT
);
GO

SET NOCOUNT ON
INSERT INTO dbo.TablaPrueba (ColumnaUno,
                             Columna2)
VALUES (N'Datos de Prueba', -- ColumnaUno - nvarchar(600)
        230122 -- Columna2 - bigint
    )
GO 2500

SELECT TOP 100 * FROM dbo.TablaPrueba

BACKUP DATABASE AdventureWorks2019 
 TO AWorksDevice  
   WITH DIFFERENTIAL, NAME = N'AdventureWorks Diferential Backup 2' ;  
GO 

--Creamos un Backup Full para crear el 4to y ultimo backup
BACKUP DATABASE AdventureWorks2019 
 TO AWorksDevice  
   WITH NOFORMAT, NOINIT, NAME = N'AdventureWorks Full Backup 2' ;  
GO 

--Listamos los backups que hemos creado
USE master
GO
RESTORE HEADERONLY FROM AWorksDevice
GO

RESTORE FILELISTONLY FROM AWorksDevice
GO

--######################################################################################
--Inciso D):
--Crea una rutina rutina que restuare uno de los backups con nombre AwExamenBDII
--basado en el número del archivo de backup.
--######################################################################################

IF OBJECT_ID('TempDB..#RestoreHeaderOnlyData') IS NOT NULL
DROP TABLE #RestoreHeaderOnlyData
GO
CREATE TABLE #RestoreHeaderOnlyData( 
BackupName NVARCHAR(128) 
,BackupDescription NVARCHAR(255) 
,BackupType smallint 
,ExpirationDate datetime 
,Compressed tinyint 
,Position smallint 
,DeviceType tinyint 
,UserName NVARCHAR(128) 
,ServerName NVARCHAR(128) 
,DatabaseName NVARCHAR(128) 
,DatabaseVersion INT 
,DatabaseCreationDate datetime 
,BackupSize numeric(20,0) 
,FirstLSN numeric(25,0) 
,LastLSN numeric(25,0) 
,CheckpointLSN numeric(25,0) 
,DatabaseBackupLSN numeric(25,0) 
,BackupStartDate datetime 
,BackupFinishDate datetime 
,SortOrder smallint 
,CodePage smallint 
,UnicodeLocaleId INT 
,UnicodeComparisonStyle INT 
,CompatibilityLevel tinyint 
,SoftwareVendorId INT 
,SoftwareVersionMajor INT 
,SoftwareVersionMinor INT 
,SoftwareVersionBuild INT 
,MachineName NVARCHAR(128) 
,Flags INT 
,BindingID uniqueidentifier 
,RecoveryForkID uniqueidentifier 
,Collation NVARCHAR(128) 
,FamilyGUID uniqueidentifier 
,HasBulkLoggedData INT 
,IsSnapshot INT 
,IsReadOnly INT 
,IsSingleUser INT 
,HasBackupChecksums INT 
,IsDamaged INT 
,BeginsLogChain INT 
,HasIncompleteMetaData INT 
,IsForceOffline INT 
,IsCopyOnly INT 
,FirstRecoveryForkID uniqueidentifier 
,ForkPointLSN numeric(25,0) 
,RecoveryModel NVARCHAR(128) 
,DifferentialBaseLSN numeric(25,0) 
,DifferentialBaseGUID uniqueidentifier 
,BackupTypeDescription NVARCHAR(128) 
,BackupSetGUID uniqueidentifier 
,CompressedBackupSize BIGINT
,Containment INT
,KeyAlgorithm varchar(500)
,EncryptorThumbprint varchar(500)
,EncryptorType varchar(500)
) 

----------------------------------------------------------------------------
--2. Collect header information FROM the backup device into a temporary table
----------------------------------------------------------------------------
INSERT INTO #RestoreHeaderOnlyData 
EXEC('RESTORE HEADERONLY FROM AWorksDevice') 

----------------------------------------------------------------------------
--3. Complete database restore from the latest FULL backup; 
----------------------------------------------------------------------------
--NORECOVERY is specified so that roll back not occur. This allows additional backups to be restored. 
DECLARE @File smallint
SELECT @File = MAX(Position) 
FROM #RestoreHeaderOnlyData 
WHERE BackupName = 'AdventureWorks Full Backup' 

RESTORE DATABASE AwExamenBDII 
FROM AWorksDevice
WITH FILE = @File, 
    MOVE N'AdventureWorks2017' TO N'D:\BD2\DATA\AwExamenBDII.mdf', 
    MOVE N'AdventureWorks2017_log' TO N'D:\BD2\LOG\AwExamenBDII.ldf', 
NOUNLOAD, REPLACE, STATS = 10
GO