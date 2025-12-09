Write-Host "--- FORÇANDO TEMA VERDE (OVERRIDE) ---" -ForegroundColor Cyan

$xamlFile = "xaml\inputXML.xaml"
$backupFile = "xaml\inputXML.xaml.bak"

if (-not (Test-Path $xamlFile)) {
    Write-Error "Arquivo xaml\inputXML.xaml não encontrado!"
    exit
}

# 1. Faz backup por segurança
Copy-Item $xamlFile $backupFile -Force

# 2. Lê o conteúdo
$content = Get-Content -Path $xamlFile -Raw

# 3. Define o "Veneno Verde" (Estilos que forçam a cor)
# Isso cria recursos que sobrescrevem os padrões do Windows/WPF
$greenResources = @'
    <Window.Resources>
        <SolidColorBrush x:Key="{x:Static SystemParameters.WindowGlassBrushKey}" Color="#00C853"/>
        <SolidColorBrush x:Key="#FF00C853" Color="#00C853"/>
        <SolidColorBrush x:Key="AccentColorBrush" Color="#00C853"/>
        <SolidColorBrush x:Key="PrimaryBrush" Color="#00C853"/>

        <Style TargetType="Button">
            <Setter Property="Background" Value="#1E1E1E"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#00C853"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#00C853"/>
                    <Setter Property="Foreground" Value="Black"/>
                </Trigger>
            </Style.Triggers>
        </Style>
'@

# 4. Injeta os recursos logo após a abertura da tag <Window ...>
# Se já tiver <Window.Resources>, substituímos ou adicionamos dentro.
if ($content -match "<Window.Resources>") {
    # Se já existem recursos, vamos tentar substituir a cor Accent se ela estiver lá
    $content = $content -replace 'Color="#FF00C853"', 'Color="#FF00C853"'
    $content = $content -replace 'Color="#00C853"', 'Color="#FF00C853"'
    # E adicionamos nossos brushes de override no início dos recursos
    $content = $content -replace "<Window.Resources>", ("<Window.Resources>`n" + '        <SolidColorBrush x:Key="SystemAccentBrush" Color="#00C853"/>')
} else {
    # Se não tem recursos explícitos logo no início, injetamos depois de qualquer definição de Window
    # Procura o primeiro ">" que fecha a tag Window
    $firstTagClose = $content.IndexOf(">")
    if ($firstTagClose -gt 0) {
        $content = $content.Insert($firstTagClose + 1, "`n" + $greenResources + "`n    </Window.Resources>")
    }
}

# 5. Varredura final por Azuis Hexadecimais perdidos (CTT usa muito Hardcoded)
$content = $content -replace "#FF00C853", "#FF00C853" # Azul CTT
$content = $content -replace "#00C853", "#00C853"     # Azul Windows
$content = $content -replace "#00E676", "#00E676"

# Salva
Set-Content -Path $xamlFile -Value $content -Encoding UTF8
Write-Host "INJEÇÃO CONCLUÍDA. Cores forçadas." -ForegroundColor Green

