package net.set.server;

import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Properties;

import net.set.database.DatabaseConnection;
import net.set.game.GameLogic;
import net.set.game.GameManager;
import net.set.game.Lobby;

public class WorldServer {
	public static Lobby ly;
	public static ClientManager cm;
	public static WorldServer ws;
	public static GameManager gm;
	
	private Properties dbProp = new Properties();
	private ServerSocket sSocket;
	private boolean ServerOn = true;
	
	private void InitializeClasses(){
		cm = new ClientManager();
		ly = new Lobby();
		gm = new GameManager();
		new GameLogic();
	}
	
	private WorldServer(){
		try{
			InputStreamReader is = new FileReader("db.properties");
			dbProp.load(is);
			is.close();
			DatabaseConnection.setProperties(dbProp);
			if (DatabaseConnection.getConnection() == null)
				System.exit(-1);
		}catch (Exception e){
			System.out.println("WorldServer: Unable to load database configuration...");
			System.exit(-1);
		}
		InitializeClasses();
		try{
			sSocket = new ServerSocket(8888);
        }catch(IOException e){
        	System.out.println("WorldServer: Unable to start server on port 8888...");
        	System.exit(-1);
        }
		System.out.println("WorldServer: Server started on port 8888!");
		while(ServerOn){
			try{
				Socket newClient = sSocket.accept();
				cm.AddClient(newClient);
				System.out.println("WorldServer: Client accepted!");
			}catch(Exception e){
				System.out.println("WorldServer: Accept failed...");
			}
		}
		try{
			sSocket.close();
		}catch(Exception e){
			System.out.println("WorldServer: Failed to stop server...");
		}
		System.exit(0);
	}
	
	public void Shutdown(){
		ServerOn = false;
	}
	
	public static void main(String[] args) {
		ws = new WorldServer();
	}

}
