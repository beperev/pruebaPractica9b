export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe; 
export ORACLE_SID=XE; 
$ORACLE_HOME/bin/sqlplus -S travis/travis <<SQL
whenever sqlerror exit 2;
CREATE SCHEMA AUTHORIZATION travis; 
ALTER SESSION SET CURRENT_SCHEMA = travis;
CREATE TABLE ZONA (
  CODIGO  NUMBER (1)    CONSTRAINT PK_ZONA PRIMARY KEY,
  NOMBRE  VARCHAR2 (20) NOT NULL);

CREATE TABLE CODIGOPOSTAL (
  ZONA       NUMBER(1)     NOT NULL CONSTRAINT FK_CODIGOPOSTAL_ZONA REFERENCES ZONA(codigo),
  PROVINCIA  VARCHAR2 (25) NOT NULL,
  CPMIN      VARCHAR2 (5)  NOT NULL,
  CPMAX      VARCHAR2 (5)  NOT NULL);


CREATE TABLE ALMACEN (
  CODIGO  VARCHAR2 (10) CONSTRAINT PK_ALMACEN PRIMARY KEY,
  CALLE   VARCHAR2 (50) NOT NULL,
  CIUDAD  VARCHAR2 (20) NOT NULL,
  CP      VARCHAR2 (5)  NOT NULL,
  ZONA    NUMBER (1)    NOT NULL CONSTRAINT FK_ALMACEN_ZONA REFERENCES ZONA(codigo));
 

CREATE TABLE ARTICULO (
  CODIGO  VARCHAR2 (10)  CONSTRAINT PK_ARTICULO PRIMARY KEY,
  NOMBRE  VARCHAR2 (50)  NOT NULL,
  PVP     NUMBER  (10,2) NOT NULL);


CREATE TABLE CLIENTE (
  CODIGO  VARCHAR2 (10)  CONSTRAINT PK_CLIENTE PRIMARY KEY,
  CIF     VARCHAR2 (12)  NOT NULL CONSTRAINT UNQ_CIF UNIQUE,
  NOMBRE  VARCHAR2 (50)  NOT NULL,
  CALLE   VARCHAR2 (50)  NOT NULL,
  CP      VARCHAR2 (5)   NOT NULL,
  CIUDAD  VARCHAR2 (20)  NOT NULL);


CREATE TABLE FESTIVO (
  FECHA  DATE          NOT NULL);


CREATE TABLE PEDIDO (
  CODIGO         VARCHAR2 (10) CONSTRAINT PK_PEDIDO PRIMARY KEY,
  CODIGOCLIENTE  VARCHAR2 (10) NOT NULL CONSTRAINT FK_PEDIDO_CODIGOCLIENTE REFERENCES CLIENTE(codigo),
  FECHACIERRE    DATE          NOT NULL,
  CALLE          VARCHAR2 (50) NOT NULL,
  CP             VARCHAR2 (5)  NOT NULL,
  CIUDAD         VARCHAR2 (20) NOT NULL,
  CURSADO        NUMBER (1)    DEFAULT 0);


CREATE TABLE PEDIDOANULADO (
  CODIGO         VARCHAR2 (10) CONSTRAINT PK_PEDIDOANULADO PRIMARY KEY,
  FECHACIERRE    DATE          NOT NULL,
  FECHAANULACION DATE          NOT NULL,
  CODIGOCLIENTE  VARCHAR2 (10) NOT NULL CONSTRAINT FK_PEDIDOANULADO_CODIGOCLIENTE REFERENCES CLIENTE(codigo));


CREATE TABLE PEDIDOENREALIZACION (
  CODIGO         VARCHAR2 (10) CONSTRAINT PK_PEDIDOENREALIZACION PRIMARY KEY,
  FECHAINICIO    DATE          NOT NULL,
  CODIGOCLIENTE  VARCHAR2 (10) NOT NULL UNIQUE CONSTRAINT FK_PED_ENREALIZ_CODCLI REFERENCES CLIENTE(codigo));


CREATE TABLE LINEA (
  CODIGO                varchar2 (13) CONSTRAINT PK_LINEA PRIMARY KEY,
  CODIGOPEDIDO          VARCHAR2 (10) NOT NULL CONSTRAINT FK_LINEA_CODIGOPEDIDO REFERENCES PEDIDO(codigo),
  CODIGOARTICULO        VARCHAR2 (10) NOT NULL CONSTRAINT FK_LINEA_CODIGOARTICULO REFERENCES ARTICULO(codigo),
  CANTIDAD              NUMBER (2)    NOT NULL CONSTRAINT CHK_LINEA_CANTIDAD CHECK (cantidad >=0),
  PRECIOBASE            NUMBER (10,2) NOT NULL,
  FECHAENTREGADESEADA   DATE,
  FECHAENTREGAPREVISTA  DATE,
  FECHAENTREGAREAL      DATE,
  FECHARECEPCION        DATE,
  PRECIOREAL            NUMBER (10,2) NOT NULL);

