package sol;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Properties;

import main.java.bd.AbstractDBManager;
import main.java.bd.ConnectionManager;
import main.java.bd.ConstantesConexion;
import main.java.debug.Debug;
import main.java.model.ExcepcionDeAplicacion;
import main.java.model.PedidoEnRealizacion;

public class GestorBD extends AbstractDBManager {
	private static final String URL = getPropiedad("url");;
	private static final String USR = getPropiedad("user");
	private static final String PWD = getPropiedad("password");


  public static String getPropiedad(String clave){
		 String valor=null;
	    try {
	      Properties props = new Properties();
	      props.load(new FileInputStream("src/conexion.properties"));
	   
	       valor= props.getProperty(clave);
	      
	    } catch (IOException ex) {
	      ex.printStackTrace();
	    }
	    return valor;
	    }
  public boolean isFestivo(Calendar fecha) throws ExcepcionDeAplicacion {
    Debug.prec(fecha, "Me has enviado una fecha nulo");
    boolean festivo = false;
    Connection con = null;
    try {
      con = ConnectionManager.getConnection();
//      java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd");
//      String sql = "SELECT * FROM Festivo WHERE fecha ={d '"+df.format(fecha.getTime())+"'}";
//      Statement ps = con.createStatement();
//
//      ResultSet res = ps.executeQuery(sql);

      String sql = "SELECT * FROM Festivo WHERE fecha =?";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setDate(1, new java.sql.Date(fecha.getTime().getTime()));
      ResultSet res = ps.executeQuery();
      if (res.next()) {
        festivo = true;

      }
      res.close();
      ps.close();
    } catch (SQLException ex) {
      throw new ExcepcionDeAplicacion(ex);
    } finally {
      if (con != null) {
        try {
          ConnectionManager.returnConnection(con);
        } catch (SQLException ex1) {
          ex1.printStackTrace();
        }
      }
    }

    return festivo;
  }

  protected List<String> buscaArticulos(List criterios, String conjuncion) throws ExcepcionDeAplicacion {
    Debug.prec(criterios, "Me debes dar una lista de criterios");
    conjuncion = conjuncion != null && conjuncion.trim().length() > 0 ? conjuncion : "and";
    conjuncion = conjuncion.trim().toLowerCase();
    Debug.prec(conjuncion.equals("or") || conjuncion.equals("and"), "Debe ser and u or");
    String condicion = "";
    for (int i = 0; i < criterios.size() - 1; i++) {
      String crit = ( (String) criterios.get(i)).toUpperCase();
      if (ConstantesConexion.URL.indexOf("jdbc:oracle") != -1) { // Es oracle
        condicion += "upper(nombre) like '%" + crit + "%' " + conjuncion + " ";
      } else {
        condicion += "nombre like '%" + crit + "%' " + conjuncion + " ";
      }
    }
    if (criterios.size() > 0) {
      String crit = ( (String) criterios.get(criterios.size() - 1)).toUpperCase();
      if (ConstantesConexion.URL.indexOf("jdbc:oracle") != -1) { // Es oracle
        condicion += "upper(nombre) like '%" + crit + "%'";
      } else {
        condicion += "nombre like '%" + crit + "%'";
      }
    }

    List contenido = new ArrayList();
    String sql = "select codigo from articulo ";
    if (criterios.size() > 0) {
      sql += "where " + condicion + " ";
    }
    sql += "order by nombre";
    Debug.trace(sql);
    Statement stm = null;

    try {
      stm = ConnectionManager.getStatement();

      ResultSet rs = stm.executeQuery(sql);
      while (rs.next()) {
        contenido.add(rs.getString("codigo"));
      }
      return contenido;
    } catch (SQLException ex) {
      throw new ExcepcionDeAplicacion(ex);
    } finally {
      if (stm != null) {
        try {
          ConnectionManager.closeStatement(stm);
        } catch (SQLException ex1) {
          ex1.printStackTrace();
        }
      }
    }

  }

//  public Almacen getAlmacenDeCP(String CP) throws ExcepcionDeAplicacion {
//    Debug.prec(CP, "Me has enviado un código postal nulo");
//    Almacen almacen = null;
//    Statement stm = null;
//    try {
//      stm = ConnectionManager.getStatement();
//      String sql = "select almacen.* " +
//          "from almacen, codigoPostal " +
//          "where almacen.zona = codigoPostal.zona " +
//          "      and '" + CP + "' between CPMIN and CPMAX";
//
//      ResultSet res = stm.executeQuery(sql);
//      if (res.next()) {
//        almacen = new Almacen(res.getString(1), res.getString(2), res.getString(3), res.getString(4),
//                              res.getInt(5));
//      }
//      res.close();
//    } catch (SQLException ex) {
//      throw new ExcepcionDeAplicacion(ex);
//    } finally {
//      if (stm != null) {
//        try {
//          ConnectionManager.closeStatement(stm);
//        } catch (SQLException ex1) {
//          ex1.printStackTrace();
//        }
//      }
//    }
//
//    return almacen;
//  }

