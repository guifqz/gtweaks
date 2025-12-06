<#
    GTweaks Optimizer - Versão Final (IRM Friendly)
    Alterações: 
    - Removida auto-elevação quebrada via PSCommandPath (incompatível com IRM).
    - Ajustado caminho do batch temporário para $env:TEMP para evitar Access Denied.
#>

# ==============================================================================
# 1. VERIFICAÇÃO DE ADMINISTRADOR (COMPATÍVEL COM IRM)
# ==============================================================================
$Principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (!($Principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))) {
    Write-Host "`n[ERRO CRITICO] O GTweaks precisa de privilegios de Administrador." -ForegroundColor Red
    Write-Host "Por favor, feche esta janela." -ForegroundColor Yellow
    Write-Host "Abra o PowerShell como ADMINISTRADOR e rode o comando novamente.`n" -ForegroundColor Yellow
    
    # Pausa para o usuário ler antes de fechar (caso esteja rodando direto)
    Read-Host "Pressione ENTER para sair..."
    exit
}

# ==============================================================================
# 2. CONFIGURAÇÃO DE AMBIENTE
# ==============================================================================
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==============================================================================
# 3. INTERFACE GRÁFICA (XAML)
# ==============================================================================
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="GTweaks Optimizer" Height="780" Width="1080" 
        Background="#1e1e1e" Foreground="#cccccc" WindowStartupLocation="CenterScreen">
    <Window.Resources>
        <Style TargetType="CheckBox">
            <Setter Property="Margin" Value="0,3,0,3"/>
            <Setter Property="Foreground" Value="#dddddd"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
        <Style TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI"/>
        </Style>
    </Window.Resources>
    
    <Grid Margin="15">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="20"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <RowDefinition Height="*"/>    <RowDefinition Height="Auto"/> <RowDefinition Height="150"/>  </Grid.RowDefinitions>

        <TextBlock Text="GTweaks Essentials" Grid.Column="0" Grid.Row="0" FontSize="20" Foreground="#007ACC" FontWeight="Bold" Margin="0,0,0,10"/>
        <TextBlock Text="Advanced Tweaks" Grid.Column="2" Grid.Row="0" FontSize="20" Foreground="#007ACC" FontWeight="Bold" Margin="0,0,0,10"/>

        <ScrollViewer Grid.Column="0" Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="PanelEssentials">
                <CheckBox Name="chkRestorePoint" Content="Create Restore Point (RECOMMENDED)" FontWeight="Bold" Foreground="#FFFFFF"/>
                <CheckBox Name="chkDeepClean" Content="Deep Clean Cache &amp; Event Logs (Matrix Mode)"/>
                <CheckBox Name="chkTempFiles" Content="Delete Temporary Files (Basic)"/>
                <CheckBox Name="chkConsumer" Content="Disable Consumer Features (CandyCrush)"/>
                <CheckBox Name="chkTelemetry" Content="Disable Telemetry (?)"/>
                <CheckBox Name="chkActivity" Content="Disable Activity History (?)"/>
                <CheckBox Name="chkFolderDiscovery" Content="Disable Explorer Auto Folder Discovery"/>
                <CheckBox Name="chkGameDVR" Content="Disable GameDVR (?)"/>
                <CheckBox Name="chkHibernation" Content="Disable Hibernation (?)"/>
                <CheckBox Name="chkLocation" Content="Disable Location Tracking (?)"/>
                <CheckBox Name="chkStorageSense" Content="Disable Storage Sense (?)"/>
                <CheckBox Name="chkWifiSense" Content="Disable Wi-Fi Sense (?)"/>
                <CheckBox Name="chkEndTask" Content="Enable End Task With Right Click (?)"/>
                <CheckBox Name="chkDiskCleanup" Content="Run Disk Cleanup (Windows Tool)"/>
                <CheckBox Name="chkPSTelemetry" Content="Disable PowerShell 7 Telemetry (?)"/>
                <CheckBox Name="chkServicesManual" Content="Set Services to Manual (Safe List) (?)"/>
            </StackPanel>
        </ScrollViewer>

        <ScrollViewer Grid.Column="2" Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="PanelAdvanced">
                <CheckBox Name="chkAdobeBlock" Content="Adobe Network Block (Firewall)"/>
                <CheckBox Name="chkAdobeDebloat" Content="Adobe Debloat (Services)"/>
                <CheckBox Name="chkRazerBlock" Content="Block Razer Software Installs"/>
                <CheckBox Name="chkEdgeDebloat" Content="Edge Debloat (Policy)"/>
                <CheckBox Name="chkDisableEdge" Content="Disable Edge (Registry)"/>
                <CheckBox Name="chkBgApps" Content="Disable Background Apps"/>
                <CheckBox Name="chkFullscreenOpt" Content="Disable Fullscreen Optimizations"/>
                <CheckBox Name="chkTeredo" Content="Disable Teredo"/>
                <CheckBox Name="chkRecall" Content="Disable Recall (AI)"/>
                <CheckBox Name="chkCopilot" Content="Disable Microsoft Copilot"/>
                <CheckBox Name="chkIntelMM" Content="Disable Intel MM (vPro LMS)"/>
                <CheckBox Name="chkTrayCalendar" Content="Disable Notification Tray/Calendar"/>
                <CheckBox Name="chkWPBT" Content="Disable Windows Platform Binary Table"/>
                <CheckBox Name="chkPerfDisplay" Content="Set Display for Performance"/>
                <CheckBox Name="chkHibernationDefault" Content="Set Hibernation as default"/>
                <CheckBox Name="chkClassicMenu" Content="Set Classic Right-Click Menu"/>
                <CheckBox Name="chkUTCTime" Content="Set Time to UTC (Dual Boot)"/>
                <CheckBox Name="chkRemoveHome" Content="Remove Home from Explorer"/>
                <CheckBox Name="chkRemoveGallery" Content="Remove Gallery from Explorer"/>
                <CheckBox Name="chkRemoveOneDrive" Content="Remove OneDrive"/>
            </StackPanel>
        </ScrollViewer>

        <Grid Grid.Row="2" Grid.ColumnSpan="3" Margin="0,15,0,5">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="150"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            
            <Button Name="btnSelectAll" Content="SELECT ALL" Grid.Column="0" Height="45" Margin="0,0,10,0"
                    Background="#444444" Foreground="White" FontWeight="Bold" FontSize="14" BorderThickness="0" Cursor="Hand">
                 <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="5"/>
                    </Style>
                </Button.Resources>
            </Button>

            <Button Name="btnRun" Content="RUN GTWEAKS" Grid.Column="1" Height="45" 
                    Background="#007ACC" Foreground="White" FontWeight="Bold" FontSize="16" BorderThickness="0" Cursor="Hand">
                <Button.Resources>
                    <Style TargetType="Border">
                        <Setter Property="CornerRadius" Value="5"/>
                    </Style>
                </Button.Resources>
            </Button>
        </Grid>

        <TextBox Name="txtLog" Grid.Row="3" Grid.ColumnSpan="3" Background="#111111" Foreground="#00FF00" 
                 FontFamily="Consolas" FontSize="12" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"
                 Padding="5"/>
    </Grid>
