Write-Host "INICIANDO LIMPEZA PROFUNDA E TEMA VERDE..." -ForegroundColor Cyan

# --- 1. CORRIGIR O ERRO "UTILITY" (Crítico para os erros vermelhos) ---
# O problema está escondido nos arquivos .json dentro da pasta config/
Write-Host ">>> Corrigindo referências quebradas nos JSONs..." -ForegroundColor Yellow

$arquivosJson = Get-ChildItem -Path ".\config" -Filter "*.json" -Recurse

foreach ($arquivo in $arquivosJson) {
    $jsonContent = Get-Content -Path $arquivo.FullName -Raw

    # Se encontrar "GTweaks Utility", substitui impiedosamente por "GTweaks"
    if ($jsonContent -match "GTweaks Utility") {
        $jsonContent = $jsonContent -replace "GTweaks Utility", "GTweaks"
        Set-Content -Path $arquivo.FullName -Value $jsonContent -Encoding UTF8
        Write-Host "  [JSON FIXED]$($arquivo.Name)" -ForegroundColor Green
    }
}

# --- 2. CORRIGIR O LOGO (ASCII Simples - Sem Acentos) ---
Write-Host ">>> Recriando Logo..." -ForegroundColor Yellow
$logoCode = @'
function Show-GTweaksLogo {
    Write-Host "   ____ _____                       _       " -ForegroundColor Green
    Write-Host "  / ___|_   __|_      _____  _ __ | | _____ " -ForegroundColor Green
    Write-Host " | |  _  | |  \ \ /\ / / _ \| '_ \| |/ / __|" -ForegroundColor Green
    Write-Host " | |_| | | |   \ V  V /  __/| | | |   <\__ \" -ForegroundColor Green
    Write-Host "  \____| |_|    \_/\_/ \___||_| |_|_|\_\___/" -ForegroundColor Green
    Write-Host "      OPTIMIZATION TOOLKIT - HIGH PERF      " -ForegroundColor DarkGray
    Write-Host ""
}
'@
Set-Content -Path "functions\public\Show-GTweaksLogo.ps1" -Value $logoCode -Encoding UTF8


# --- 3. FORÇAR O TEMA VERDE (Substituição Inteligente no XAML) ---
Write-Host ">>> Injetando Tema Verde no XAML..." -ForegroundColor Yellow

# Define a cor Verde Matrix (#00E676)
$greenColor = "#00E676"
$darkGreen = "#1B5E20"

# Varre todos os arquivos que definem a interface
$uiFiles = Get-ChildItem -Path . -Recurse -Include "*.xaml", "Initialize-WPFUI.ps1", "inputXML.xaml"

foreach ($file in $uiFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $changed = $false

    # 1. Substitui a cor de destaque do sistema (#FF00C853) pelo nosso Verde
    if ($content -match "#FF00C853") {
        $content = $content -replace "#FF00C853", $greenColor
        $changed = $true
    }

    # 2. Substitui o Azul Padrão (Hex e Nome)
    if ($content -match "#00C853") { $content = $content -replace "#00C853", $greenColor; $changed = $true }
    if ($content -match "Blue") { $content = $content -replace "Blue", $greenColor; $changed = $true }

    # 3. Substitui cores de fundo específicas dos botões
    if ($content -match "Background=`"#FF00C853`"") {
        $content = $content -replace "Background=`"#FF00C853`"", "Background=`"$greenColor`""
        $changed = $true
    }

    if ($changed) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "  [THEME FIXED]$($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`n------------------------------------------------"
Write-Host "LIMPEZA CONCLUÍDA."
Write-Host "Agora compile novamente!"


