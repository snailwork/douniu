package com.heishan.tools.font;

/**
 * 包含简单对象，用于实现java函数调用中的引用传递
 * @author heishanlaoyao
 *
 */
public class FontValue {
	
	int intValue;
	boolean booleanValue;
	String stringValue;
	float floatValue;
	
	public FontValue() {}
	
	public FontValue(int intValue) {
		this.intValue = intValue;
	}
	
	public FontValue(boolean booleanValue) {
		this.booleanValue = booleanValue;
	}
	
	public FontValue(String stringValue) {
		this.stringValue = stringValue;
	}
	
	public FontValue(float floatValue) {
		this.floatValue = floatValue;
	}
	
	@Override
	public String toString() {
		return "[MRValue] intValue=" + intValue + ", booleanValue=" + booleanValue + ", stringValue=" + stringValue + ", floatValue=" + floatValue;
	}

}