</Window>
"@

# ==============================================================================
# 4. FUNÇÕES DE SUPORTE
# ==============================================================================
$Reader = (New-Object System.Xml.XmlNodeReader $XAML)
try {
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} catch {
    Write-Host "Erro XAML: $_"
    exit
}

$txtLog = $Window.FindName("txtLog")
$btnRun = $Window.FindName("btnRun")
$btnSelectAll = $Window.FindName("btnSelectAll")

# Log Header na UI (Apenas Visual)
$txtLog.AppendText("GTweaks Engine Loaded.`r`nReady.`r`n")

function Log-Write {
    param([string]$Msg)
    $TimeStamp = (Get-Date).ToString('HH:mm:ss')
    $FormattedLine = "[$TimeStamp] $Msg"

    # UI ONLY
    $txtLog.AppendText("$FormattedLine`r`n")
    $txtLog.ScrollToEnd()
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-Reg {
    param($Path, $Name, $Value, $Type="DWord")
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
    Log-Write "Registry: $Name set to $Value"
}

# ==============================================================================
# 5. LÓGICA DOS TWEAKS
# ==============================================================================
$Actions = @{}

# --- NEW: DEEP CLEANER VISUAL ---
$Actions["chkDeepClean"] = {
    Log-Write "Iniciando Deep Clean (Janela Externa)..."
    
    $BatchContent = @"
@echo off
cd /d "%TEMP%"
color 0A
title GTweaks Deep Cleaner - EXECUTANDO
cls
echo ===================================================
echo          GTWEAKS - DEEP CLEANING MATRIX
echo ===================================================
echo.
echo [PROCESSANDO] Limpando Arquivos Temp...
echo.
del /s /f /q "%temp%\*.*"
del /s /f /q "C:\Windows\Temp\*.*"
echo.
echo [OK] Limpeza Temp finalizada.
echo.
echo [PROCESSANDO] Limpando Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*"
echo [OK] Prefetch limpo.
echo.
echo [PROCESSANDO] Limpando Logs de Eventos...
echo (Isso pode levar alguns segundos)...
echo.
for /F "tokens=*" %%A in ('wevtutil.exe el') do (
    echo Limpando Log: %%A
    wevtutil.exe cl "%%A"
)
echo.
echo ===================================================
echo              LIMPEZA CONCLUIDA!
echo ===================================================
echo.
echo Pode fechar esta janela para voltar ao GTweaks.
pause
"@
    
    # FIX: Usar Temp path em vez de C:\ raiz para evitar Access Denied
    $BatchPath = "$env:TEMP\GTweaks_Cleaner.bat"
    
    try {
        $BatchContent | Out-File -FilePath $BatchPath -Encoding ASCII -Force
        Start-Process "cmd.exe" -ArgumentList "/c start cmd /c `"$BatchPath`"" -WindowStyle Hidden
        Log-Write "Janela de limpeza aberta com sucesso."
    } catch {
        Log-Write "ERRO FATAL: $_"
        [System.Windows.MessageBox]::Show("Erro ao criar arquivo: $_")
    }
}

# --- ESSENTIALS ---
$Actions["chkRestorePoint"] = {
    Log-Write "Criando Restore Point (GTweaks)..."
    Checkpoint-Computer -Description "GTweaks Backup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
}
$Actions["chkTempFiles"] = {
    Log-Write "Limpando Temp (Silencioso)..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}
$Actions["chkConsumer"] = {
    Log-Write "Desativando Consumer Features..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
}
$Actions["chkTelemetry"] = {
    Log-Write "Desativando Telemetria..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
    Stop-Service DiagTrack -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled
}
$Actions["chkActivity"] = {
    Log-Write "Desativando Activity History..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 0
}
$Actions["chkFolderDiscovery"] = {
    Log-Write "Desativando Folder Discovery..."
    $HKCU = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"
    if (!(Test-Path $HKCU)) { New-Item -Path $HKCU -Force | Out-Null }
    Set-ItemProperty -Path $HKCU -Name "FolderType" -Value "NotSpecified" -Force | Out-Null
}
$Actions["chkGameDVR"] = {
    Log-Write "Desativando GameDVR..."
    Set-Reg "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 0
}
$Actions["chkHibernation"] = {
    Log-Write "Desativando Hibernacao..."
    powercfg /h off
}
$Actions["chkLocation"] = {
    Log-Write "Desativando Location Tracking..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 1
}
$Actions["chkStorageSense"] = {
    Log-Write "Desativando Storage Sense..."
    Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" 0
}
$Actions["chkWifiSense"] = {
    Log-Write "Desativando Wi-Fi Sense..."
    Set-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0
}
$Actions["chkEndTask"] = {
    Log-Write "Ativando End Task..."
    Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarEndTask" 1
}
$Actions["chkDiskCleanup"] = {
    Log-Write "Executando Disk Cleanup (Cleanmgr)..."
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files"
    Set-ItemProperty -Path $RegPath -Name "StateFlags0001" -Value 2 -Type DWord -Force | Out-Null
    Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -NoNewWindow -Wait
}
$Actions["chkPSTelemetry"] = {
    Log-Write "Desativando PS Telemetry..."
    [Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "Machine")
}
$Actions["chkServicesManual"] = {
    Log-Write "Servicos para Manual..."
    $Services = @("DiagTrack", "WwerSvc", "DPS", "MapsBroker") 
    foreach ($svc in $Services) { Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue }
}

# --- ADVANCED ---
$Actions["chkAdobeBlock"] = {
    Log-Write "Bloqueando Adobe Firewall..."
    $AdobePath = "C:\Program Files\Adobe"
    if (Test-Path $AdobePath) {
        New-NetFirewallRule -DisplayName "Block Adobe Outbound" -Direction Outbound -Program "$AdobePath\*" -Action Block -ErrorAction SilentlyContinue
    }
}
$Actions["chkAdobeDebloat"] = {
    Log-Write "Adobe Debloat..."
    Get-Service | Where-Object {$_.Name -like "*Adobe*Update*"} | Stop-Service -Force -ErrorAction SilentlyContinue
    Get-Service | Where-Object {$_.Name -like "*Adobe*Update*"} | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
}
$Actions["chkRazerBlock"] = {
    Log-Write "Bloqueando Razer Synapse..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Razer\Synapse3" "InstallDir" "C:\Null" -Type String
}
$Actions["chkEdgeDebloat"] = {
    Log-Write "Edge Debloat..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "HubsSidebarEnabled" 0
}
$Actions["chkDisableEdge"] = {
    Log-Write "Desativando Edge Pre-launch..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "AllowPrelaunch" 0
}
$Actions["chkBgApps"] = {
    Log-Write "Desativando Background Apps..."
    Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1
}
$Actions["chkFullscreenOpt"] = {
    Log-Write "Desativando Fullscreen Optimizations..."
    Set-Reg "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2
}
$Actions["chkTeredo"] = {
    Log-Write "Desativando Teredo..."
    netsh interface teredo set state disabled
}
$Actions["chkRecall"] = {
    Log-Write "Desativando Recall AI..."
    Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 1
}
$Actions["chkCopilot"] = {
    Log-Write "Desativando Copilot..."
    Set-Reg "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
}
$Actions["chkClassicMenu"] = {
    Log-Write "Menu Classico W11..."
    Set-Reg "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" "" "" -Type String
}
$Actions["chkRemoveOneDrive"] = {
    Log-Write "Removendo OneDrive..."
    taskkill /f /im OneDrive.exe -ErrorAction SilentlyContinue
    if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
        Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall" -Wait
    }
}
$Actions["chkRemoveHome"] = {
    Log-Write "Removendo Home do Explorer..."
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace_36354489\DelegateFolders\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" "Status" 0
}
$Actions["chkRemoveGallery"] = {
    Log-Write "Removendo Gallery do Explorer..."
    Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace_36354489\DelegateFolders\{e88865ea-0e1c-4e20-9aa6-ed25316e5390}" "Status" 0
}
$Actions["chkIntelMM"] = {
    Log-Write "Desativando Intel LMS..."
    Stop-Service "LMS" -ErrorAction SilentlyContinue
    Set-Service "LMS" -StartupType Disabled -ErrorAction SilentlyContinue
}
$Actions["chkWPBT"] = { Log-Write "WPBT nao suportado (Requer BIOS)." }
$Actions["chkUTCTime"] = {
    Log-Write "Setando UTC Time..."
    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" 1
}
$Actions["chkHibernationDefault"] = {
    Log-Write "Setando Hibernacao como padrao..."
    powercfg /h on
}
$Actions["chkTrayCalendar"] = { Log-Write "Tweak de Calendario nao implementado." }

# ==============================================================================
# 6. HANDLERS E EXECUÇÃO
# ==============================================================================

# --- BOTÃO SELECT ALL ---
$btnSelectAll.Add_Click({
    $PanelEssentials = $Window.FindName("PanelEssentials")
    $PanelAdvanced = $Window.FindName("PanelAdvanced")
    
    function Check-All($Panel) {
        foreach ($child in $Panel.Children) {
            if ($child.GetType().Name -eq "CheckBox") {
                $child.IsChecked = $true
            }
        }
    }
    
    Check-All $PanelEssentials
    Check-All $PanelAdvanced
    Log-Write "Todas as opcoes foram selecionadas (Cuidado!)."
})

# --- BOTÃO RUN ---
$btnRun.Add_Click({
    $btnRun.IsEnabled = $false
    $btnRun.Content = "Processing..."
    $btnRun.Background = "#333333"

    $PanelEssentials = $Window.FindName("PanelEssentials")
    $PanelAdvanced = $Window.FindName("PanelAdvanced")

    function Run-Checks($Panel) {
        foreach ($child in $Panel.Children) {
            if ($child.GetType().Name -eq "CheckBox" -and $child.IsChecked) {
                if ($Actions.ContainsKey($child.Name)) {
                    & $Actions[$child.Name]
                }
            }
        }
    }

    Run-Checks $PanelEssentials
    Run-Checks $PanelAdvanced

    Log-Write "--- FINALIZADO ---"
    Log-Write "Reinicie o PC para aplicar as mudancas do GTweaks."
    
    $btnRun.IsEnabled = $true
    $btnRun.Content = "RUN GTWEAKS"
    $btnRun.Background = "#007ACC"
    
    [System.Windows.MessageBox]::Show("Processo GTweaks finalizado!", "GTweaks")
})

$Window.ShowDialog() | Out-Null
