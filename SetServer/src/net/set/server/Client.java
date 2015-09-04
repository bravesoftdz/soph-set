package net.set.server;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.Iterator;

import net.set.packet.PacketFactory;
import net.set.packet.PacketReader;
import net.set.packet.PacketWriter;
import net.set.game.GameLobby;
import net.set.game.GameLogic;
import net.set.game.Player;
import net.set.game.Player.GameState;

public class Client extends Thread {
	private Socket clientsocket;
	private DataOutputStream outstream;
	private boolean terminated = false;
	
	private Player player;
	
	private long pingpong_timer = 0;
	private long lobbyupdate_timer = 0;
	
	public Client(Socket cs) {
		super();
		player = new Player(this);
		clientsocket = cs;
	}
	
	public void Close() {
		terminated = true;
	}
	
	public int GetUID() {
		return player.uid;
	}
	
	public String GetUsername() {
		return player.username;
	}
	
	public int GetScore() {
		return player.score;
	}
	
	public void IncreaseWins() {
		player.wins++;
	}
	
	public void Save() {
		player.Save();
	}
	
	public void JoinGame() {
		player.JoinGame(player.gamelobby.hostuid);
		SendPacket(PacketFactory.InterfaceGame());
	}
	
	public void JoinLobby() {
		player.JoinLobby();
		SendPacket(PacketFactory.InterfaceLobby());
	}
	
	public void KickFromGame() {
		player.QuitGame();
		player.JoinLobby();
		SendPacket(PacketFactory.InterfaceLobby());
		lobbyupdate_timer = 0;
	}
	
	public void KickFromGameLobby() {
		player.QuitGameLobby();
		player.JoinLobby();
		SendPacket(PacketFactory.InterfaceLobby());
		lobbyupdate_timer = 0;
	}
	
	public synchronized void SendPacket(PacketWriter p) {
		ByteArrayOutputStream ps = p.getStream();
		try {
			// [Short: Size] [Short: Header] [Data: Packet]
			outstream.write((byte) (ps.size() & 0xFF));
			outstream.write((byte) ((ps.size() >>> 8) & 0xFF));
			outstream.write(ps.toByteArray());
			outstream.flush();
		} catch(IOException e) {
			Close();
		}
	}
	
	private void ParsePacket(PacketReader p) {
		short header = p.ReadShort();
		
		switch(header) {
		case 0x00: //Login
			int isReg = p.ReadByte();
			String username = p.ReadAnsiString();
			String password = p.ReadAnsiString();
			if (isReg == 0) {
				if (player.Login(username, password)) {
					SendPacket(PacketFactory.InterfaceLobby());
					lobbyupdate_timer = 0;
					SendPacket(PacketFactory.PlayerInfo(player.uid, player.wins, player.score, player.username));
				} else {
					SendPacket(PacketFactory.MessageBox("Invalid username/password or already logged in. Please try again later."));
				}
			} else {
				if (player.Register(username,password))
					SendPacket(PacketFactory.MessageBox("Account registered! Please login to continue."));
				else
					SendPacket(PacketFactory.MessageBox("Failed to register..."));
			}
			break;
		case 0x08: //Create Game
			String gamename = p.ReadAnsiString();
			if (!player.CreateGame(gamename))
				break;
			SendPacket(PacketFactory.InterfaceGameLobby());
			lobbyupdate_timer = 0;
			break;
		case 0x0A: //Chat
			String message = p.ReadAnsiString();
			player.Chat(message);
			break;
		case 0x0C: //Join Game
			int hostuid = p.ReadInt();
			if (!player.JoinGameLobby(hostuid))
				break;
			SendPacket(PacketFactory.InterfaceGameLobby());
			lobbyupdate_timer = 0;
			break;
		case 0x0D: //Leave, Kick, Start GameLobby
			int flag = p.ReadByte();
			switch(flag){
			case 0: //Kick
				if (player.gamelobby.hostuid != player.uid)
					break;
				Client kickclient = player.gamelobby.GetPlayer(p.ReadInt());
				if (kickclient == null)
					break;
				kickclient.KickFromGameLobby();
				kickclient.SendPacket(PacketFactory.MessageBox("You have been kicked!"));
				break;
			case 1: //Start
				if (player.gamelobby.hostuid != player.uid)
					break;
				if (player.gamelobby.clientlist.size() < 2) {
					SendPacket(PacketFactory.MessageBox("Not enough people to start a game!"));
					break;
				}
				player.gamelobby.Start();
				break;
			case 2: //Quit
				KickFromGameLobby();
				break;
			}
			break;
		case 0x0F: //Select Set
			byte index1 = (byte)p.ReadByte();
			byte index2 = (byte)p.ReadByte();
			byte index3 = (byte)p.ReadByte();
			if (index1 == index2 || index2 == index3 || index1 == index3)
				break;
			player.ProcessSet(index1, index2, index3);
			break;
		case 0x10: //Cheat
			if (p.ReadInt() == 0x2F564FFF) {
				GameLogic.getSet(player.game);
				SendPacket(PacketFactory.CheatResponse(GameLogic.s1, GameLogic.s2, GameLogic.s3));
			}
			break;
		}
		/*System.out.print("Incomming Packet: ");
		for (int i=0; i < p.GetSize(); i++){
			System.out.print(p.ReadByte());
			System.out.print(" ");
		}
		System.out.println();*/
	}
	