CREATE TABLE LINEAANULADA (
  CODIGO               varchar2 (13) CONSTRAINT PK_LINEAANULADA PRIMARY KEY,
  CODIGOARTICULO       VARCHAR2 (10) NOT NULL CONSTRAINT FK_LINEAANULADA_CODIGOARTICULO REFERENCES ARTICULO(codigo),
  CANTIDAD             NUMBER (2)    NOT NULL CONSTRAINT CHK_LINEAANULADA_CANTIDAD CHECK (cantidad >=0),
  CODIGOPEDIDO         VARCHAR2 (10) NOT NULL CONSTRAINT FK_LINEAANULADA_CODIGOPEDIDO REFERENCES PEDIDOANULADO(codigo));


CREATE TABLE LINEAENREALIZACION (
  CODIGO               varchar2 (13) CONSTRAINT PK_LINEAENREALIZACION PRIMARY KEY,
  CODIGOARTICULO       VARCHAR2 (10) NOT NULL CONSTRAINT FK_LIN_ENREALIZ_COD_ARTIC REFERENCES ARTICULO(codigo),
  CANTIDAD             NUMBER (2)    NOT NULL CHECK (cantidad >=0),
  PRECIO               NUMBER (10,2) NOT NULL,
  FECHAENTREGADESEADA  DATE,
  CODIGOPEDIDO         VARCHAR2 (10) NOT NULL CONSTRAINT FK_LIN_ENREALIZ_COD_PEDIDO REFERENCES PEDIDOENREALIZACION(codigo));


CREATE TABLE NUMDOC (
  ANIO  NUMBER(4)    CONSTRAINT PK_NUMDOC PRIMARY KEY,
  NUM   NUMBER(10)   NOT NULL);


CREATE TABLE REPOSICION (
  CODIGO          VARCHAR2 (10) CONSTRAINT PK_REPOSICION PRIMARY KEY,
  CODIGOARTICULO  VARCHAR2 (10) NOT NULL CONSTRAINT FK_REPOSICION_CODIGOARTICULO REFERENCES ARTICULO(codigo),
  CODIGOALMACEN   VARCHAR2 (10) NOT NULL CONSTRAINT FK_REPOSICION_CODIGOALMACEN  REFERENCES ALMACEN(codigo),
  CANTIDAD        NUMBER (2)    NOT NULL CONSTRAINT CHK_REPOSICION_CANTIDAD CHECK (cantidad >=0),
  FECHAENTRADA    DATE          NOT NULL);


CREATE TABLE STOCK (
  CODIGO          VARCHAR2 (10) CONSTRAINT PK_STOCK PRIMARY KEY,
  CODIGOARTICULO  VARCHAR2 (10) NOT NULL CONSTRAINT FK_STOCK_CODIGOARTICULO REFERENCES ARTICULO(codigo),
  CODIGOALMACEN   VARCHAR2 (10) NOT NULL CONSTRAINT FK_STOCK_CODIGOALMACEN REFERENCES ALMACEN(codigo),
  CANTIDAD        NUMBER (2)    NOT NULL CONSTRAINT CHK_STOCK_CANTIDAD CHECK (cantidad >=0));


create table Oferta (
  codigoArticulo VARCHAR2(10) NOT NULL CONSTRAINT UNQ_OFERTA_CODIGOARTICULO UNIQUE,
  descuento NUMBER(5,2) NOT NULL,
  CONSTRAINT FK_OFERTAS_CODIGOARTICULO FOREIGN KEY (codigoArticulo) REFERENCES ARTICULO(codigo));


create table Oferta3x2 (
  codigoArticulo VARCHAR2(10) NOT NULL CONSTRAINT UNQ_Oferta3x2_CODIGOARTICULO UNIQUE,
  aComprar NUMBER(3) NOT NULL,
  aPagar NUMBER(3) NOT NULL,
  CONSTRAINT FK_Oferta3x2_CODIGOARTICULO FOREIGN KEY (codigoArticulo) REFERENCES ARTICULO(codigo));


create table ClientePreferente (
  codigoCliente VARCHAR2(10) NOT NULL CONSTRAINT UNQ_ClientePreferente_CODCLI UNIQUE,
  descuento NUMBER(5,2) NOT NULL,
  incrFact NUMBER(5,2),
  CONSTRAINT FK_ClientePreferente_CODCLI FOREIGN KEY(codigoCliente) REFERENCES Cliente(codigo));


