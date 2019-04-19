package test.java.main;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;

import org.dbunit.Assertion;
import org.dbunit.dataset.IDataSet;
import org.dbunit.dataset.ITable;
import org.dbunit.dataset.ReplacementTable;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import main.java.model.ExcepcionDeAplicacion;
import main.java.model.PedidoEnRealizacion;
import sol.GestorBD;
import util.TestsUtil;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestsPr9b extends TestsUtil {
	private static final double DELTA = 1e-15;
	@BeforeClass
	public static void creacionGestorBD() {
		gbd = new GestorBD();
		url = GestorBD.getPropiedad("url");
		user = GestorBD.getPropiedad("user");
		password = GestorBD.getPropiedad("password");
		schema = GestorBD.getPropiedad("schema");
		
	}

	// Antes de ejecutar cada test, eliminamos el estado previo de la BD, eliminando
	// los registros insertados en el test previo y cargando los datos requeridos
	// para dicho test.
	@Before
	public void importDataSet() throws Exception {
		IDataSet dataSet = readDataSet();
		cleanlyInsertDataset(dataSet);
	}
	@Test
	public void testGetPrecioOferta() {

			try {
				// Obtenemos el precio de 3 unidades del articulo con codigo "Ede/435PA"
				double precioOferta= gbd.getPrecioOferta("Ede/435PA", 3);
				// Comprobamos que coincide con el numero esperado
				assertEquals("Falla al comprobar el precio", precioOferta, 780.0, DELTA);
			} catch (ExcepcionDeAplicacion e) {
				e.printStackTrace();
			}
		}


}
