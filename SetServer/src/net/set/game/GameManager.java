package net.set.game;

import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import net.set.packet.PacketFactory;
import net.set.server.Client;

public class GameManager {
	public List<Game> gamelist = Collections.synchronizedList(new LinkedList<Game>());
	
	public GameManager() {
		
	}
	
	public boolean AddGame(Client host, String name) {
		if (GetGame(host.GetUID()) != null)
			return false;
		Game newgame = new Game(host, name);
		gamelist.add(newgame);
		return true;
	}
	
	public Game GetGame(int hostuid) {
		synchronized (gamelist){
			for (Iterator<Game> iter = gamelist.listIterator(); iter.hasNext();){
				Game game = iter.next();
				if (game.hostuid == hostuid)
					return game;
			}
		}
		return null;
	}
	
	public void DeleteGame(int hostuid) {
		synchronized (gamelist) {
			for (Iterator<Game> iter = gamelist.listIterator(); iter.hasNext();){
				Game game = iter.next();
				if(game.hostuid == hostuid) {
					synchronized (game) {
						for (Iterator<Client> iter2 = game.clientlist.listIterator(); iter2.hasNext();){
							Client client = iter2.next();
							client.KickFromGame();
							client.SendPacket(PacketFactory.MessageBox("Game terminated because host has left!"));
						}
					}
					iter.remove();
					return;
				}
			}
		}
	}
}
