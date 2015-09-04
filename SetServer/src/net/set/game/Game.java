package net.set.game;

import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import java.util.Stack;
import java.util.Vector;

import net.set.packet.PacketFactory;
import net.set.packet.PacketWriter;
import net.set.server.Client;
import net.set.server.WorldServer;

public class Game {
	public List<Client> clientlist = Collections.synchronizedList(new LinkedList<Client>());
	public Stack<Byte> decklist = new Stack<Byte>();
	public Vector<Byte> cardlist = new Vector<Byte>();
	
	public String name;
	public int hostuid;
	
	private static Random rand = new Random();
	
	public static int randInt(int min, int max) {
	    return rand.nextInt((max - min) + 1) + min;
	}
	
	public Game(Client host, String name) {
		hostuid = host.GetUID();
		this.name = name;
		// Shuffle Cards
		Vector<Byte> cardlist = new Vector<Byte>();
		for (int i=0; i<81; i++)
			cardlist.add((byte)i);
		for (int i=0; i<81; i++) {
			int rm = rand.nextInt(cardlist.size());
			this.decklist.push(cardlist.get(rm));
			cardlist.remove(rm);
		}
		// Deal 12 Cards
		Deal(12);
	}
	
	public void Deal(int num) {
		synchronized (cardlist) {
			if (cardlist.size() >= 20)
				return;
			if (cardlist.size() + num > 20)
				num = 20;
			for (int i = 0; i < num; i++)
				if (!decklist.empty())
					cardlist.add(decklist.pop());
		}
	}
	
	public void End() {
		synchronized (clientlist) {
			int HighestScore = 0;
			
			// Find Winner
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client cclient = iter.next();
				if (cclient.GetScore() > HighestScore)
					HighestScore = cclient.GetScore();
			}
			
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client cclient = iter.next();
				cclient.JoinLobby();
				if (cclient.GetScore() == HighestScore) {
					cclient.IncreaseWins();
					cclient.SendPacket(PacketFactory.GameEventYouWon());
					cclient.SendPacket(PacketFactory.MessageBox("You Won!"));
				} else {
					cclient.SendPacket(PacketFactory.GameEventYouLost());
					cclient.SendPacket(PacketFactory.MessageBox("You Lost..."));;
				}
				cclient.Save();
				iter.remove();
			}
		}
		WorldServer.gm.DeleteGame(hostuid);
	}
	
	public void ReplaceCard(int id, boolean bdelete) {
		synchronized (cardlist) {
			for (int i = 0; i < cardlist.size(); i++)
				if (cardlist.get(i) == id) {
					if (bdelete) {
						cardlist.remove(i);
						break;
					}
					if (!decklist.empty())
						cardlist.set(i, decklist.pop());
					else
						cardlist.remove(i);
					break;
				}
		}
	}
	
	public void RemoveCard(int id) {
		synchronized (cardlist) {
			for (int i = 0; i < cardlist.size(); i++)
				if (cardlist.get(i) == id) {
					cardlist.remove(i);
					break;
				}
		}
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
	
	public void BroadcastPacket(PacketWriter p) {
		synchronized (clientlist) {
			for (Iterator<Client> iter = clientlist.listIterator(); iter.hasNext();){
				Client client = iter.next();
				client.SendPacket(p);
			}
		}
	}
}
