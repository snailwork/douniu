package com.heishan.tools.font;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JFrame;
import javax.swing.JPanel;

import com.heishan.tools.log.Log;

/**
 * 测试类，用以调试
 * @author heishanlaoyao
 *
 */
public class FontTest extends JFrame {
	
	private static final String TAG = FontTest.class.getSimpleName();
	
	public static String getExtensionName(String filename) {   
        if ((filename != null) && (filename.length() > 0)) {   
            int dot = filename.lastIndexOf('.');   
            if ((dot >-1) && (dot < (filename.length() - 1))) {   
                return filename.substring(dot + 1);   
            }   
        }   
        return filename;   
    }
	
	/**
	 * 算法测试
	 * @param args
	 */
	public static void main(String[] args) {
		String inPath = System.getProperty("user.dir") + "/font_in/";
		
		FontValue atlasWidth = new FontValue();
		FontValue atlasHeight = new FontValue();

		List<FontRect> sourceRects = FontUtil.GetSourceRects(inPath, atlasWidth, atlasHeight);
		
		FontBinBuilder binBuilder = new FontBinBuilder();
		binBuilder.init(atlasWidth.intValue, atlasHeight.intValue, sourceRects);
		binBuilder.build();
		
		List<FontRect> packedRects = binBuilder.getPackedRects();
		Log.debug("packedRects.size()=" + packedRects.size());
		
//		FontBinPacker binPacker = new FontBinPacker();
//		boolean initResult = binPacker.init(outWidth, outHeight, true);
//		Log.debug(TAG, "BinPack init result=" + initResult);
//		boolean packResult = binPacker.pack(unpackedRects, FontBinPacker.METHOD_RECT_BEST_AREA_FIT);
//		Log.debug(TAG, "BinPack pack result=" + packResult);
//		packedRects = binPacker.getPackedRects();
		
		FontTest fontTest = new FontTest(atlasWidth.intValue, atlasHeight.intValue);
		for (FontRect rect : packedRects) {
			// 由于算法是基于左下角为原点的坐标系，而显示是基于左上角为原点的坐标系，需要对y轴做坐标系转换
			int x1 = rect.x;
			int y1 = rect.y;
			int x2 = rect.x + rect.width;
			int y2 = rect.y + rect.height;
			Log.debug(TAG, "rect=" + rect.toString());
			fontTest.addFillRect(x1, y1, x2, y2, rect.id + "");
		}
	}
	
	/** =================================================== 华丽的分割线-界面相关 =================================================== **/
	
	private static final long serialVersionUID = 1L;
	
	private DrawPanel drawPanel = null;
	
	public FontTest(int width, int height) {
		super("MaxRect装箱面板");
		
		// 重置当前容器大小
	    this.setBounds(40, 40, width, height);
	    this.setVisible(true);
	    this.validate();
	    this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    
	    // 添加绘图面板
	    this.drawPanel = new DrawPanel();
	    this.add(this.drawPanel);
	}
	
	/**
	 * 在面板中添加矩形
	 */
	public void addFillRect(int x1, int y1, int x2, int y2, String text) {
		if (this.drawPanel != null) {
			this.drawPanel.drawFillRect(x1, y1, x2, y2, text);
		}
	}
	
	/** =================================================== 华丽的分割线-绘图相关 =================================================== **/
	public class Drawing implements Serializable {

		private static final long serialVersionUID = 1L;
		
		public int x1, y1, x2, y2;
		public int r, g, b;
		public String text;
		
		public void draw(Graphics2D g2d) {}
	}
	
	public class FillRect extends Drawing {
		private static final long serialVersionUID = 1L;

		public void draw(Graphics2D g2d) {
			g2d.setPaint(new Color(r, g, b));
			g2d.fillRect(x1, y1, Math.abs(x1 - x2), Math.abs(y1 - y2));
		}
	}
	
	public class Word extends Drawing {
		private static final long serialVersionUID = 1L;
		
		public void draw(Graphics2D g2d) {
			if (text != null) {
				g2d.setPaint(new Color(0, 0, 0));
				g2d.setFont(new Font("黑体", Font.BOLD, 15));
				g2d.drawString(text, x1, y1 + 15);
			}
		}
	}
	
	public class DrawPanel extends JPanel {
		private static final long serialVersionUID = 1L;

		private List<Drawing> drawings;

		public DrawPanel() {
			//this.setBackground(Color.gray);// 设置绘制区的背景是白色
			drawings = new ArrayList<Drawing>();
		}

		@Override
		public void paintComponent(Graphics g) {
			super.paintComponent(g);
			Graphics2D g2d = (Graphics2D) g;
			if (this.drawings != null && this.drawings.size() > 0) {
				for (int i = 0; i < this.drawings.size(); i++) {
					Drawing drawing = this.drawings.get(i);
					drawing.draw(g2d);
				}
			}
		}
		
		public void drawFillRect(int x1, int y1, int x2, int y2, String text) {
			Drawing fillRect = new FillRect();
			fillRect.x1 = x1;
			fillRect.y1 = y1;
			fillRect.x2 = x2;
			fillRect.y2 = y2;
			fillRect.r = (int) (Math.random() * 200) + 50;
			fillRect.g = (int) (Math.random() * 200) + 50;
			fillRect.b = (int) (Math.random() * 200) + 50;
			this.drawings.add(fillRect);
			Drawing word = new Word();
			word.x1 = x1;
			word.y1 = y1;
			word.x2 = x2;
			word.y2 = y2;
			word.text = text;
			this.drawings.add(word);
			this.repaint();
		}
		
	}

}