  public double getPrecioOferta(String codigoArticulo, int cantidad) throws ExcepcionDeAplicacion {
    double precioLinea = 0;
    Connection con = null;
    try {
      con = ConnectionManager.getConnection();
      CallableStatement call = con.prepareCall("{?=call PrecioArticulo(?,?)}");
      call.registerOutParameter(1, Types.DOUBLE);
      call.setString(2, codigoArticulo);
      call.setInt(3, cantidad);

      call.execute();

      precioLinea = call.getDouble(1);

      call.close();
    } catch (SQLException ex) {
      ex.printStackTrace();
      throw new ExcepcionDeAplicacion("Error invocando PrecioArticulo", ex);
    } finally {
      if (con != null) {
        try {
          ConnectionManager.returnConnection(con);
        } catch (SQLException ex1) {
          ex1.printStackTrace();
          throw new ExcepcionDeAplicacion("Error cerrando conexion", ex1);
        }
      }
    }
    return precioLinea;

  }

  public synchronized String getNumeroDoc(int anio) throws ExcepcionDeAplicacion {
    int numero = -1;
    Connection con = null;
    try {
      con = ConnectionManager.getConnection();
      CallableStatement call = con.prepareCall("{call GetNumDocumento(?,?)}");
      call.setInt(1, anio);
      call.registerOutParameter(2, Types.INTEGER);

      call.execute();

      numero = call.getInt(2);

      call.close();
    } catch (SQLException ex) {
      ex.printStackTrace();
      throw new ExcepcionDeAplicacion("Error invocando getNumDocumento", ex);
    } finally {
      if (con != null) {
        try {
          ConnectionManager.returnConnection(con);
        } catch (SQLException ex1) {
          ex1.printStackTrace();
          throw new ExcepcionDeAplicacion("Error cerrando conexion", ex1);
        }
      }
    }

    if (numero < 10) {
      return "00000" + numero;
    } else if (numero < 100) {
      return "0000" + numero;
    } else if (numero < 1000) {
      return "000" + numero;
    } else if (numero < 10000) {
      return "00" + numero;
    } else if (numero < 100000) {
      return "0" + numero;
    } else {
      return "" + numero;
    }
  }

//  public double getPrecioLineaCliente(String codigoArticulo, int cantidad,
//                                      String codigoCliente) throws ExcepcionDeAplicacion {
//    return 0;
//  }


  public static void main(String[] args) throws Exception{
    try {
      final GestorBD gbd = new GestorBD();
      System.out.println(gbd.getPrecioOferta("Ede/435PA", 1));
      System.out.println(gbd.getNumeroDoc(2007));
    } catch (ExcepcionDeAplicacion ex) {
      ex.printStackTrace();
    }
  }








//  public static void main(String[] args) throws Exception{
//    try {
//      final PrintStream dos = new PrintStream(new FileOutputStream("C:/tmp/numDoc.txt"));
//      final GestorBD gbd = new GestorBD();
//      System.out.println(gbd.getPrecioOferta("Ede/435PA", 1));
//      System.out.println(gbd.getNumeroDoc(2013));
//      for (int i = 0; i < 10; i++) {
//        final int k = i;
//        new Thread() {
//          public void run() {
//            for (int j = 0; j < 10000; j++) {
//              try {
////                System.out.println(this.getName()+" "+gbd.getNumeroDoc(2002));
//                dos.println(this.getName()+" "+gbd.getNumeroDoc(2009));
//              } catch (ExcepcionDeAplicacion ex) {
//                System.err.println(this.getName()+" ("+k+"-"+j+") "+ex);
//              }
//            }
//          }
//        }.start();
//      }
//    } catch (ExcepcionDeAplicacion ex) {
//      ex.printStackTrace();
//    }
//  }
}
