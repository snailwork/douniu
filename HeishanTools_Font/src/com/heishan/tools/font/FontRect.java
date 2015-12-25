package com.heishan.tools.font;

import java.awt.image.BufferedImage;

/**
 * 任何图形都可以被描述为一个矩形
 * @author heishanlaoyao
 *
 */
public class FontRect {

	public BufferedImage bufferedImage = null;
	public String name = ""; // 名称
	public int id = -1; // 唯一标识
	public int x = 0;
	public int y = 0;
	public int width = 0;
	public int height = 0;
	public int offsetX = 0;
	public int offsetY = 0;
	
	/**
	 * 构造函数
	 */
	public FontRect() { }
	
	/**
	 * 构造函数
	 * @param id
	 * @param bufferedImage
	 */
	public FontRect(int id, String name, BufferedImage bufferedImage) {
		this.id = id;
		this.name = name;
		this.bufferedImage = bufferedImage;
		if (this.bufferedImage != null) {
			this.width = this.bufferedImage.getWidth();
			this.height = this.bufferedImage.getHeight();
		}
	}
	
	/**
	 * 构造函数
	 * @param id
	 * @param width
	 * @param height
	 */
	public FontRect(int id, String name, int width, int height) {
		this.id = id;
		this.name = name;
		this.width = width;
		this.height = height;
	}
	
	/**
	 * 构造函数
	 * @param id
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 */
	public FontRect(int id, String name, int x, int y, int width, int height) {
		this.id = id;
		this.name = name;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	/**
	 * 构造函数
	 * @param id
	 * @param name
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 * @param offsetX
	 * @param offsetY
	 */
	public FontRect(int id, String name, int x, int y, int width, int height, int offsetX, int offsetY) {
		this.id = id;
		this.name = name;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}
	
	/**
	 * 获取图片的rgb数组
	 * @return
	 */
	public int[] getRGB() {
		if (this.bufferedImage == null) {
			return null;
		}
		int[] rgb = new int[this.width * this.height];
		this.bufferedImage.getRGB(0, 0, this.width, this.height, rgb, 0, this.width);
		return rgb;
	}
	
	/**
	 * 判断当前节点是否包含输入的矩形
	 * @param rect
	 * @return
	 */
	public boolean isContain(FontRect rect) {
		if (rect.x >= this.x && rect.y >= this.y && (rect.x + rect.width) <= (this.x + this.width) && (rect.y + rect.height) <= (this.y + this.height)) {
			return true;
		}
		return false;
	}
	
	/**
	 * 复制矩形，返回与当前节点内容相同的新对象
	 */
	public FontRect clone() {
		FontRect newRect = new FontRect(this.id, this.name, this.x, this.y, this.width, this.height, this.offsetX, this.offsetY);
		newRect.bufferedImage = this.bufferedImage;
		return newRect;
	}
	
	@Override
	public String toString() {
		String str = "id=" + id + ", x=" + x + ", y=" + y + ", width=" + width + ", height=" + height + ", offsetX=" + offsetX + ", offsetY=" + offsetY;
		if (this.bufferedImage != null) {
			str = str + ", bufferedImage.width=" + bufferedImage.getWidth() + ", bufferedImage.height=" + bufferedImage.getHeight();
		}
		return str;
	}
	
}