CREATE TABLE ReservaStock (
	codigoLinea	VARCHAR2(13) NOT NULL,
	codigoStock	VARCHAR2(10) NOT NULL,
	cantidad	NUMBER(2) NOT NULL,
	CONSTRAINT PK_ReservaStock PRIMARY KEY (codigoLinea, codigoStock),
	CONSTRAINT FK_ReservaStock_codigoLinea FOREIGN KEY (codigoLinea) REFERENCES Linea(codigo) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT FK_ReservaStock_codigoStock FOREIGN KEY (codigoStock) REFERENCES Stock(codigo));

CREATE TABLE ReservaReposicion (
	codigoLinea	VARCHAR2(13) NOT NULL,
	codigoReposicion	VARCHAR2(10) NOT NULL,
	cantidad	NUMBER(2) NOT NULL,
	CONSTRAINT PK_ReservaRepo PRIMARY KEY (codigoLinea, codigoReposicion),
	CONSTRAINT FK_ReservaRepo_linea FOREIGN KEY (codigoLinea) REFERENCES Linea(codigo) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT FK_ReservaRepo_reposicion FOREIGN KEY (codigoReposicion) REFERENCES Reposicion(codigo));


CREATE TABLE TransitoMercancia (
  almacenOrigen   VARCHAR2 (10) NOT NULL,
  almacenDestino  VARCHAR2 (10) NOT NULL,
  fechaSalida     DATE  NOT NULL,
  codigoLinea     VARCHAR2 (13)  NOT NULL,
  cantidad        NUMBER  NOT NULL,
  codigoArticulo  VARCHAR2 (10) NOT NULL,
  CONSTRAINT fk_Transito_origen FOREIGN KEY (almacenOrigen) REFERENCES Almacen (codigo),
  CONSTRAINT fk_Transito_destino FOREIGN KEY (almacenDestino) REFERENCES Almacen (codigo),
  CONSTRAINT fk_Transito_linea FOREIGN KEY (codigoLinea) REFERENCES Linea (codigo) DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_Transito_articulo FOREIGN KEY (codigoArticulo) REFERENCES Articulo (codigo));


create or replace java source named "PrecioArticuloSrc" as
import java.sql.*;
import java.util.*;

public class PrecioArticulo {
	// Para su uso con el driver JDBC interno
	private static String url = "jdbc:default:connection:";

	public static double getPrecioArticulosEnOferta(String codigoArticulo, int cantidad) throws SQLException {
	  Connection con = null;
	  con = DriverManager.getConnection(url);

	  // Primer paso. Cálculo del precio por artículo (con o sin descuento)

	  String sql1 = "select PVP*(100-nvl(descuento,0))/100 from articulo " +
			"left outer join oferta on articulo.CODIGO = oferta.CODIGOARTICULO where " +
			"codigo = '" + codigoArticulo + "'";
	  //Almacenará el precio por artículo (con o sin descuento)
	  double precioOfertaDescuento = 0;

	  Statement get1 = con.createStatement();
	  ResultSet res1 = get1.executeQuery(sql1);
	  if (res1.next()) {
		precioOfertaDescuento = res1.getDouble(1);
	  }
	  res1.close();
       get1.close();


	  //Segundo paso, calculamos el número de artículos a pagar.

	  String sql2 = "select aComprar, aPagar from oferta3x2 where codigoArticulo = '"+codigoArticulo+"'";
	  double precioTotal = 0;
	  int aComprar;
	  int aPagar;
	  int lotes;
	  int totalArticulosAPagar;
		
	  Statement get2 = con.createStatement();
	  ResultSet res2 = get2.executeQuery(sql2);
	  if (res2.next()) {
		aComprar = res2.getInt("aComprar");
		aPagar = res2.getInt("aPagar");
		lotes = cantidad / aComprar;
		totalArticulosAPagar = lotes*aPagar + cantidad % aComprar;
        } else {
		totalArticulosAPagar = cantidad;
	  }
	  //último paso. Calculamos el precio total, teniendo en cuenta el número de artículos
       // a pagar (marcado por la oferta 3x2) y el precio de los mismos (marcado por la 
       //oferta de descuento)
		precioTotal=totalArticulosAPagar * precioOfertaDescuento;
		res2.close();
		get2.close();
		return precioTotal;
	}
};

create or replace function PrecioArticulo(codigoArticulo VARCHAR2, cantidad NUMBER) return NUMBER as
language java name
'PrecioArticulo.getPrecioArticulosEnOferta (java.lang.String, int) return double';

SQL
