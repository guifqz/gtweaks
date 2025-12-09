Write-Host "--- INICIANDO REPARO DE BUGS E LOGO ---" -ForegroundColor Cyan

# 1. CORREÇÃO DOS NOMES DE VARIÁVEIS (Mata o erro vermelho)
# O erro acontece porque "GTweaks" tem espaço. Vamos trocar por "GTweaks" em tudo.
$arquivos = Get-ChildItem -Path . -Recurse -Include "*.ps1", "*.json", "*.xaml"

foreach ($arquivo in $arquivos) {
    $conteudo = Get-Content -Path $arquivo.FullName -Raw -ErrorAction SilentlyContinue

    if ($conteudo -match "GTweaks") {
        # Substitui "GTweaks" por "GTweaks" (remove o espaço e a palavra Utility sobrando)
        $novoConteudo = $conteudo -replace "GTweaks", "GTweaks"
        Set-Content -Path $arquivo.FullName -Value $novoConteudo -Encoding UTF8
        Write-Host "  [REPARO] Espaço removido em: $($arquivo.Name)" -ForegroundColor Green
    }
}

# 2. CORREÇÃO DO LOGO (ASCII Art limpo)
$logoContent = @'
function Show-GTweaksLogo {
    Write-Host "   ____ _____                       _       " -ForegroundColor Green
    Write-Host "  / ___|_   __|_      _____  _ __ | | _____ " -ForegroundColor Green
    Write-Host " | |  _  | |  \ \ /\ / / _ \| '_ \| |/ / __|" -ForegroundColor Green
    Write-Host " | |_| | | |   \ V  V /  __/| | | |   <\__ \" -ForegroundColor Green
    Write-Host "  \____| |_|    \_/\_/ \___||_| |_|_|\_\___/" -ForegroundColor Green
    Write-Host "      OTIMIZACAO DE ALTA PERFORMANCE        " -ForegroundColor DarkGray
    Write-Host ""
}
'@

# Força a criação do arquivo novo
$caminhoLogo = "functions\public\Show-GTweaksLogo.ps1"
Set-Content -Path $caminhoLogo -Value $logoContent -Encoding UTF8
Write-Host "[OK] Logo recriado sem acentos." -ForegroundColor Yellow
