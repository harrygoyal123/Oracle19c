#Task1:- To check CPU Utilization of Server, if utilization is above 90%, list top 5 cpu consuming processes created

$path = Read-Host "Enter the path to get a list of Servers" #Enter the path of server file
 
try                                                          #using try catch for path related exceptions
{
    $serverlist = Get-Content -path $path -ErrorAction stop
    $null = ""

    if($serverlist -eq $null)                                      # Check the serverlist file is empty               
    {
        Write-Host "The File may be Empty" -ForegroundColor Red    # if the serverlist file is empty
    }
    else 
    {
        foreach($server in $serverlist)
        { 
            $testpath = Test-Path "\\$server\c$"                    # Check the Servers existence

            if($testpath -eq "True")                                # if server exists or found
            {  
                $utilization = (Get-WmiObject -ComputerName $server -Class win32_processor -ErrorAction SilentlyContinue | Measure-Object  LoadPercentage -Average ).Average     # calculate cpu utilization of each server   
                Write-Host "`n$server :- `nCPU Utilization Percantage of $server : $utilization"   # write cpu utilization of each server 
      
                if($utilization -ge 90)                             # if block run when cpu utilization is greater then 90%
                {        
                    Invoke-Command -ComputerName $server -ScriptBlock{     # to run script on available servers 
                        try                                                # using try catch for export-file or processes related exceptions
                        {        
	                        $server = hostname        
	                        ($server,(Get-Process | Select-Object id,CPU,Name -First 5 | Sort-Object CPU -Descending)) | Out-File "\\jumphost\C$\Users\Administrator.DEMO\Desktop\21stDec.csv" -Force -Append   # to print top 5 processes in descending order of there cpu utilization in a csv file 
                        }
                        catch [UnauthorizedAccessException]    # when access is denied for server to create out-file to specific location 
                        {
                            Write-Host "Access to outfile path is denied in $server" -ForegroundColor Red
                        }
                        catch                                  # when any other exception occured
                        {
                            Write-Host $_.Exception.Message -ForegroundColor yellow
                        }
                    }
                }
                else                    # if cpu utilization below 90%
                {
                    Write-Host "$server CPU Utilization is not high" -ForegroundColor Green    
                }
            }
            else                        # when server not found
            {    
                Write-Host "`n$server Server is Not Found" -ForegroundColor Red  
            }
        } 
    }
}
catch [System.Management.Automation.ItemNotFoundException]    #if path of server file not foumd
{ 
    Write-Host "The path was not found" -ForegroundColor Red
}
catch [UnauthorizedAccessException]                           #if unauthorizedaccessexception occurs 
{ 
    Write-Host "The access was denied to that path" -ForegroundColor Red 
}
catch                                                         #if any other exception occured related to path
{
    Write-Host "Invalid path format" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor yellow
}