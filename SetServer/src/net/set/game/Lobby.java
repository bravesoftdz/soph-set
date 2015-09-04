package net.set.game;

import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import net.set.packet.PacketFactory;
import net.set.server.Client;

public class Lobby {
	public List<Client> clientlist = Collections.synchronizedList(new LinkedList<Client>());
	public List<GameLobby> gamelobbylist = Collections.synchronizedList(new LinkedList<GameLobby>());
	
	public Lobby() {
		
	}
	
	public void AddPlayer(Client client) {
		if (GetPlayer(client.GetUID()) == null)
			clientlist.add(client);
	}
	
	public Client GetPlayer(int uid) {
		synchronized (clientlist){
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client cclient = iter.next();
				if (cclient.GetUID() == uid)
					return cclient;
			}
		}
		return null;
	}
	
	public void DeletePlayer(Client client) {
		synchronized (clientlist){
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client cclient = iter.next();
				if (cclient == client){
					iter.remove();
				}
			}
		}
	}
	
	public boolean AddGame(Client host, String name) {
		if (GetGame(host.GetUID()) != null)
			return false;
		GameLobby newgame = new GameLobby(host, name);
		gamelobbylist.add(newgame);
		return true;
	}
	
	public GameLobby GetGame(int hostuid) {
		synchronized (gamelobbylist){
			for (Iterator<GameLobby> iter = gamelobbylist.listIterator(); iter.hasNext();){
				GameLobby gamelobby = iter.next();
				if (gamelobby.hostuid == hostuid)
					return gamelobby;
			}
		}
		return null;
	}
	
	public void DeleteGame(int hostuid) {
		synchronized (gamelobbylist) {
			for (Iterator<GameLobby> iter = gamelobbylist.listIterator(); iter.hasNext();){
				GameLobby gamelobby = iter.next();
				if(gamelobby.hostuid == hostuid) {
					synchronized (gamelobby) {
						for (Iterator<Client> iter2 = gamelobby.clientlist.listIterator(); iter2.hasNext();){
							Client client = iter2.next();
							client.KickFromGameLobby();
							client.SendPacket(PacketFactory.MessageBox("Game host has left!"));
						}
					}
					iter.remove();
					return;
				}
			}
		}
	}
	
	public void BroadcastChat(Client sender, String message) {
		String completemessage = String.format("%s: %s",sender.GetUsername() ,message);
		synchronized (clientlist) {
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client client = iter.next();
				client.SendPacket(PacketFactory.CreateChatBroadcast(completemessage));
			}
		}
	}
}
