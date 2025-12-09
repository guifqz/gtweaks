Write-Host "MODO BRUTO: SUBSTITUINDO CORES NO XAML..." -ForegroundColor Cyan

$arquivo = "xaml\inputXML.xaml"

if (-not (Test-Path $arquivo)) {
    Write-Error "ERRO: xaml\inputXML.xaml nao encontrado!"
    exit
}

$txt = Get-Content -Path $arquivo -Raw

# 1. Substitui o Azul CTT (#0078D7) pelo Verde (#00C853)
if ($txt.Contains("0078D7")) {
    $txt = $txt.Replace("0078D7", "00C853")
    Write-Host "[FIX] Azul CTT (0078D7) substituido." -ForegroundColor Green
}

# 2. Substitui a Referencia ao Sistema (SystemAccentColor)
# Isso e o que faz ele ficar azul igual ao Windows
if ($txt.Contains("SystemAccentColor")) {
    # Truque: Trocamos o nome do recurso dinamico por uma cor estatica
    $txt = $txt.Replace("{DynamicResource SystemAccentColor}", "#FF00C853")
    $txt = $txt.Replace("{x:Static SystemParameters.WindowGlassBrushKey}", "#FF00C853")
    Write-Host "[FIX] Vinculo com cor do Windows removido." -ForegroundColor Green
}

# 3. Substitui "Blue" e "DeepSkyBlue"
$txt = $txt.Replace("DeepSkyBlue", "#00E676")
$txt = $txt.Replace("Blue", "#00C853")

Set-Content -Path $arquivo -Value $txt -Encoding UTF8
Write-Host "CONCLUIDO."
