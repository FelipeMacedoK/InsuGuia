#!/usr/bin/env pwsh
# Script para baixar e instalar as fontes Noto Sans

Write-Host "📥 Iniciando download de fontes Noto Sans..." -ForegroundColor Cyan
Write-Host ""

# Desabilitar barra de progresso para speed up
$ProgressPreference = 'SilentlyContinue'

# URLs das fontes (do repositório Google Noto Fonts oficial)
$regularUrl = "https://github.com/googlei18n/noto-fonts/raw/main/hinted/NotoSans-Regular.ttf"
$boldUrl = "https://github.com/googlei18n/noto-fonts/raw/main/hinted/NotoSans-Bold.ttf"

# Caminhos locais
$fontsDir = "assets/fonts"
$regularPath = "$fontsDir/NotoSans-Regular.ttf"
$boldPath = "$fontsDir/NotoSans-Bold.ttf"

# Criar diretório se não existir
if (-not (Test-Path $fontsDir)) {
    Write-Host "📁 Criando diretório: $fontsDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null
}

# Download Regular
try {
    Write-Host "⬇️  Baixando NotoSans-Regular.ttf..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $regularUrl -OutFile $regularPath -ErrorAction Stop
    Write-Host "✅ NotoSans-Regular.ttf instalada com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao baixar NotoSans-Regular.ttf: $_" -ForegroundColor Red
    exit 1
}

# Download Bold
try {
    Write-Host "⬇️  Baixando NotoSans-Bold.ttf..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $boldUrl -OutFile $boldPath -ErrorAction Stop
    Write-Host "✅ NotoSans-Bold.ttf instalada com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao baixar NotoSans-Bold.ttf: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✨ Setup de fontes concluído!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos passos:" -ForegroundColor Cyan
Write-Host "  1. Execute: flutter clean"
Write-Host "  2. Execute: flutter pub get"
Write-Host "  3. Execute: flutter run"
Write-Host ""
Write-Host "✅ Fontes instaladas em: $fontsDir" -ForegroundColor Green
