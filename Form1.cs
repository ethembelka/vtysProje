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
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=OtelRezervasyon; user ID=postgres; password=Ethem.2151");
        private void btnMusteri_Click(object sender, EventArgs e)
        {
            frmMusteri musteri = new frmMusteri();
            musteri.Show();
        }

        private void btnCalisan_Click(object sender, EventArgs e)
        {
            frmCalisanGiris fr = new frmCalisanGiris();
            fr.Show();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }
    }
}
