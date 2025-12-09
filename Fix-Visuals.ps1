Write-Host "INICIANDO A PLÁSTICA NO GTWEAKS..." -ForegroundColor Green

# --- 1. CRIAR NOVO LOGO ASCII (Substitui o antigo CTTLogo) ---
$logoContent = @'
function Show-GTweaksLogo {
    Write-Host "   ____ _____                       _       " -ForegroundColor Green
    Write-Host "  / ___|_   __|_      _____  _ __ | | _____ " -ForegroundColor Green
    Write-Host " | |  _  | |  \ \ /\ / / _ \| '_ \| |/ / __|" -ForegroundColor Green
    Write-Host " | |_| | | |   \ V  V /  __/| | | |   <\__ \" -ForegroundColor Green
    Write-Host "  \____| |_|    \_/\_/ \___||_| |_|_|\_\___/" -ForegroundColor Green
    Write-Host "      OTIMIZAÇÃO DE ALTA PERFORMANCE        " -ForegroundColor DarkGray
    Write-Host ""
}
'@

# Salva na pasta correta (o nome do arquivo pode ter mudado no Rebrand, vamos garantir)
$caminhoLogo = "functions\public\Show-GTweaksLogo.ps1"
if (-not (Test-Path $caminhoLogo)) {
    # Tenta achar o arquivo antigo se o nome não mudou
    $caminhoLogo = "functions\public\Show-CTTLogo.ps1"
}
Set-Content -Path $caminhoLogo -Value $logoContent -Encoding UTF8
Write-Host "[OK] Logo novo aplicado em: $caminhoLogo" -ForegroundColor Yellow


# --- 2. TEMA VERDE (Troca o Azul #00C853 e variantes pelo Verde Tech) ---
# Vamos caçar as cores HEX do tema azul padrão e trocar por um Verde Neon/Tech
# Azul Padrão: FF00C853 / 00C853 -> Verde: FF00C853 / 00C853

$arquivosVisuais = Get-ChildItem -Path . -Recurse -Include "*.xaml", "*.json", "*.ps1"

foreach ($arquivo in $arquivosVisuais) {
    $content = Get-Content -Path $arquivo.FullName -Raw -ErrorAction SilentlyContinue
    $mudou = $false

    # Substituição 1: Azul Windows Padrão -> Verde Matrix
    if ($content -match "00C853") {
        $content = $content -replace "00C853", "00C853"
        $mudou = $true
    }

    # Substituição 2: Azul Escuro (Bordas) -> Verde Escuro
    if ($content -match "006400") {
        $content = $content -replace "006400", "006400"
        $mudou = $true
    }

    # Substituição 3: Azul Claro (Hover) -> Verde Claro
    if ($content -match "69F0AE") {
        $content = $content -replace "69F0AE", "69F0AE"
        $mudou = $true
    }

    if ($mudou) {
        Set-Content -Path $arquivo.FullName -Value $content -Encoding UTF8
        Write-Host "  [COR] Tema atualizado para verde em: $($arquivo.Name)" -ForegroundColor DarkGreen
    }
}

Write-Host "`n------------------------------------------------"
Write-Host "VISUAL ATUALIZADO."
Write-Host "IMPORTANTE: Rode o .\Compile.ps1 novamente para aplicar!" -ForegroundColor Red
Write-Host "------------------------------------------------"
