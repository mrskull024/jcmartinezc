BACKUP DATABASE AdventureWorks2019   
 TO AdventureWorksBackupDevice  
   WITH NOFORMAT, NOINIT, NAME = N'Adventure Works Full Backup';  
GO

RESTORE HEADERONLY FROM AdventureWorksBackupDevice


DECLARE @BACKUP_NAME VARCHAR(100)
SET @BACKUP_NAME = N'Adventure Works Full Backup ' + FORMAT(GETDATE(),'yyyyMMdd_hhmmss');

BACKUP DATABASE AdventureWorks2019   
 TO AdventureWorksBackupDevice  
   WITH NOFORMAT, NOINIT, NAME = @BACKUP_NAME;  
GO