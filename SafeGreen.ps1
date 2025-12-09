Write-Host "INJETANDO VERDE (MODO SEGURO)..." -ForegroundColor Cyan

$arquivo = "functions\public\Initialize-WPFUI.ps1"

if (-not (Test-Path $arquivo)) {
    Write-Error "Arquivo Initialize-WPFUI.ps1 não encontrado!"
    exit
}

$conteudo = Get-Content -Path $arquivo -Raw

# Se já tiver a injeção, avisa e para
if ($conteudo -match "GTWEAKS_GREEN_INJECTION") {
    Write-Host "A injeção verde já existe neste arquivo." -ForegroundColor Yellow
}
else {
    # O código que vamos injetar (Define Verde Neon #00C853)
    # Tentamos aplicar em várias variáveis possíveis para garantir ($WPFGTweaksWindow, $WPFWinUtilWindow, etc)
    $codigoVerde = @'

    # --- GTWEAKS_GREEN_INJECTION START ---
    try {
        $hexGreen = "#00C853"
        $brushGreen = (New-Object System.Windows.Media.BrushConverter).ConvertFromString($hexGreen)

        # Força bruta: Tenta aplicar o verde na aplicação inteira
        [System.Windows.Application]::Current.Resources["SystemAccentColor"] = [System.Windows.Media.Color]::FromRgb(0, 200, 83)
        [System.Windows.Application]::Current.Resources["SystemAccentBrush"] = $brushGreen
        [System.Windows.Application]::Current.Resources["AccentColorBrush"] = $brushGreen
        [System.Windows.Application]::Current.Resources["PrimaryBrush"] = $brushGreen

        # Tenta aplicar nas variáveis de janela mais prováveis (pós-rebrand)
        if ($Variable:WPFGTweaksWindow) { $WPFGTweaksWindow.Resources["SystemAccentBrush"] = $brushGreen }
        if ($Variable:WPFWinUtilWindow) { $WPFWinUtilWindow.Resources["SystemAccentBrush"] = $brushGreen }
    } catch {}
    # --- GTWEAKS_GREEN_INJECTION END ---

'@

    # SUBSTITUIÇÃO SIMPLES (SEM REGEX)
    # Procura por ".ShowDialog()" e coloca o código verde antes dele
    if ($conteudo.Contains(".ShowDialog()")) {
        $novoConteudo = $conteudo.Replace(".ShowDialog()", "$codigoVerde`n    .ShowDialog()")

        Set-Content -Path $arquivo -Value $novoConteudo -Encoding UTF8
        Write-Host "SUCESSO! Código verde injetado." -ForegroundColor Green
    } else {
        Write-Host "ERRO: Não encontrei '.ShowDialog()' no arquivo." -ForegroundColor Red
    }
}

Write-Host "--------------------------------"
Write-Host "AGORA RODE O .\Compile.ps1"
Write-Host "--------------------------------"
