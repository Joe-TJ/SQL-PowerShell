<#$Standalone_Config_SQL2016=@{
ACTION="INSTALL";
#Specifies a Setup work flow, like INSTALL, UNINSTALL, or UPGRADE

FEATURES="SQLENGINE,REPLICATION,FULLTEXT,CONN";
#Specifies features to install, uninstall, or upgrade

INSTANCENAME="MSSQLSERVER"
#Specify a default or named instance

INSTANCEDIR="C:\Program Files\Microsoft SQL Server";
#Specify the installation directory

AGTSVCACCOUNT="PETSHOP\sqlsvc";
# SQL Server Agent account name 

AGTSVCPASSWORD="";
# Password for SQL Server Agent service account

AGTSVCSTARTUPTYPE="Automatic";
# Auto-start service after installation,supported values:Automatic,Disabled,Manual

SQLSVCACCOUNT="PETSHOP\sqlsvc";
#SQL Server account name 

SQLSVCPASSWORD="";
# Password for SQL Server Agent service account

SQLSVCSTARTUPTYPE="Automatic";
#Startup type for the SQL Server service supported values:Automatic,Disabled,Manual

SQLSVCINSTANTFILEINIT="True";
#Enable instant file initialization for SQL Server service

SQLSYSADMINACCOUNTS="PETSHOP\sqladmin";
# Windows account(s) to provision as SQL Server system administrators

SECURITYMODE="SQL";
# Use "SQL" for Mixed Mode Authentication

SAPWD="";
# Password for the SQL Server SA account

SQLTEMPDBDIR="C:\sqltempdb"
SQLTEMPDBFILECOUNT="2";
SQLTEMPDBFILESIZE="8";
SQLTEMPDBFILEGROWTH="64";
SQLTEMPDBLOGFILESIZE="8";
# Configuration for Tempdb

INSTALLSQLDATADIR="C:\sqldata";
# Database Engine root data directory

SQLBACKUPDIR="C:\sqlbackup";
# Default directory for the Database Engine backup files

SQLUSERDBDIR="C:\sqldata";
# Default directory for the Database Engine user databases

SQLUSERDBLOGDIR="C:\sqllog";
# Default directory for the Database Engine user database logs

PID="";
# Specifies the product key for the edition of SQL Server
}
#>

$Standalone_Config_SQL2014=@{
ACTION="INSTALL";
#Specifies a Setup work flow, like INSTALL, UNINSTALL, or UPGRADE

FEATURES="SQLENGINE,REPLICATION,FULLTEXT,CONN,SSMS,ADV_SSMS";
#Specifies features to install, uninstall, or upgrade

INSTANCENAME="MSSQLSERVER"
#Specify a default or named instance

INSTANCEDIR="C:\Program Files\Microsoft SQL Server";
#Specify the installation directory

AGTSVCACCOUNT="PETSHOP\sqlsvc";
# SQL Server Agent account name 

AGTSVCPASSWORD="";
# Password for SQL Server Agent service account

AGTSVCSTARTUPTYPE="Automatic";
# Auto-start service after installation,supported values:Automatic,Disabled,Manual

SQLSVCACCOUNT="PETSHOP\sqlsvc";
#SQL Server account name 

SQLSVCPASSWORD="";
# Password for SQL Server Agent service account

SQLSVCSTARTUPTYPE="Automatic";
#Startup type for the SQL Server service supported values:Automatic,Disabled,Manual

SQLSYSADMINACCOUNTS="PETSHOP\sqladmin";
# Windows account(s) to provision as SQL Server system administrators

SECURITYMODE="SQL";
# Use "SQL" for Mixed Mode Authentication

SAPWD="";
# Password for the SQL Server SA account

INSTALLSQLDATADIR="C:\sqldata";
# Database Engine root data directory

SQLBACKUPDIR="C:\sqlbackup";
# Default directory for the Database Engine backup files

SQLUSERDBDIR="C:\sqldata";
# Default directory for the Database Engine user databases

SQLUSERDBLOGDIR="C:\sqllog";
# Default directory for the Database Engine user database logs

PID="";
# Specifies the product key for the edition of SQL Server
}
#>
<#
Initialize required parameters for installation:
PID,SAPWD,SQLSVCPASSWORD,AGTSVCPASSWORD
#>

<# For SQL 2016
$Standalone_Config_SQL2016["PID"]="xxxx-xxxx-xxxx-xxxx";
$Standalone_Config_SQL2016["SAPWD"]="1qaz@WSX";
$Standalone_Config_SQL2016["SQLSVCPASSWORD"]="1qaz@WSX";
$Standalone_Config_SQL2016["AGTSVCPASSWORD"]="1qaz@WSX";
#/Q /IACCEPTSQLSERVERLICENSETERMS
$install_cmd="D:\setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS "
$Standalone_Config_SQL2016.GetEnumerator()|%{$install_cmd+="/$($_.Key)=""$($_.Value)"" "};
Invoke-Expression $install_cmd;
#>

#For SQL 2014
$Standalone_Config_SQL2014["PID"]="xxxx-xxxx-xxxx-xxxx";
$Standalone_Config_SQL2014["SAPWD"]="1qaz@WSX";
$Standalone_Config_SQL2014["SQLSVCPASSWORD"]="1qaz@WSX";
$Standalone_Config_SQL2014["AGTSVCPASSWORD"]="1qaz@WSX";
#/Q /IACCEPTSQLSERVERLICENSETERMS
$install_cmd="D:\setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS "
$Standalone_Config_SQL2014.GetEnumerator()|%{$install_cmd+="/$($_.Key)=""$($_.Value)"" "};
Invoke-Expression $install_cmd;

