package main;

import static org.junit.Assert.assertEquals;

import org.dbunit.dataset.IDataSet;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

import main.java.model.ExcepcionDeAplicacion;
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
