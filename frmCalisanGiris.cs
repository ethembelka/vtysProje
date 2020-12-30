using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace otelRez
{
    public partial class frmCalisanGiris : Form
    {
        public frmCalisanGiris()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=otelRez; user ID=postgres; password=Ethem.2151");
        private void btnGiris_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            string isimm = txtIsim.Text.Trim();
            string sifree = txtSifre.Text.Trim();
            string sorgu = "select * from calisan where isim=@ad and sifre=@sfr";
            NpgsqlParameter prm1 = new NpgsqlParameter("ad", isimm);
            NpgsqlParameter prm2 = new NpgsqlParameter("sfr", sifree);
            NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);
            komut.Parameters.Add(prm1);
            komut.Parameters.Add(prm2);
            DataTable dt = new DataTable();
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut);
            da.Fill(dt);
            if(dt.Rows.Count >0)
            {
                frmCalisan fr = new frmCalisan();
                fr.Show();
                NpgsqlCommand komut1 = new NpgsqlCommand("select id from calisan where isim = @ad and sifre = @sfr", baglanti);
                komut1.Parameters.AddWithValue("@ad", isimm);
                komut1.Parameters.AddWithValue("@sfr", sifree);
                int calisanId = Convert.ToInt32(komut1.ExecuteScalar().ToString());

                NpgsqlCommand komut2 = new NpgsqlCommand("select soyisim from calisan where isim = @ad and sifre = @sfr", baglanti);
                komut2.Parameters.AddWithValue("@ad", isimm);
                komut2.Parameters.AddWithValue("@sfr", sifree);
                string calisanSoyisim = komut2.ExecuteScalar().ToString();

                fr.lblCalisanId.Text = calisanId.ToString();
                fr.lblCalisanIsim.Text = isimm;
                fr.lblCalisanSifre.Text = sifree;
                fr.lblCalisanSoyisim.Text = calisanSoyisim;

                this.Hide();
            }
            baglanti.Close();

        }

        private void frmCalisanGiris_Load(object sender, EventArgs e)
        {

        }
    }
}
