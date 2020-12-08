#================================================================================================================
#
# Author 		 : Damien VAN ROBAEYS
#
#================================================================================================================

$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path


[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadFrom("assembly\MahApps.Metro.dll")       				| out-null
[System.Reflection.Assembly]::LoadFrom("assembly\MahApps.Metro.IconPacks.dll")      | out-null  
[System.Reflection.Assembly]::LoadFrom("assembly\ControlzEx.dll")      | out-null  
[System.Reflection.Assembly]::LoadFrom("assembly\Microsoft.Xaml.Behaviors.dll")      | out-null  


function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$Global:Current_Folder\MyGUI.xaml")

$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

[System.Windows.Forms.Application]::EnableVisualStyles()

$MonBouton = $form.FindName("MonBouton")
$Choose_Theme = $form.FindName("Choose_Theme")
$Theme_Dark = $form.FindName("Theme_Dark")
$Theme_Light = $form.FindName("Theme_Light")
$Choose_Accent = $form.FindName("Choose_Accent")


$Test_Windows_Theme = Test-Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
If ($Test_Windows_Theme)
	{
		$Windows_Theme_Key = get-itemproperty -path registry::"HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -erroraction 'silentlycontinue'	
		$Windows_Theme_Value = $Windows_Theme_Key.AppsUseLightTheme
		If($Windows_Theme_Value -ne $null)
			{
				If($Windows_Theme_Value -eq 1)
					{
						$OS_Theme = "Light"
					}
				Else
					{
						$OS_Theme = "Dark"
					}				
			}
		Else
			{
				$OS_Theme = "Light"
			}
	}
Else
	{
		$OS_Theme = "Light"
	}	
	
[ControlzEx.Theming.ThemeManager]::Current.ChangeThemeBaseColor($form,$OS_Theme)


$MonBouton.Add_Click({
	$Theme = [ControlzEx.Theming.ThemeManager]::Current.DetectTheme($form)
    $my_theme = ($Theme.BaseColorScheme)
	If($my_theme -eq "Light")
		{
            [ControlzEx.Theming.ThemeManager]::Current.ChangeThemeBaseColor($form,"Dark")
				
		}
	ElseIf($my_theme -eq "Dark")
		{					
            [ControlzEx.Theming.ThemeManager]::Current.ChangeThemeBaseColor($form,"Light")
		}		
})

$Choose_Theme.Add_SelectionChanged({	
	$Theme = [ControlzEx.Theming.ThemeManager]::Current.DetectTheme($form)
    $my_theme = ($Theme.BaseColorScheme)
	If($my_theme -eq "Light")
		{
            [ControlzEx.Theming.ThemeManager]::Current.ChangeThemeBaseColor($form,"Dark")
				
		}
	ElseIf($my_theme -eq "Dark")
		{					
            [ControlzEx.Theming.ThemeManager]::Current.ChangeThemeBaseColor($form,"Light")
		}		
})

$Choose_Accent.Add_SelectionChanged({	
	
	$Theme = [ControlzEx.Theming.ThemeManager]::Current.DetectTheme($form)
	$my_theme = ($Theme.ColorScheme)
    $Value = $Choose_Accent.SelectedValue

    [ControlzEx.Theming.ThemeManager]::Current.ChangeThemeColorScheme($form ,$Value)
})	

$Colors=@()
$Accent = [ControlzEx.Theming.ThemeManager]::Current.ColorSchemes
foreach($item in $Accent)
{
    $Choose_Accent.Items.Add($item)| Out-Null

}

[ControlzEx.Theming.ThemeManager]::Current.ChangeThemeColorScheme($form ,"Cobalt")

$Form.ShowDialog() | Out-Null

