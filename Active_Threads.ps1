clear-host

$CurrentDir = 'C:\Users\605819\Desktop\ActiveThread\'
$Date =  (get-date).tostring("MMddyyyy")
$Time = Get-Date -Format HH
$DailyInfo = $CurrentDir + $Date							# Folder path for daily Graph

$DailyInfo



If(!(test-path $DailyInfo))
{
      New-Item -Path "C:\Users\605819\Desktop\ActiveThread" -Name $Date -ItemType "directory"
}

$user = '605819'
$pass = '9878zZ!!'

$maxATvalue = '150'							# Threshold Active Thread value

$HtmlFile = $DailyInfo + '\ServerInfo.html'

$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
Authorization = $basicAuthValue
}

$Url = "https://cams-uat.cognizant.com/stat/statusLanding?selectID=2"
$Response = Invoke-WebRequest -Uri $Url -Headers $Headers
$Response.content > $HtmlFile


$data = ""

if($Response.content -match "Threads</td></tr>(?<content>.*)</tr>" -ne 0)
{
$data = $matches['content']
} 

$cnt = 0
$str1 = ""
$str2 = ""
$lists = $data -split "</td><td>"
$count_int = 0														# Total number of Active Threads in all internal server 
$count_ext = 0														# Total number of Active Threads in all external server 
$total_ATvalue = 0													# Total number of Active Threads in all server 															
$list1 = @()
$list2 = @()
$ATvalue2 = 0

for($i=0;$i -lt $lists.length;$i+=1)
{

	if($lists[$i]  -match '^ [0-9]+$')
	{
	$cnt+=1
#		if($lists[$i] -eq ' 0' -or $lists[$i] -gt ' 400' )
	
	#if($lists[$i] -eq ' 0')
	if([int]::Parse($lists[$i]) -eq [int]::Parse(' 0'))
		{			
			if($lists[$i-1] -match "<td>(?<content>.*)" -ne 0)
				{$str1 = $matches['content'] + "`r`n"}
				$list1+=$str1				
		}
		
	if([int]::Parse($lists[$i]) -gt [int]::Parse($maxATvalue))
		{			
			if($lists[$i-1] -match "<td>(?<content>.*)" -ne 0)
				{$str2 = $matches['content'] +"#"+ $lists[$i]}
				$list2+=$str2
				#$ATvalue2+=	$lists[$i].tostring()+" "
		}
		
	if($lists[$i-1] -like "*internal*")
		{
		$count_int += $lists[$i]
		#write-host $lists[$i-1]
		}
	if($lists[$i-1] -like "*external*")
		{
		$count_ext += $lists[$i]
		#write-host $lists[$i-1]
		}

	}
}
$str = ""


if($str1.length -ne 0)
{	
	$str = " ########## Sever List with ZERO Active Threads ########## `r`n`r`n`r`n"
	$str + $str1 > $file1
}

if($str2.length -ne 0)
{	
	$str = " ########## Sever List with Active Threads more than " + $maxATvalue + " ########## `r`n`r`n`r`n" 
	$str + $str2 > $file2
}

$results_str1 = @()

write-host "List2 Length : "$List2.length
#$List1[0]

for ($i=0;$i -lt $List1.length;$i+=1)
{
	$details1 = @{            
		"Time"		= $Time           
		"Server"        = $List1[$i]
		"Active Thread"						= 0
		}
            $results_str1+= New-Object PSObject -Property $details1 			
}

$results_str2 = @()
for ($i=0;$i -lt $list2.length;$i+=1)
{
$lists = $list2[$i] -split "#"
#$lists[1]
	$details2 = @{            
		"Time"		= $Time           
		"Server"        = $lists[0]
		"Active Thread"						= $lists[1]
		}
			$results_str2+= New-Object PSObject -Property $details2
}


	#$count_int
	#$count_ext
	$total_ATvalue = $count_int + $count_ext
	#$total_ATvalue
	write-host "Total Active threads : "$cnt
	
	
	
	$path = $DailyInfo + '\a.csv'
	$results = @()
	$details = @{            
            "Internal Server AT"		= $count_int           
            "External Server AT"        = $count_ext
			"Total"						= $total_ATvalue
			"Time"						= $Time
            }

            $results+= New-Object PSObject -Property $details 
            $results | export-csv -append -Path $path -NoTypeInformation
            

$HTML_Path = $DailyInfo + '\AT.html'
$Image_Path = $DailyInfo + '\ActiveThreadGraph.png'

If(test-path $Image_Path)											# deleted old image 
{
	rm $Image_Path 
}

$line_chart_path = $CurrentDir + 'line_chart.py'

python $line_chart_path

Start-Sleep -s 1

while(!(test-path $Image_Path))											# new image created
{
      Start-Sleep -s 3
	  write-host 'image not created'
}

If(test-path $Image_Path)											# deleted old image 
{
	write-host 'image created'
}




			
			
$Header1 = @"
<Title>Service Uptime Status Report</Title>
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;display: inline-block; }
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}

</style>
<Body>
<img src=$Image_Path alt="HTML5 Icon" style="width:100%;height:50%;">
</Body>
"@

ConvertTo-Html -Head $Header1 | Out-File $HTML_Path

$results_str1 | ConvertTo-Html -Head $Header | Out-File $HTML_Path -append	

$results_str2 | ConvertTo-Html -Head $Header | Out-File $HTML_Path -append	

#ConvertTo-Html -Head $Header1 | Out-File $HTML_Path

			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
	

