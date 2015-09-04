package net.set.packet;

import java.io.ByteArrayInputStream;

public class PacketReader{
	private ByteArrayInputStream bais;
	private int size;
	
	public PacketReader(ByteArrayInputStream in) {
		bais = in;
		size = in.available();
	}
	
	public int GetSize() {
		return size;
	}
	
	public int Remaining() {
		return bais.available();
	}
	
	public int ReadByte() {
		int temp;
		if (Remaining() < 1)
			return -1;
		try {
			temp = bais.read();
			return temp;
		} catch (Exception e) {
			return -1;
		}
	}
	
	public short ReadShort() {
		int byte1, byte2;
		if (Remaining() < 2)
			return -1;
		byte1 = ReadByte();
		byte2 = ReadByte();
		return (short) ((byte2 << 8) + byte1);
	}
	
	public int ReadInt() {
		int byte1, byte2, byte3, byte4;
		if (Remaining() < 4)
			return -1;
		byte1 = ReadByte();
		byte2 = ReadByte();
		byte3 = ReadByte();
		byte4 = ReadByte();
		return (byte4 << 24) + (byte3 << 16) + (byte2 << 8) + byte1;
	}
	
	public String ReadAnsiString() {
		int n = ReadShort();
		if (Remaining() < n)
			return "";
		char ret[] = new char[n];
		for (int x = 0; x < n; x++) {
			ret[x] = (char) ReadByte();
		}
		return String.valueOf(ret);
	}
}