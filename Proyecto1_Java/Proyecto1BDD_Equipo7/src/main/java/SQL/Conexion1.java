/*
 * Clase de conexion, ejecucion de procedimientos almacenados y desconexion para una sola instancia sin distribuir
 */
package SQL;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;


/**
 *
 * @author Equipo7BDD
 */
public class Conexion1 {
    Connection conexion;
    String BD_URL = "jdbc:sqlserver://aworksbdd.database.windows.net:1434;"
                    +"database=AW_Sales;"
                    +"user=awroksbdd;"
                    +"password=Gearsofwar&3;"
                    +"loginTimeout=30;";
    CallableStatement statement = null;
    ResultSet result = null;
    
    public void Conectar(){
    try{
        conexion=DriverManager.getConnection(BD_URL);
    } catch(SQLException ex){
        System.out.println(ex.toString());
        
    }
    }
    
    public String consulta1(int cat) throws SQLException{
        String res="";
        try{
        //Llamamos al procedimiento almacenado
        statement = conexion.prepareCall("{call sp_Ejercicioa(?)}");
        //Agregamos los parametros al procedimiento y ejecutamos
        statement.setInt(1,cat);
        statement.execute();   
        //Obtenemos los resultados 
        result = statement.getResultSet();
        while(result.next()){
            res+=result.getRow()+" Total Ventas:"+result.getString(1)+" Territorio:"+result.getString(2)+" IDTerritorio:"+result.getString(3)+"\n";
        }
    }catch (SQLException ex){
            System.out.println(ex.toString());
    
    }
        return res;
    }
    
    public String consulta2() throws SQLException{
    String res="";//Variable para el resultado
    try{
        //Llamamos al procedimiento almacenado
        statement = conexion.prepareCall("{call sp_Ejerciciob}");
        //Ejecutamos la consulta
        statement.execute();   
        //Obtenemos los resultados 
        result = statement.getResultSet();
        while(result.next()){
            res+=result.getRow()+" Producto:"+result.getString(1)+" Solicitudes:"+result.getString(2)+" Region:"+result.getString(3)+"\n";
        }
    }catch(SQLException ex){
        System.out.println(ex.toString());
    }
    return res;
    }
    
    public String consulta3(int cat,int ID) throws SQLException{
    String res="";//Variable para el resultado
    try{
        //Llamamos al procedimiento almacenado
        statement = conexion.prepareCall("{call sp_Ejercicioc(?,?)}");
        //Agregamos los parametros del procedimiento
        statement.setInt(1, cat);
        statement.setInt(2,ID);
        //Ejecutamos la consulta
        statement.execute();   
        //Obtenemos los resultados 
        res="Stock Actualizado!";
    }catch(SQLException ex){
        System.out.println(ex.toString());
    }
    return res;
    }
    
    public String consulta4() throws SQLException{
    String res="";//Variable para el resultado
    try{
        //Llamamos al procedimiento almacenado
        statement = conexion.prepareCall("{call sp_Ejerciciod}");
        //Ejecutamos la consulta
        statement.execute();   
        //Obtenemos los resultados 
        result = statement.getResultSet();
        while(result.next()){
            res+=result.getRow()+" ID: "+result.getString(1)+" TeritorioPedido:"+result.getString(2)+" TerritorioMandado:"+result.getString(3)+"\n";
        }
    }catch(SQLException ex){
        System.out.println(ex.toString());
    }
    return res;
    }
     
    public String consulta5(int ID, int PID, int cant) throws SQLException{
    String res="";//Variable para el resultado
    try{
        //Llamamos al procedimiento almacenado
        statement = conexion.prepareCall("{call sp_Ejercicioe(?,?,?)}");
        //Agregamos los parametros del procedimiento
        statement.setInt(1, ID);
        statement.setInt(2,PID);
        statement.setInt(3,cant);
        //Ejecutamos la consulta
        statement.execute();   
        //Obtenemos los resultados 
        res="Cantidad Actualizada";
    }catch(SQLException ex){
        System.out.println(ex.toString());
    }
    return res;
    }
    
    public String consulta6(int ID, int dir) throws SQLException{
    String res="";//Variable para el resultado
    try{
        //Llamamos al procedimiento almacenado
        statement = conexion.prepareCall("{call sp_Ejerciciof(?,?)}");
        //Agregamos los parametros del procedimiento
        statement.setInt(1, ID);
        statement.setInt(2,dir);
        //Ejecutamos la consulta
        statement.execute();   
        //Obtenemos los resultados 
        res="Metodo Actualizado!";
    }catch(SQLException ex){
        System.out.println(ex.toString());
    }
    return res;
    }
    
    public String consulta7(int IDP, String email) throws SQLException{
    String res="";//Variable para el resultado
    try{
        //Llamamos al procedimiento almacenado
        statement = conexion.prepareCall("{call sp_Ejerciciog(?,?)}");
        //Agregamos los parametros del procedimiento
        statement.setInt(1, IDP);
        statement.setString(2,email);
        //Ejecutamos la consulta
        statement.execute();   
        //Obtenemos los resultados 
        res="Email Actualizado!";
    }catch(SQLException ex){
        System.out.println(ex.toString());
    }
    return res;
    }
    
    public void Desconectar(){
        try{
            if(result==null){
                statement.close();
                conexion.close();
            }else{
                result.close();
                statement.close();
                conexion.close();
            }
        
        }catch(SQLException ex){
           System.out.println(ex.toString());
        }
    }
    
}

