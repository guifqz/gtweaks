Write-Host "INICIANDO LIMPEZA FINAL E CORREÇÃO DE BUGS..." -ForegroundColor Cyan

# --- 1. CORREÇÃO DOS NOMES DE BOTÕES (Remove espaços proibidos) ---
# O erro acontece porque "GTweaks" tem espaço. Vamos simplificar para "GTweaks".
# Isso vai consertar o erro: 'WPFGTweaksInstallPSProfile' is not a valid value

$arquivosCodigo = Get-ChildItem -Path . -Recurse -Include "*.ps1", "*.xaml", "*.json"

foreach ($arquivo in $arquivosCodigo) {
    $conteudo = Get-Content -Path $arquivo.FullName -Raw -ErrorAction SilentlyContinue

    # Procura por "GTweaks" e troca por "GTweaks" (remove o " Utility" e o espaço)
    if ($conteudo -match "GTweaks") {
        $novoConteudo = $conteudo -replace "GTweaks", "GTweaks"
        Set-Content -Path $arquivo.FullName -Value $novoConteudo -Encoding UTF8
        Write-Host "  [FIX] Espaço removido em: $($arquivo.Name)" -ForegroundColor Green
    }
}

# --- 2. CORREÇÃO DO LOGO (Sem acentos para evitar ?????) ---
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

# Salva o logo corrigido
$caminhoLogo = "functions\public\Show-GTweaksLogo.ps1"
if (Test-Path $caminhoLogo) {
    Set-Content -Path $caminhoLogo -Value $logoContent -Encoding UTF8
    Write-Host "[OK] Logo atualizado (sem acentos)." -ForegroundColor Yellow
} else {
    Write-Host "[ERRO] Arquivo de logo não encontrado em $caminhoLogo" -ForegroundColor Red
}

Write-Host "`n------------------------------------------------"
Write-Host "CORREÇÕES APLICADAS."
Write-Host "1. Rode o .\Compile.ps1 novamente."
Write-Host "2. Teste o .\GTweaks.ps1"
Write-Host "------------------------------------------------"
