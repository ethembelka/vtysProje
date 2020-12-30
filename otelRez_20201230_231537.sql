--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: otelRez; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "otelRez" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Turkish_Turkey.1254';


ALTER DATABASE "otelRez" OWNER TO postgres;

\connect "otelRez"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: calisanekle(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.calisanekle(isimm character varying, soyisimm character varying, sifree character varying, unvann character varying)
    LANGUAGE sql
    AS $$
INSERT INTO calisan (isim, soyisim, sifre, unvan) VALUES (isimm, soyisimm, sifree, unvann);
$$;


ALTER PROCEDURE public.calisanekle(isimm character varying, soyisimm character varying, sifree character varying, unvann character varying) OWNER TO postgres;

--
-- Name: calisanguncelle(integer, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.calisanguncelle(calisanid integer, isimm character varying, soyisimm character varying, sifree character varying, unvann character varying)
    LANGUAGE sql
    AS $$
UPDATE calisan SET isim = isimm, soyisim = soyisim, sifre=sifree, unvan = unvann WHERE(id = calisanId);
$$;


ALTER PROCEDURE public.calisanguncelle(calisanid integer, isimm character varying, soyisimm character varying, sifree character varying, unvann character varying) OWNER TO postgres;

--
-- Name: calisansil(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.calisansil(calisanid integer)
    LANGUAGE sql
    AS $$
DELETE FROM calisan WHERE (id = calisanId);
$$;


ALTER PROCEDURE public.calisansil(calisanid integer) OWNER TO postgres;

--
-- Name: evlilikteklifikar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.evlilikteklifikar() RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE
toplam money;
BEGIN
toplam = (SELECT sum("satisFiyat" - "maliyet") FROM "evlilikTeklifi");
RETURN toplam;
end;
$$;


ALTER FUNCTION public.evlilikteklifikar() OWNER TO postgres;

--
-- Name: lokantatutar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.lokantatutar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
adetFiyat money;
urununId INTEGER;
BEGIN 
urununId:= (SELECT "urunId" FROM "lokantaHesap" ORDER BY id DESC LIMIT 1);
adetFiyat:=(SELECT "birimFiyat" FROM "lokantaUrun" WHERE id = urununId );
UPDATE "lokantaHesap" SET tutar = adetFiyat * adet WHERE ("lokantaHesap"."urunId" = urununId);
RETURN NEW;
END;
$$;


ALTER FUNCTION public.lokantatutar() OWNER TO postgres;

--
-- Name: lokantatutari(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.lokantatutari(musterininid integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE
toplam money;
BEGIN
toplam = (SELECT sum(tutar) FROM "lokantaHesap" WHERE "musteriId" = musterininId);
RETURN toplam;
end;
$$;


ALTER FUNCTION public.lokantatutari(musterininid integer) OWNER TO postgres;

--
-- Name: makbuzolustur(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.makbuzolustur() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
musterininId INTEGER;
evlilikTutari money;
lokantaTutarr money;
odaTutari money;
transferTutari money;
turTutari money;
toplamTutari money;
BEGIN
musterininId:= (SELECT "musteriId" FROM makbuz ORDER BY id DESC LIMIT 1);
evlilikTutari:= (SELECT "satisFiyat" FROM "evlilikTeklifi" WHERE ("musteriId" = musterininId));
lokantaTutarr:= lokantaTutari(musterininId);
odaTutari:= (SELECT "tutar" FROM "satilanOda" WHERE ("musteriId" = musterininId));
transferTutari:= (SELECT "satisFiyat" FROM "transfer" WHERE ("musteriId" = musterininId));
turTutari:= (SELECT "tutar" FROM "satilanTur" WHERE ("musteriId" = musterininId));
toplamTutari = evlilikTutari + lokantaTutarr + odaTutari + transferTutari + turTutari;

UPDATE makbuz SET "evlilikHesap"= evlilikTutari, "lokantaHesap"=lokantaTutarr, "odaTutar"=odaTutari, "transferHesap" = transferTutari, "turHesap" = turTutari, "toplamTutar" = toplamTutari  WHERE ("musteriId" = musterininId);
RETURN NEW;
END;
$$;


ALTER FUNCTION public.makbuzolustur() OWNER TO postgres;

--
-- Name: odadurum(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.odadurum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
odaninId INTEGER;
BEGIN 
odaninId:= (SELECT "odaId" FROM "rezervasyon" ORDER BY id DESC LIMIT 1);
UPDATE "oda" SET durum=true WHERE ("id" = odaninId);
RETURN NEW;
END;
$$;


ALTER FUNCTION public.odadurum() OWNER TO postgres;

--
-- Name: raporlama(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.raporlama() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
raporId INTEGER;
toplamEvlilik money;
toplamLokanta money;
toplamOda money;
toplamTransfer money;
toplamTur money;
toplamTutarlar money;
BEGIN
raporId:= (SELECT "id" FROM rapor ORDER BY id DESC LIMIT 1);
toplamEvlilik:= (SELECT sum("satisFiyat") FROM "evlilikTeklifi");
toplamLokanta:= (SELECT sum(tutar) FROM "lokantaHesap");
toplamOda:= (SELECT sum("tutar") FROM "satilanOda");
toplamTransfer:= (SELECT sum("satisFiyat") FROM "transfer");
toplamTur:= (SELECT sum("tutar") FROM "satilanTur");
toplamTutarlar = toplamEvlilik + toplamLokanta + toplamOda + toplamTransfer + toplamTur;

UPDATE rapor SET "toplamEvlilikTeklifiTutar" = toplamEvlilik, "toplamLokantaTutar" = toplamLokanta, "toplamOdaTutar" = toplamOda, "toplamTransferTutar" = toplamTransfer, "toplamTurTutar" = toplamTur, "genelToplamTutar" = toplamTutarlar  WHERE (id = raporId);
RETURN NEW;
END;
$$;


ALTER FUNCTION public.raporlama() OWNER TO postgres;

--
-- Name: satilanodatutar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.satilanodatutar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
odaninId INTEGER;
gecelikFiyat money;
BEGIN
odaninId:= (SELECT "odaId" FROM "satilanOda" ORDER BY id DESC LIMIT 1);
gecelikFiyat := (SELECT "gecelikSatis" FROM oda WHERE id = odaninId);
UPDATE "satilanOda" set tutar = sure * gecelikFiyat WHERE "odaId" = odaninId;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.satilanodatutar() OWNER TO postgres;

--
-- Name: stokazalt(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stokazalt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
urununId INTEGER;
adedi INTEGER;
BEGIN 
urununId:= (SELECT "urunId" FROM "lokantaHesap" ORDER BY id DESC LIMIT 1);
adedi:= (select "adet" FROM "lokantaHesap" ORDER BY id DESC LIMIT 1);
UPDATE "lokantaUrun" SET stok=stok-adedi WHERE ("lokantaUrun"."id" = urununId);
RETURN NEW;
END;
$$;


ALTER FUNCTION public.stokazalt() OWNER TO postgres;

--
-- Name: transferkar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.transferkar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
transferId INTEGER;
BEGIN
transferId:= (select id FROM transfer ORDER BY id DESC LIMIT 1);
UPDATE transfer set kar = "satisFiyat" - "alisfiyat" WHERE id = transferId;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.transferkar() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: calisan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calisan (
    id integer NOT NULL,
    isim character varying(20) NOT NULL,
    soyisim character varying(20) NOT NULL,
    unvan character varying(20) NOT NULL,
    sifre character varying(10) NOT NULL
);


ALTER TABLE public.calisan OWNER TO postgres;

--
-- Name: calisan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.calisan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calisan_id_seq OWNER TO postgres;

--
-- Name: calisan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.calisan_id_seq OWNED BY public.calisan.id;


--
-- Name: evlilikTeklifi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."evlilikTeklifi" (
    "musteriId" integer NOT NULL,
    maliyet money NOT NULL,
    "satisFiyat" money NOT NULL
);


ALTER TABLE public."evlilikTeklifi" OWNER TO postgres;

--
-- Name: lokantaHesap; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."lokantaHesap" (
    "musteriId" integer NOT NULL,
    "urunId" integer NOT NULL,
    adet integer NOT NULL,
    tutar money NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public."lokantaHesap" OWNER TO postgres;

--
-- Name: lokantaHesap_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."lokantaHesap_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."lokantaHesap_id_seq" OWNER TO postgres;

--
-- Name: lokantaHesap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."lokantaHesap_id_seq" OWNED BY public."lokantaHesap".id;


--
-- Name: lokantaUrun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."lokantaUrun" (
    id integer NOT NULL,
    "birimFiyat" money NOT NULL,
    stok double precision NOT NULL,
    isim character varying(20) NOT NULL
);


ALTER TABLE public."lokantaUrun" OWNER TO postgres;

--
-- Name: lokantaUrun_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."lokantaUrun_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."lokantaUrun_id_seq" OWNER TO postgres;

--
-- Name: lokantaUrun_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."lokantaUrun_id_seq" OWNED BY public."lokantaUrun".id;


--
-- Name: makbuz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.makbuz (
    id integer NOT NULL,
    "hazirlayanId" integer,
    "musteriId" integer,
    "odaTutar" money,
    "lokantaHesap" money,
    "turHesap" money,
    "transferHesap" money,
    "evlilikHesap" money,
    "toplamTutar" money
);


ALTER TABLE public.makbuz OWNER TO postgres;

--
-- Name: makbuz_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.makbuz_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.makbuz_id_seq OWNER TO postgres;

--
-- Name: makbuz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.makbuz_id_seq OWNED BY public.makbuz.id;


--
-- Name: musteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri (
    id integer NOT NULL,
    "mAdi" character varying(20) NOT NULL,
    "mSoyadi" character varying(20) NOT NULL,
    "mCinsiyet" character(1),
    "mAdresi" character varying(60),
    "girisTarihi" timestamp without time zone NOT NULL,
    "cikisTarihi" timestamp without time zone NOT NULL,
    iletisim character varying(11) NOT NULL
);


ALTER TABLE public.musteri OWNER TO postgres;

--
-- Name: musteriYakini; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."musteriYakini" (
    "musteriId" integer NOT NULL,
    "yakinAdi" character varying(20) NOT NULL,
    "yakinSoyadi" character varying(20) NOT NULL,
    "yakinikDerecesi" character varying(20) NOT NULL
);


ALTER TABLE public."musteriYakini" OWNER TO postgres;

--
-- Name: musteri_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.musteri_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.musteri_id_seq OWNER TO postgres;

--
-- Name: musteri_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.musteri_id_seq OWNED BY public.musteri.id;


--
-- Name: oda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oda (
    "gecelikAlisFiyati" money NOT NULL,
    "odaNo" integer NOT NULL,
    "otelId" integer NOT NULL,
    "gecelikSatis" money NOT NULL,
    "yatakSayisi" integer NOT NULL,
    durum boolean NOT NULL,
    id integer NOT NULL,
    gorsel character varying(40) NOT NULL
);


ALTER TABLE public.oda OWNER TO postgres;

--
-- Name: oda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oda_id_seq OWNER TO postgres;

--
-- Name: oda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oda_id_seq OWNED BY public.oda.id;


--
-- Name: otel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.otel (
    id integer NOT NULL,
    oteladi character varying(40) NOT NULL,
    otelkonum character varying(40) NOT NULL,
    odasayisi integer NOT NULL,
    gorsel character varying(100) NOT NULL,
    telno character varying(11) NOT NULL
);


ALTER TABLE public.otel OWNER TO postgres;

--
-- Name: otel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.otel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.otel_id_seq OWNER TO postgres;

--
-- Name: otel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.otel_id_seq OWNED BY public.otel.id;


--
-- Name: rapor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rapor (
    id integer NOT NULL,
    "duzTarihi" timestamp with time zone NOT NULL,
    "toplamOdaTutar" money,
    "toplamLokantaTutar" money,
    "toplamTurTutar" money,
    "toplamTransferTutar" money,
    "toplamEvlilikTeklifiTutar" money,
    "genelToplamTutar" money,
    "duzenleyenId" integer NOT NULL
);


ALTER TABLE public.rapor OWNER TO postgres;

--
-- Name: rapor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rapor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rapor_id_seq OWNER TO postgres;

--
-- Name: rapor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rapor_id_seq OWNED BY public.rapor.id;


--
-- Name: rezervasyon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rezervasyon (
    id integer NOT NULL,
    "calisanId" integer NOT NULL,
    "musteriId" integer NOT NULL,
    "odaId" integer NOT NULL,
    "rezTarihi" timestamp with time zone NOT NULL
);


ALTER TABLE public.rezervasyon OWNER TO postgres;

--
-- Name: rezervasyon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rezervasyon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rezervasyon_id_seq OWNER TO postgres;

--
-- Name: rezervasyon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rezervasyon_id_seq OWNED BY public.rezervasyon.id;


--
-- Name: satilanOda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."satilanOda" (
    "musteriId" integer NOT NULL,
    "odaId" integer NOT NULL,
    sure integer NOT NULL,
    tutar money NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public."satilanOda" OWNER TO postgres;

--
-- Name: satilanOda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."satilanOda_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."satilanOda_id_seq" OWNER TO postgres;

--
-- Name: satilanOda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."satilanOda_id_seq" OWNED BY public."satilanOda".id;


--
-- Name: satilanTur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."satilanTur" (
    "turId" integer NOT NULL,
    "musteriId" integer NOT NULL,
    tutar money NOT NULL
);


ALTER TABLE public."satilanTur" OWNER TO postgres;

--
-- Name: transfer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transfer (
    id integer NOT NULL,
    "musteriId" integer NOT NULL,
    nereden character varying(40) NOT NULL,
    nereye character varying(40) NOT NULL,
    alisfiyat money NOT NULL,
    "satisFiyat" money NOT NULL,
    kar money NOT NULL
);


ALTER TABLE public.transfer OWNER TO postgres;

--
-- Name: transfer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transfer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfer_id_seq OWNER TO postgres;

--
-- Name: transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transfer_id_seq OWNED BY public.transfer.id;


--
-- Name: turlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turlar (
    id integer NOT NULL,
    isim character varying(40) NOT NULL,
    "alisFiyat" money NOT NULL,
    "satisFiyat" money NOT NULL
);


ALTER TABLE public.turlar OWNER TO postgres;

--
-- Name: turlar_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.turlar_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.turlar_id_seq OWNER TO postgres;

--
-- Name: turlar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.turlar_id_seq OWNED BY public.turlar.id;


--
-- Name: calisan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan ALTER COLUMN id SET DEFAULT nextval('public.calisan_id_seq'::regclass);


--
-- Name: lokantaHesap id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."lokantaHesap" ALTER COLUMN id SET DEFAULT nextval('public."lokantaHesap_id_seq"'::regclass);


--
-- Name: lokantaUrun id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."lokantaUrun" ALTER COLUMN id SET DEFAULT nextval('public."lokantaUrun_id_seq"'::regclass);


--
-- Name: makbuz id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.makbuz ALTER COLUMN id SET DEFAULT nextval('public.makbuz_id_seq'::regclass);


--
-- Name: musteri id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri ALTER COLUMN id SET DEFAULT nextval('public.musteri_id_seq'::regclass);


--
-- Name: oda id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oda ALTER COLUMN id SET DEFAULT nextval('public.oda_id_seq'::regclass);


--
-- Name: otel id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otel ALTER COLUMN id SET DEFAULT nextval('public.otel_id_seq'::regclass);


--
-- Name: rapor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rapor ALTER COLUMN id SET DEFAULT nextval('public.rapor_id_seq'::regclass);


--
-- Name: rezervasyon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezervasyon ALTER COLUMN id SET DEFAULT nextval('public.rezervasyon_id_seq'::regclass);


--
-- Name: satilanOda id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanOda" ALTER COLUMN id SET DEFAULT nextval('public."satilanOda_id_seq"'::regclass);


--
-- Name: transfer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer ALTER COLUMN id SET DEFAULT nextval('public.transfer_id_seq'::regclass);


--
-- Name: turlar id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turlar ALTER COLUMN id SET DEFAULT nextval('public.turlar_id_seq'::regclass);


--
-- Data for Name: calisan; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.calisan VALUES
	(2, 'ethemm', 'sahin', 'ebs', 'ebs'),
	(3, 'admin', 'admin', 'admin', 'admin');


--
-- Data for Name: evlilikTeklifi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."evlilikTeklifi" VALUES
	(1, '?200,00', '?350,00'),
	(2, '?400,00', '?850,00');


--
-- Data for Name: lokantaHesap; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."lokantaHesap" VALUES
	(2, 1, 4, '?60,00', 2),
	(1, 1, 4, '?60,00', 3),
	(1, 2, 3, '?60,00', 1),
	(2, 2, 1, '?20,00', 4);


--
-- Data for Name: lokantaUrun; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."lokantaUrun" VALUES
	(1, '?15,00', 1, 'kola'),
	(2, '?20,00', -1, 'ayran');


--
-- Data for Name: makbuz; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.makbuz VALUES
	(49, 2, 1, '?550,00', '?120,00', '?0,00', '?500,00', '?350,00', '?0,00');


--
-- Data for Name: musteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteri VALUES
	(1, 'eee', 'eeeee', 'e', 'eeeeee', '2020-10-10 00:00:00', '2020-10-12 00:00:00', '123456'),
	(2, 'eee', 'eeee', 'e', 'eeeee', '2020-10-15 00:00:00', '2020-10-15 00:00:00', '456789');


--
-- Data for Name: musteriYakini; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: oda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.oda VALUES
	('?300,00', 2, 1, '?450,00', 1, false, 6, 'dddd'),
	('?250,00', 1, 2, '?350,00', 2, false, 2, 'sss'),
	('?450,00', 1, 1, '?550,00', 2, true, 1, 'ddddd');


--
-- Data for Name: otel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.otel VALUES
	(1, 'aaaa', 'aaaaa', 12, 'aaaa', '123456'),
	(4, 'eeee', 'eeee', 8, 'eeee', '013345'),
	(5, 'dddd', 'dddd', 4, 'dddd', '789456'),
	(2, 'xyzt', 'bbbb', 10, 'bbb', '456789'),
	(6, 'ethem', 'bbbb', 10, 'bbb', '456789');


--
-- Data for Name: rapor; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rezervasyon; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.rezervasyon VALUES
	(1, 2, 1, 1, '2020-10-10 00:00:00+03');


--
-- Data for Name: satilanOda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."satilanOda" VALUES
	(1, 1, 1, '?550,00', 1),
	(2, 2, 2, '?700,00', 2);


--
-- Data for Name: satilanTur; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: transfer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.transfer VALUES
	(1, 1, 'aaaa', 'aaa', '?200,00', '?500,00', '?300,00');


--
-- Data for Name: turlar; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: calisan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calisan_id_seq', 3, true);


--
-- Name: lokantaHesap_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."lokantaHesap_id_seq"', 1, false);


--
-- Name: lokantaUrun_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."lokantaUrun_id_seq"', 2, true);


--
-- Name: makbuz_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.makbuz_id_seq', 49, true);


--
-- Name: musteri_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.musteri_id_seq', 2, true);


--
-- Name: oda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oda_id_seq', 7, true);


--
-- Name: otel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.otel_id_seq', 6, true);


--
-- Name: rapor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rapor_id_seq', 2, true);


--
-- Name: rezervasyon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rezervasyon_id_seq', 4, true);


--
-- Name: satilanOda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."satilanOda_id_seq"', 1, true);


--
-- Name: transfer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transfer_id_seq', 1, true);


--
-- Name: turlar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.turlar_id_seq', 1, false);


--
-- Name: lokantaHesap lokantaHesap_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."lokantaHesap"
    ADD CONSTRAINT "lokantaHesap_pkey" PRIMARY KEY (id);


--
-- Name: makbuz makbuz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.makbuz
    ADD CONSTRAINT makbuz_pkey PRIMARY KEY (id);


--
-- Name: oda oda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oda
    ADD CONSTRAINT oda_pkey PRIMARY KEY (id, "odaNo", "otelId");


--
-- Name: otel otel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otel
    ADD CONSTRAINT otel_pkey PRIMARY KEY (id);


--
-- Name: rapor rapor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rapor
    ADD CONSTRAINT rapor_pkey PRIMARY KEY (id);


--
-- Name: rezervasyon rezervasyon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezervasyon
    ADD CONSTRAINT rezervasyon_pkey PRIMARY KEY (id);


--
-- Name: satilanOda satilanOda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanOda"
    ADD CONSTRAINT "satilanOda_pkey" PRIMARY KEY (id);


--
-- Name: transfer transfer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_pkey PRIMARY KEY (id);


--
-- Name: turlar turlar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turlar
    ADD CONSTRAINT turlar_pkey PRIMARY KEY (id);


--
-- Name: oda unique_Oda_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oda
    ADD CONSTRAINT "unique_Oda_id" UNIQUE (id);


--
-- Name: calisan unique_calisan_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT unique_calisan_id PRIMARY KEY (id);


--
-- Name: evlilikTeklifi unique_evlilikTeklifi_musteriId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."evlilikTeklifi"
    ADD CONSTRAINT "unique_evlilikTeklifi_musteriId" UNIQUE ("musteriId");


--
-- Name: lokantaUrun unique_lokantaUrun_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."lokantaUrun"
    ADD CONSTRAINT "unique_lokantaUrun_id" PRIMARY KEY (id);


--
-- Name: musteri unique_musteri_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT unique_musteri_id PRIMARY KEY (id);


--
-- Name: otel unique_otel_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otel
    ADD CONSTRAINT unique_otel_id UNIQUE (id);


--
-- Name: satilanOda unique_satilanOda_musteriId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanOda"
    ADD CONSTRAINT "unique_satilanOda_musteriId" UNIQUE ("musteriId");


--
-- Name: satilanTur unique_satilanTur_musteriId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanTur"
    ADD CONSTRAINT "unique_satilanTur_musteriId" UNIQUE ("musteriId");


--
-- Name: lokantaHesap lokantatutartrig; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER lokantatutartrig AFTER INSERT ON public."lokantaHesap" FOR EACH ROW EXECUTE FUNCTION public.lokantatutar();


--
-- Name: makbuz makbuzolusturtrig; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER makbuzolusturtrig AFTER INSERT ON public.makbuz FOR EACH ROW EXECUTE FUNCTION public.makbuzolustur();


--
-- Name: rezervasyon odadurumtrig; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER odadurumtrig AFTER INSERT ON public.rezervasyon FOR EACH ROW EXECUTE FUNCTION public.odadurum();


--
-- Name: rapor raporlamatrig; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER raporlamatrig AFTER INSERT ON public.rapor FOR EACH ROW EXECUTE FUNCTION public.raporlama();


--
-- Name: satilanOda satilanodatutartrig; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER satilanodatutartrig AFTER INSERT ON public."satilanOda" FOR EACH ROW EXECUTE FUNCTION public.satilanodatutar();


--
-- Name: lokantaHesap stokazalttrig; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER stokazalttrig AFTER INSERT ON public."lokantaHesap" FOR EACH ROW EXECUTE FUNCTION public.stokazalt();


--
-- Name: transfer trasferkartrig; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trasferkartrig AFTER INSERT ON public.transfer FOR EACH ROW EXECUTE FUNCTION public.transferkar();


--
-- Name: lokantaHesap lokanta-musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."lokantaHesap"
    ADD CONSTRAINT "lokanta-musteri" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lokantaHesap lokanta-urun; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."lokantaHesap"
    ADD CONSTRAINT "lokanta-urun" FOREIGN KEY ("urunId") REFERENCES public."lokantaUrun"(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: makbuz makbuz-hazirlayan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.makbuz
    ADD CONSTRAINT "makbuz-hazirlayan" FOREIGN KEY ("hazirlayanId") REFERENCES public.calisan(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: makbuz makbuz-musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.makbuz
    ADD CONSTRAINT "makbuz-musteri" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musteriYakini musteri-mYakini; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."musteriYakini"
    ADD CONSTRAINT "musteri-mYakini" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: satilanOda oda-musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanOda"
    ADD CONSTRAINT "oda-musteri" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rezervasyon oda-rezervasyon; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezervasyon
    ADD CONSTRAINT "oda-rezervasyon" FOREIGN KEY ("odaId") REFERENCES public.oda(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: satilanOda oda-satilan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanOda"
    ADD CONSTRAINT "oda-satilan" FOREIGN KEY ("odaId") REFERENCES public.oda(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oda otel-oda; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oda
    ADD CONSTRAINT "otel-oda" FOREIGN KEY ("otelId") REFERENCES public.otel(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rapor public.rapor.rapor-calisan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rapor
    ADD CONSTRAINT "public.rapor.rapor-calisan" FOREIGN KEY ("duzenleyenId") REFERENCES public.calisan(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transfer public.transfer.transfer-musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT "public.transfer.transfer-musteri" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rezervasyon rezervasyon-calisan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezervasyon
    ADD CONSTRAINT "rezervasyon-calisan" FOREIGN KEY ("calisanId") REFERENCES public.calisan(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rezervasyon rezervasyon-musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rezervasyon
    ADD CONSTRAINT "rezervasyon-musteri" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: satilanTur satilanTur-tur; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanTur"
    ADD CONSTRAINT "satilanTur-tur" FOREIGN KEY ("turId") REFERENCES public.turlar(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: evlilikTeklifi teklif-musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."evlilikTeklifi"
    ADD CONSTRAINT "teklif-musteri" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: satilanTur tur-musteri; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."satilanTur"
    ADD CONSTRAINT "tur-musteri" FOREIGN KEY ("musteriId") REFERENCES public.musteri(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

