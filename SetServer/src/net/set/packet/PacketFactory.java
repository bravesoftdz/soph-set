package net.set.packet;

public class PacketFactory {
	public static PacketWriter InterfaceLogin(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x01);
		p.WriteInt(0x00);
		return p;
	}
	
	public static PacketWriter InterfaceLobby(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x01);
		p.WriteInt(0x01);
		return p;
	}
	
	public static PacketWriter InterfaceGameLobby(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x01);
		p.WriteInt(0x02);
		return p;
	}
	
	public static PacketWriter InterfaceGame(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x01);
		p.WriteInt(0x03);
		return p;
	}
	
	public static PacketWriter Ping(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x02);
		p.WriteInt((int)System.currentTimeMillis());
		return p;
	}
	
	public static PacketWriter PlayerInfo(int uid, int wins, int score, String name){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x04);
		p.WriteInt(uid);
		p.WriteInt(wins);
		p.WriteAnsiString(name);
		return p;
	}
	
	public static PacketWriter MessageBox(String message){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x09);
		p.WriteAnsiString(message);
		return p;
	}
	
	public static PacketWriter CreateChatBroadcast(String chatmessage){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x0B);
		p.WriteAnsiString(chatmessage);
		return p;
	}
	
	public static PacketWriter GameEventSetOther(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x0E);
		p.WriteByte(0x00);
		return p;
	}
	
	public static PacketWriter GameEventSetYou(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x0E);
		p.WriteByte(0x01);
		return p;
	}
	
	public static PacketWriter GameEventYouWon(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x0E);
		p.WriteByte(0x02);
		return p;
	}
	
	public static PacketWriter GameEventYouLost(){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x0E);
		p.WriteByte(0x03);
		return p;
	}
	
	public static PacketWriter CheatResponse(byte c1, byte c2, byte c3){
		PacketWriter p = new PacketWriter();
		p.WriteShort(0x11);
		p.WriteByte(c1);
		p.WriteByte(c2);
		p.WriteByte(c3);
		return p;
	}
}
