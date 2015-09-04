package net.set.game;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import net.set.database.DatabaseConnection;
import net.set.packet.PacketFactory;
import net.set.server.Client;
import net.set.server.WorldServer;

public class Player {
	public GameState state = GameState.GS_LOGIN;
	
	public int uid;
	public String username;
	public int wins;
	public int score;
	
	public GameLobby gamelobby; //Assigned ONLY if game_state = GS_ROOM
	public Game game; //Assigned ONLY if game_state = GS_INGAME
	private Client client;
	
	public enum GameState {GS_LOGIN, GS_LOBBY, GS_ROOM, GS_INGAME};
	
	public Player(Client c){
		client = c;
		gamelobby = null;
		game = null;
	}
	
	public boolean Login(String username, String password) {
		//Invalid State
		if (state != GameState.GS_LOGIN)
			return false;
		//Alphanumeric Only
		if (!username.matches("[A-Za-z0-9]+"))
			return false;
		Connection con = DatabaseConnection.getConnection();
		try{
			PreparedStatement ps = con.prepareStatement("SELECT id,wins FROM `users` WHERE `username` = ? AND `password` = SHA1(?)");
			ps.setString(1, username);
			ps.setString(2, password);
			ResultSet rs = ps.executeQuery();
			if (rs.next()){
				if (WorldServer.cm.GetClient(rs.getInt("id")) != null)
					return false;
				this.username = username;
				uid = rs.getInt("id");
				wins = rs.getInt("wins");
				score = 0;
				JoinLobby();
				return true;
			}else{
				return false;
			}
		}catch(SQLException e){
			return false;
		}
	}
	
	public boolean Register(String username, String password) {
		//Invalid State
		if (state != GameState.GS_LOGIN)
			return false;
		//Alphanumeric Only
		if (!username.matches("[A-Za-z0-9]+"))
			return false;
		if(username.length() >= 30)
			return false;
		Connection con = DatabaseConnection.getConnection();
		try{
			PreparedStatement ps = con.prepareStatement("SELECT id,wins FROM `users` WHERE `username` = ? AND `password` = SHA1(?)");
			ps = con.prepareStatement("SELECT id FROM `users` WHERE `username` = ?");
			ps.setString(1, username);
			ResultSet rs = ps.executeQuery();
			//Account already exists
			if (rs.next())
				return false;
			ps = con.prepareStatement("INSERT INTO `users` VALUES (0,?,SHA1(?),0)");
			ps.setString(1, username);
			ps.setString(2, password);
			ps.execute();
			return true;
		}catch(SQLException e){
			return false;
		}
	}
	
	public void Save() {
		Connection con = DatabaseConnection.getConnection();
		try{
			PreparedStatement ps = con.prepareStatement("UPDATE `users` SET wins = ? WHERE id = ?");
			ps.setInt(1, wins);
			ps.setInt(2, uid);
			ps.execute();
		}catch(SQLException e){
			System.out.println(e.getLocalizedMessage());
		}
	}
	
	public void Chat(String message) {
		if (state == GameState.GS_LOBBY) {
			WorldServer.ly.BroadcastChat(client, message);
		}
		if (state == GameState.GS_ROOM) {
			gamelobby.BroadcastChat(client, message);
		}
	}
	
	public void JoinLobby() {
		WorldServer.ly.AddPlayer(client);
		state = GameState.GS_LOBBY;
		game = null;
		gamelobby = null;
	}
	
	public boolean CreateGame(String name) {
		if (state != GameState.GS_LOBBY)
			return false;
		if (!WorldServer.ly.AddGame(client, name))
			return false;
		JoinGameLobby(uid);
		return true;
	}
	
	public boolean JoinGameLobby(int hostuid) {
		gamelobby = WorldServer.ly.GetGame(hostuid);
		if (gamelobby != null) {
			WorldServer.ly.DeletePlayer(client);
			gamelobby.AddPlayer(client);
			state = GameState.GS_ROOM;
			return true;
		} else {
			return false;
		}
	}
	
	public void QuitGameLobby() {
		if (gamelobby != null) {
			gamelobby.DeletePlayer(client);
			if (gamelobby.hostuid == uid)
				WorldServer.ly.DeleteGame(uid);
			gamelobby = null;
		}
	}
	
	public boolean JoinGame(int hostuid) {
		game = WorldServer.gm.GetGame(hostuid);
		gamelobby = null;
		if (game != null) {
			score = 0;
			game.AddPlayer(client);
			state = GameState.GS_INGAME;
			return true;
		} else {
			return false;
		}
	}
	
	public void QuitGame() {
		if (game != null) {
			game.DeletePlayer(client);
			if (game.hostuid == uid)
				WorldServer.gm.DeleteGame(uid);
			game = null;
		}
	}
	
	public void ProcessSet(byte c1, byte c2, byte c3) {
		synchronized (game.cardlist) {
			int upper = game.cardlist.size();
			if (c1 >= upper || c2 >= upper || c3 >= upper)
				return;
			byte cc1 = game.cardlist.get(c1);
			byte cc2 = game.cardlist.get(c2);
			byte cc3 = game.cardlist.get(c3);
			if (GameLogic.Set(cc1, cc2, cc3)) {
				if (GameLogic.SetExistsIgnore(game, cc1,cc2,cc3) && game.cardlist.size() > 15) {
					game.ReplaceCard(cc1, true);
					game.ReplaceCard(cc2, true);
					game.ReplaceCard(cc3, true);
				} else {
					game.ReplaceCard(cc1, false);
					game.ReplaceCard(cc2, false);
					game.ReplaceCard(cc3, false);
				}
				score += 3;
				game.BroadcastPacket(PacketFactory.GameEventSetOther());
				client.SendPacket(PacketFactory.GameEventSetYou());
			} else {
				score -= 1;
			}
		}
	}
}