# make sure SQL Server service account has proper privilege on HADR endpoint  
$ag_name='test_ag';
$primary_instance="node1";
$secondary_instance=("node2");
$hadr_port=5022;
$backup_path='\\node1\backup\';
$db_list=("agdb1","agdb2")

$secondary_objs=@();
$replicas = @();

$ErrorActionPreference="Stop";
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO");
#Add-Type -AssemblyName "Microsoft.SqlServer.Smo,Version=11.0.0.0,Culture=neutral,PublicKeyToken=89845dcd8080cc91"
<#############################
#1.initilize primary replica
##############################>
Write-Verbose "enable HADR feature and create smo object for primary" -Verbose;
Enable-SqlAlwaysOn -ServerInstance $primary_instance -Force -Verbose;
$primary_obj = New-Object Microsoft.SQLServer.Management.SMO.Server($primary_instance);

Write-Verbose "create and enable HADR endpoint" -Verbose;
$endport_obj=New-SqlHADREndpoint -InputObject $primary_obj -Name "hadr_port" -Port $hadr_port -Verbose;
Set-SqlHADREndpoint -InputObject $endport_obj -State Started -Verbose;

Write-Verbose "create primary replica" -Verbose;
$fqdn = $primary_obj.Information.FullyQualifiedNetName;
$endpointURL = "TCP://${fqdn}:${hadr_port}";
$replicas+=New-SqlAvailabilityReplica -Name $primary_instance -AvailabilityMode SynchronousCommit -FailoverMode Automatic `
    -EndpointUrl $endpointURL -ConnectionModeInSecondaryRole AllowAllConnections -AsTemplate -Version 13 -Verbose;

<################################
#2.initilize secondary replicas
#################################>
foreach ($sec in $secondary_instance)
{
    Write-Verbose "enable HADR feature and create smo object for $($sec)" -Verbose;
    Enable-SqlAlwaysOn -ServerInstance $secondary_instance -Force -Verbose;
    $sec_obj=New-Object Microsoft.SQLServer.Management.SMO.Server($secondary_instance);
    $secondary_objs+= $sec_obj;

    Write-Verbose "create and enable HADR endpoint for ${sec}" -Verbose;
    $endport_obj=New-SqlHADREndpoint -InputObject $sec_obj -Name "hadr_port" -Port $hadr_port -Verbose;
    Set-SqlHADREndpoint -InputObject $endport_obj -State Started -Verbose;
}
foreach($secondary_obj in $secondary_objs)
{
    Write-Verbose "create replica for $($secondary_obj.name)" -Verbose;
    $fqdn = $secondary_obj.Information.FullyQualifiedNetName;
    $endpointURL = "TCP://${fqdn}:${hadr_port}";
    $replicas+=New-SqlAvailabilityReplica -Name $secondary_instance -AvailabilityMode AsynchronousCommit -FailoverMode Manual `
    -EndpointUrl $endpointURL -ConnectionModeInSecondaryRole AllowAllConnections -AsTemplate -Version 13 -Verbose;
}


<#######################
#3.initialize databases
########################>
foreach ($db in $db_list)
{
    # backup databases on primary
    Write-Verbose "backup database :${db}" -Verbose;
    $full_file=$backup_path+$db+'_full.bak';
    Backup-SqlDatabase -InputObject $primary_obj -Database $db -BackupAction Database -BackupFile $full_file -CompressionOption On -Initialize -Verbose;
    $log_file=$backup_path+$db+'_log.trn';
    Backup-SqlDatabase -InputObject $primary_obj -Database $db -BackupAction Log -BackupFile $log_file -CompressionOption On -Initialize -Verbose;

    # restore databases on each secondary
    foreach($secondary_obj in $secondary_objs)
    {
        Write-Verbose "restore database $db on $($secondary_obj.Name)" -Verbose;
        Restore-SqlDatabase -InputObject $secondary_obj -Database $db -RestoreAction Database -BackupFile $full_file -NoRecovery -Verbose -ReplaceDatabase;
        Restore-SqlDatabase -InputObject $secondary_obj -Database $db -RestoreAction Log -BackupFile $log_file -NoRecovery -Verbose;
    }
}

<###########################
#4.create availability group
############################>
Write-Verbose "create AG:$ag_name" -Verbose
New-SqlAvailabilityGroup -InputObject $primary_obj -Name $ag_name -AvailabilityReplica $replicas -Database $db_list -Verbose;

<#######################################
#5.add secondaries and databases to AG
########################################>
foreach($sec in $secondary_objs)
{
    Write-Verbose "join replica:$($sec.name) to AG" -Verbose;
    Join-SqlAvailabilityGroup -Name $ag_name -InputObject $sec -Verbose;
    Add-SqlAvailabilityDatabase -InputObject ($sec.AvailabilityGroups[$ag_name]) -Database $db_list -Verbose;
}

<######################
#5. create AG listener
#######################>
Write-Verbose "create AG listener" -Verbose;
New-SqlAvailabilityGroupListener -Name "AG-Listener" -InputObject $primary_obj.AvailabilityGroups[$ag_name] -StaticIp "192.168.7.219/255.255.255.0" -Verbose;



