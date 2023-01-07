/*
 * PROGRAMA PRINCIPAL PARA LA REALIZACION Y BUSQUEDA DE LAS CONSULTAS DEL PROYECTO
 */
package Principal;

import SQL.Conexion1;
import SQL.Conexion2;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.InputMismatchException;
import java.util.Scanner;

/**
 *
 * @author Equipo7BDD
 */
public class Inicio{
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args)throws Exception {
    //Comenzamos con un menu para realizar las diferentes consultas
    Scanner sn=new Scanner(System.in);
    boolean salir = false;
    int op;
    while(!salir){
    System.out.println("------------MENU------------");
    System.out.println("1.-Total de Ventas de producto");
    System.out.println("2.-Consultar producto mas solicitado para norteamerica");
    System.out.println("3.-Actualizar Stock por categoria un 5%");
    System.out.println("4.-Determinacion de clientes en otras regiones");
    System.out.println("5.-Actualizar cantidad de productos por orden");
    System.out.println("6.-Actualizar Metodo de envio de una orden");
    System.out.println("7.-Actualizar correo electronico de cliente");
    System.out.println("8.-Salir");
    try{
        System.out.println("Escoga una opcion");
        op=sn.nextInt();
        switch(op){
        case 1:
            System.out.println("---Total de Ventas de producto---");
            //Conexion1 con1 = new Conexion1();
            //Para las conexiones con las demas instancias tomando asi los procedimientos almacenados
            Conexion2 con2 = new Conexion2();
            int cat;
            Scanner sn2=new Scanner(System.in);
            try{
                System.out.println("\nIntroduzca la Categoria del producto:");
                cat=sn2.nextInt();//Agregamos el valor para la consulta
                con2.Conectar();//Nos conectamos a la instancia
                System.out.println(con2.consulta1(cat));//Imprimos la consulta la procedimiento almacenado con la categoria agregada
                con2.Desconectar();//Nos desconectamos de la base de datos   
            }catch(SQLException ex){
                System.out.println(ex.toString());
            }
            break;
        case 2:
            System.out.println("---Consultar producto mas solicitado para norteamerica---");
            Conexion2 con1_2 = new Conexion2();
            try{
                con1_2.Conectar();//Nos conectamos a la instancia
                System.out.println(con1_2.consulta2());//Imprimos la consulta la procedimiento almacenado con la categoria agregada
                con1_2.Desconectar();//Nos desconectamos de la base de datos   
            }catch(SQLException ex){
                System.out.println(ex.toString());
            }
            break;
        case 3:
            System.out.println("---Actualizar Stock por categoria un 5%---");
            
            int cat2,ID;
            Scanner sn3=new Scanner(System.in);
            Conexion2 con1_3 = new Conexion2();
            try{
                System.out.println("\nIntroduzca la Categoria del producto:");
                cat2=sn3.nextInt();
                System.out.println("\nIntroduzca la locacion ID:");
                ID=sn3.nextInt();
                con1_3.Conectar();
                System.out.println(con1_3.consulta3(cat2, ID));
                con1_3.Desconectar();
            }catch(SQLException ex){
                System.out.println(ex.toString());
            }
            break;
        case 4:
            System.out.println("---Determinacion de clientes en otras regiones---");
            Conexion2 con1_4 = new Conexion2();
            try{
                 con1_4.Conectar();//Nos conectamos a la instancia
                System.out.println(con1_4.consulta4());//Imprimos la consulta la procedimiento almacenado con la categoria agregada
                con1_4.Desconectar();//Nos desconectamos de la base de datos   
            }catch(SQLException ex){
                System.out.println(ex.toString());
            }
            break;
        case 5:
            System.out.println("---Actualizar cantidad de productos por orden---");
            int ID2,PID,cant;
            Scanner sn4=new Scanner(System.in);
            Conexion2 con1_5 = new Conexion2();
            try{
                System.out.println("\nIntroduzca el ID:");
                ID2=sn4.nextInt();
                System.out.println("\nIntroduzca el ID del producto:");
                PID=sn4.nextInt();
                System.out.println("\nIntroduzca la cantidad:");
                cant=sn4.nextInt();
                con1_5.Conectar();//Nos conectamos a la instancia
                System.out.println(con1_5.consulta5(ID2,PID,cant));//Imprimos la consulta la procedimiento almacenado con la categoria agregada
                con1_5.Desconectar();//Nos desconectamos de la base de datos   
            }catch(SQLException ex){
                System.out.println(ex.toString());
            }
            break;
        case 6:
            System.out.println("---Actualizar Metodo de envio de una orden---");
            int ID3,dir;
            Scanner sn5=new Scanner(System.in);
            Conexion2 con1_6 = new Conexion2();
            try{
                System.out.println("\nIntroduzca el ID:");
                ID3=sn5.nextInt();
                System.out.println("\nIntroduzca el ID del metodo de envio nuevo:");
                dir=sn5.nextInt();
                con1_6.Conectar();//Nos conectamos a la instancia
                System.out.println(con1_6.consulta6(ID3,dir));//Imprimos la consulta la procedimiento almacenado con la categoria agregada
                con1_6.Desconectar();//Nos desconectamos de la base de datos   
            }catch(SQLException ex){
                System.out.println(ex.toString());
            }
            break;
        case 7:
            System.out.println("---Actualizar correo electronico de cliente---");
            int IDP;
            String email;
            Scanner sn6=new Scanner(System.in);
            Conexion2 con1_7 = new Conexion2();
            try{
                System.out.println("\nIntroduzca el ID de la persona:");
                IDP=sn6.nextInt();
                System.out.println("\nIntroduzca el nuevo email:");
                email=sn6.next();
                con1_7.Conectar();//Nos conectamos a la instancia
                System.out.println(con1_7.consulta7(IDP,email));//Imprimos la consulta la procedimiento almacenado con la categoria agregada
                con1_7.Desconectar();//Nos desconectamos de la base de datos   
            }catch(SQLException ex){
                System.out.println(ex.toString());
            }
            break;
        case 8:
            salir=true;
            break;
        default:
            System.out.println("Solo numeros de 1 a 8");
        }
    }catch(InputMismatchException e){
        System.out.println("Debe de insertar un numero");
        sn.next();
    }   
}
}
}
