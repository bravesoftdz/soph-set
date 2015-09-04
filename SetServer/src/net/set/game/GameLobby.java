package net.set.game;

import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import net.set.packet.PacketFactory;
import net.set.server.Client;
import net.set.server.WorldServer;

public class GameLobby {
	public List<Client> clientlist = Collections.synchronizedList(new LinkedList<Client>());
	
	public String name;
	public int hostuid;
	
	public GameLobby(Client host, String name) {
		hostuid = host.GetUID();
		this.name = name;
	}
	
	public void AddPlayer(Client client) {
		if (GetPlayer(client.GetUID()) == null)
			clientlist.add(client);
	}
	
	public Client GetPlayer(int uid) {
		synchronized (clientlist) {
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client cclient = iter.next();
				if (cclient.GetUID() == uid) {
					return cclient;
				}
			}
		}
		return null;
	}
	
	public void DeletePlayer(Client client) {
		synchronized (clientlist) {
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client cclient = iter.next();
				if (cclient == client) {
					iter.remove();
					return;
				}
			}
		}
	}
	
	public void Start() {
		WorldServer.gm.AddGame(clientlist.get(0), name);
		Game game = WorldServer.gm.GetGame(clientlist.get(0).GetUID());
		if (game == null)
			return;
		synchronized (clientlist) {
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client cclient = iter.next();
				cclient.JoinGame();
				iter.remove();
			}
		}
		WorldServer.ly.DeleteGame(hostuid);
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
