package net.set.server;

import java.net.Socket;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import net.set.packet.PacketWriter;

public class ClientManager {
	private List<Client> Clients = Collections.synchronizedList(new LinkedList<Client>());
	
	public ClientManager() {
		
	}
	
	public void AddClient(Socket s) {
		Client c = new Client(s);
		Clients.add(c);
		c.start();
	}
	
	public void DeleteClient(Client client) {
		synchronized (Clients) {
			for (Iterator<Client> iter = Clients.listIterator(); iter.hasNext();) {
				Client cclient = iter.next();
				if (cclient == client) {
					cclient.Close();
					iter.remove();
				}
			}
		}
	}
	
	public Client GetClient(int uid) {
		synchronized (Clients) {
			for (Iterator<Client> iter = Clients.listIterator(); iter.hasNext();) {
				Client client = iter.next();
				if (client.GetUID() == uid)
					return client;
			}
		}
		return null;
	}
	
	public void Broadcast(PacketWriter p){
		synchronized (Clients) {
			for (Iterator<Client> iter = Clients.listIterator(); iter.hasNext();){
				Client client = iter.next();
				client.SendPacket(p);
			}
		}
	}
}
