Write-Host "--- APLICANDO TEMA VERDE (MATRIX STYLE) ---" -ForegroundColor Green

# Definição das cores para substituição
# Azul Padrão (#00C853) -> Verde Neon (#00E676)
# Azul Escuro (#1B5E20) -> Verde Escuro (#006400)
# Azul Claro (#00E676)  -> Verde Claro (#69F0AE)
# Fundo Azulado (#1E1E1E se houver tons azuis misturados) -> Mantemos Dark Gray

$arquivosVisuais = Get-ChildItem -Path . -Recurse -Include "*.xaml", "*.ps1", "*.json", "*.xml"

foreach ($arquivo in $arquivosVisuais) {
    $content = Get-Content -Path $arquivo.FullName -Raw -ErrorAction SilentlyContinue
    $alterado = $false

    # Mapa de substituição de Cores (Hex Codes)
    # OBS: O código original usa muito "Cyan" e "Blue" nomeados. Vamos forçar Hex.

    # 1. Azul Principal -> Verde Tech
    if ($content -match "00C853") {
        $content = $content -replace "00C853", "00C853"
        $alterado = $true
    }

    # 2. Azul Hover/Highlight -> Verde Brilhante
    if ($content -match "00E676") {
        $content = $content -replace "00E676", "00E676"
        $alterado = $true
    }

    # 3. Azul Escuro/Borda -> Verde Floresta
    if ($content -match "1B5E20") {
        $content = $content -replace "1B5E20", "1B5E20"
        $alterado = $true
    }

    # 4. Substituições de texto de cor (Brute Force em XAML)
    # Cuidado: só substituímos onde for cor de controle visual
    if ($content -match 'Color="#00C853"') {
        $content = $content -replace 'Color="#00C853"', 'Color="#00C853"'
        $alterado = $true
    }
    if ($content -match 'Background="#00C853"') {
        $content = $content -replace 'Background="#00C853"', 'Background="#00C853"'
        $alterado = $true
    }
     if ($content -match 'Background="#00C853"') {
        # Isso força o verde mesmo se o Windows do usuário for azul
        $content = $content -replace 'Background="#00C853"', 'Background="#00C853"'
        $alterado = $true
    }

    if ($alterado) {
        Set-Content -Path $arquivo.FullName -Value $content -Encoding UTF8
        Write-Host "  [COR] Tema Verde aplicado em: $($arquivo.Name)" -ForegroundColor DarkGreen
    }
}

Write-Host "`nCONCLUÍDO. O azul foi eliminado."
Write-Host "IMPORTANTE: Agora rode o .\Compile.ps1" -ForegroundColor Red


