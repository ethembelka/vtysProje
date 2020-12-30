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
    public partial class frmMusteri : Form
    {
        public frmMusteri()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=otelRez; user ID=postgres; password=Ethem.2151");
        private void frmMusteri_Load(object sender, EventArgs e)
        {
            baglanti.Open();
            string sorgu = "select * from otel";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            datagridOteller.DataSource = ds.Tables[0];

            baglanti.Close();
            
        }
    }
}