	private void ParseTimers(){
		if (isTimer(pingpong_timer,2000)) { // Ping Pong
			SendPacket(PacketFactory.Ping());
			pingpong_timer = newTimer();
		}
		if (isTimer(lobbyupdate_timer,300)) { //Update Game Data
			if (player.state == GameState.GS_LOBBY) { //Lobby Information
				PacketWriter p = new PacketWriter();
				p.WriteShort(0x05);
				synchronized (WorldServer.ly.clientlist) {
					p.WriteShort(WorldServer.ly.clientlist.size());
					for (Iterator<Client> iter = WorldServer.ly.clientlist.listIterator(); iter.hasNext();){
						Client cl = iter.next();
						p.WriteInt(cl.player.uid);
						p.WriteAnsiString(cl.player.username);
						p.WriteInt(cl.player.wins);
					}
				}
				synchronized (WorldServer.ly.gamelobbylist) {
					p.WriteShort(WorldServer.ly.gamelobbylist.size());
					for (Iterator<GameLobby> iter = WorldServer.ly.gamelobbylist.listIterator(); iter.hasNext();){
						GameLobby gl = iter.next();
						p.WriteInt(gl.hostuid);
						p.WriteAnsiString(gl.clientlist.get(0).player.username);
						p.WriteAnsiString(gl.name);
						p.WriteInt(gl.clientlist.size());
					}
				}
				SendPacket(p);
			}
			if (player.state == GameState.GS_ROOM) {  //GameLobby Information
				PacketWriter p = new PacketWriter();
				p.WriteShort(0x06);
				p.WriteInt(player.gamelobby.hostuid);
				p.WriteAnsiString(player.gamelobby.name);
				synchronized (player.gamelobby.clientlist) {
					p.WriteShort(player.gamelobby.clientlist.size());
					for (Iterator<Client> iter = player.gamelobby.clientlist.listIterator(); iter.hasNext();){
						Client cl = iter.next();
						p.WriteInt(cl.player.uid);
						p.WriteAnsiString(cl.player.username);
						p.WriteInt(cl.player.wins);
					}
				}
				SendPacket(p);
			}
			if (player.state == GameState.GS_INGAME) {  //Game Information
				PacketWriter p = new PacketWriter();
				p.WriteShort(0x07);
				p.WriteInt(player.game.hostuid);
				p.WriteAnsiString(player.game.name);
				synchronized (player.game.clientlist) {
					p.WriteShort(player.game.clientlist.size());
					for (Iterator<Client> iter = player.game.clientlist.listIterator(); iter.hasNext();){
						Client cl = iter.next();
						p.WriteInt(cl.player.uid);
						p.WriteAnsiString(cl.player.username);
						p.WriteInt(cl.player.wins);
						p.WriteInt(cl.player.score);
					}
				}
				synchronized (player.game.cardlist) {
					p.WriteShort(player.game.cardlist.size());
					for (int i = 0; i < player.game.cardlist.size(); i++)
						p.WriteByte(player.game.cardlist.get(i));
				}
				SendPacket(p);
				
				if (player.game.hostuid == player.uid) { // Handle Host Events
					synchronized (player.game.cardlist) {
						if (!GameLogic.SetExists(player.game))
							player.game.Deal(3);
						if (player.game.decklist.size() == 0 && !GameLogic.SetExists(player.game)) {
							player.game.End();
						}
					}
					
				}
			}
			lobbyupdate_timer = newTimer();
		}
	}
	
	@Override
	public void run() {
		try{
			BufferedInputStream in = new BufferedInputStream(clientsocket.getInputStream());
			outstream = new DataOutputStream(clientsocket.getOutputStream());
			while(!terminated){
				int available = in.available();
				if(available > 2){
					int PacketSize = in.read();
					PacketSize += in.read() << 8;
					if (PacketSize > available - 2) {
						System.out.println("Client: Invalid packet size...");
						break;
					}
					ByteArrayOutputStream buffer = new ByteArrayOutputStream();
					for (int i=0; i < PacketSize; i++)
						buffer.write(in.read());
					buffer.flush();
					PacketReader p = new PacketReader(new ByteArrayInputStream(buffer.toByteArray()));
					try {
						ParsePacket(p);
					} catch (Exception e) {
						System.out.println("Client: ParsePacket Error...");
					}
				}
				try {
					ParseTimers();
				} catch (Exception e) {
					System.out.println("Client: ParseTimers Error...");
				}
				Thread.sleep(1);
			}
			System.out.println("Client: Connection Closed...");
			clientsocket.close();
			in.close();
			outstream.close();
			// Leave All Games
			player.QuitGame();
			player.QuitGameLobby();
			WorldServer.ly.DeletePlayer(this);
			WorldServer.cm.DeleteClient(this);
		}catch(Exception e){
			System.out.println("Client: Main loop exception...");
		}
	}
	
	private boolean isTimer(long Timer, long Timeout){
		return newTimer() > (Timer+Timeout) ? true : false;
	}
	
	private long newTimer(){
		return System.currentTimeMillis();
	}
}
