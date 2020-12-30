using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace otelRez
{
    public partial class frmCalisan : Form
    {
        public frmCalisan()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=otelRez; user ID=postgres; password=Ethem.2151");
        private void frmCalisan_Load(object sender, EventArgs e)
        {
            baglanti.Open();
            string sorgu = "select * from otel";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            datagridOteller.DataSource = ds.Tables[0];

            string sorgu1 = "select * from oda";
            NpgsqlDataAdapter da1 = new NpgsqlDataAdapter(sorgu1, baglanti);
            DataSet ds1 = new DataSet();
            da1.Fill(ds1);
            datagridOdalar.DataSource = ds1.Tables[0];

            string sorgu2 = "select * from rezervasyon";
            NpgsqlDataAdapter da2 = new NpgsqlDataAdapter(sorgu2, baglanti);
            DataSet ds2 = new DataSet();
            da2.Fill(ds2);
            datagridRez.DataSource = ds2.Tables[0];

            string sorgu4 = "select * from makbuz";
            NpgsqlDataAdapter da4 = new NpgsqlDataAdapter(sorgu4, baglanti);
            DataSet ds4 = new DataSet();
            da4.Fill(ds4);
            datagridMakbuz.DataSource = ds4.Tables[0];
            baglanti.Close();
        }

        private void btnOtelEkle_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand komut1 = new NpgsqlCommand("insert into otel (otelAdi,otelKonum,odasayisi,gorsel,telno) values (@p2,@p3,@p4,@p5,@p6)", baglanti);
           //komut1.Parameters.AddWithValue("@p1", int.Parse(txtID.Text));
            komut1.Parameters.AddWithValue("@p2", txtAd.Text);
            komut1.Parameters.AddWithValue("@p3", txtKonum.Text);
            komut1.Parameters.AddWithValue("@p4", int.Parse(txtOdaSayisi.Text));
            komut1.Parameters.AddWithValue("@p5", txtGorsel.Text);
            komut1.Parameters.AddWithValue("@p6", txtTel.Text);
            komut1.ExecuteNonQuery();

            string sorgu = "select * from otel";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            datagridOteller.DataSource = ds.Tables[0];

            baglanti.Close();

            MessageBox.Show("Otel Başarı İle Kaydeilmiştir.");
        }

        private void datagridOteller_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            txtID.Text = datagridOteller.Rows[e.RowIndex].Cells[0].Value.ToString();
            txtAd.Text = datagridOteller.Rows[e.RowIndex].Cells[1].Value.ToString();
            txtKonum.Text = datagridOteller.Rows[e.RowIndex].Cells[2].Value.ToString();
            txtGorsel.Text = datagridOteller.Rows[e.RowIndex].Cells[4].Value.ToString();
            txtOdaSayisi.Text = datagridOteller.Rows[e.RowIndex].Cells[3].Value.ToString();
            txtTel.Text = datagridOteller.Rows[e.RowIndex].Cells[5].Value.ToString();
        }

        private void btnOtelGuncelle_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand komut3 = new NpgsqlCommand("update otel set otelAdi=@p1,otelKonum=@p2,odasayisi=@p3,gorsel=@p4,telno=@p5 where(id=@p6)", baglanti);
            komut3.Parameters.AddWithValue("@p1", txtAd.Text.Trim());
            komut3.Parameters.AddWithValue("@p2", txtKonum.Text.Trim());
            komut3.Parameters.AddWithValue("@p3", int.Parse(txtOdaSayisi.Text));
            komut3.Parameters.AddWithValue("@p4", txtGorsel.Text.Trim());
            komut3.Parameters.AddWithValue("@p5", txtTel.Text.Trim());
            komut3.Parameters.AddWithValue("@p6", int.Parse(txtID.Text.Trim()));
            komut3.ExecuteNonQuery();

            string sorgu = "select * from otel";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            datagridOteller.DataSource = ds.Tables[0];

            baglanti.Close();

            MessageBox.Show("Otel Başarı İle Güncellenmiştir.");
        }

        private void btnOtelSil_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            NpgsqlCommand komut4 = new NpgsqlCommand("delete from otel where id=@p1", baglanti);
            komut4.Parameters.AddWithValue("@p1", int.Parse(txtID.Text.Trim()));
            komut4.ExecuteNonQuery();

            string sorgu = "select * from otel";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            datagridOteller.DataSource = ds.Tables[0];

            baglanti.Close();

            MessageBox.Show("Otel Başarı İle Silinmiştir.");

        }
    }
}
