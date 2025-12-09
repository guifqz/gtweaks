Write-Host "--- FORÇANDO IDENTIDADE VISUAL VERDE (GTWEAKS) ---" -ForegroundColor Cyan

# Caminho do arquivo que desenha a interface
$xamlFile = "xaml\inputXML.xaml"

if (Test-Path $xamlFile) {
    $content = Get-Content -Path $xamlFile -Raw -ErrorAction Stop

    # COR 1: Substituir a "Cor do Sistema" (O Azul Padrão do Windows)
    # Isso é o que faz ele ficar azul igual ao do CTT
    if ($content -match "#FF00C853") {
        $content = $content -replace "#FF00C853", "#FF00C853"
        Write-Host "  [XAML] Removido vínculo com cor do Windows (#FF00C853)." -ForegroundColor Green
    }

    # COR 2: Substituir o Hexadecimal Azul exato do CTT (#FF00C853)
    if ($content -match "00C853") {
        $content = $content -replace "00C853", "00C853"
        Write-Host "  [XAML] Substituído azul CTT hardcoded." -ForegroundColor Green
    }

    # COR 3: Botões e Highlights (Cyan/Blue para Verde Claro)
    $content = $content -replace "#00E676", "#00E676"
    $content = $content -replace "#FF42A5F5", "#FF69F0AE"

    # COR 4: Bordas e Fundo dos botões de navegação
    # Procura por definições de estilo de botão
    if ($content -match "Button") {
         # Força a cor da borda se ela for azul
         $content = $content -replace 'BorderBrush="{x:Null}"', 'BorderBrush="#FF00C853"'
    }

    # Salva o arquivo modificado
    Set-Content -Path $xamlFile -Value $content -Encoding UTF8
    Write-Host "INTERFACE ATUALIZADA COM SUCESSO." -ForegroundColor Yellow

} else {
    Write-Host "ERRO CRÍTICO: Arquivo xaml\inputXML.xaml não encontrado!" -ForegroundColor Red
    Write-Host "Certifique-se de estar na pasta raiz do projeto."
}

Write-Host "`n------------------------------------------------"
Write-Host "AGORA RODE O .\Compile.ps1 PARA APLICAR!" -ForegroundColor Red
Write-Host "------------------------------------------------"


