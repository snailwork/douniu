package com.heishan.tools.font;

import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

import com.heishan.tools.log.Log;

public class FontUtil {
	
	private static final String TAG = FontUtil.class.getSimpleName();
	
	public static final int ERROR_CODE_SUCCESS = 0;
	public static final int ERROR_CODE_NO_FONT_IMAGE = 1;
	public static final int ERROR_CODE_READ_FONT_IMAGE_EXCEPTION = 2;
	public static final int ERROR_CODE_WRITE_FONT_IMAGE_EXCEPTION = 3;
	public static final int ERROR_CODE_WRITE_FONT_CONFIG_EXCEPTION = 4;
	
	public static final int LINE_NUM = 10; // 一行字数
	
	/**
	 * 单元测试
	 * @param str
	 */
	public static void main(String[] str) {
		String inPath = System.getProperty("user.dir") + "/font_in/";
		String outPath = System.getProperty("user.dir") + "/font_in/";
		String fontName = "test";
		FontValue atlasWidth = new FontValue();
		FontValue atlasHeight = new FontValue();
		List<FontRect> sourceRects = GetSourceRects(inPath, atlasWidth, atlasHeight);
		
		FontBinBuilder binBuilder = new FontBinBuilder();
		binBuilder.init(atlasWidth.intValue, atlasHeight.intValue, sourceRects);
		binBuilder.build();
		List<FontRect> packedRects = binBuilder.getPackedRects();
		
		try {
			boolean genFontImageResult = GenFontImage(packedRects, atlasWidth.intValue, atlasHeight.intValue, outPath, fontName);
			Log.debug(TAG, "genFontImageResult=" + genFontImageResult);
			
			boolean genFontFntResult = GenFontFnt(packedRects, atlasWidth.intValue, atlasHeight.intValue, outPath, fontName, 10, 10);
			Log.debug(TAG, "genFontFntResult=" + genFontFntResult);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 生成字体文件
	 * @param fontName
	 * @param inPath
	 * @param outPath
	 * @param spaceWidth
	 * @param defaultHeight
	 * @return
	 */
	public static int GenFont(String fontName, String inPath, String outPath, int spaceWidth, int defaultHeight) {
		FontValue atlasWidth = new FontValue();
		FontValue atlasHeight = new FontValue();
		List<FontRect> sourceRects = GetSourceRects(inPath, atlasWidth, atlasHeight);
		
		FontBinBuilder binBuilder = new FontBinBuilder();
		binBuilder.init(atlasWidth.intValue, atlasHeight.intValue, sourceRects);
		boolean isPackedSuccess = binBuilder.build();
		if (isPackedSuccess) {
		} else {
			if (atlasWidth.intValue > atlasHeight.intValue) {
				atlasHeight.intValue *= 2;
			} else {
				atlasWidth.intValue *= 2;
			}
			binBuilder.init(atlasWidth.intValue, atlasHeight.intValue, sourceRects);
			binBuilder.build();
		}
		
		List<FontRect> packedRects = binBuilder.getPackedRects();
		if (packedRects == null) {
			return ERROR_CODE_READ_FONT_IMAGE_EXCEPTION;
		}
		
		try {
			boolean genFontImageResult = GenFontImage(packedRects, atlasWidth.intValue, atlasHeight.intValue, outPath, fontName);
			if (!genFontImageResult) {
				return ERROR_CODE_WRITE_FONT_IMAGE_EXCEPTION;
			}
		} catch (IOException e) {
			e.printStackTrace();
			return ERROR_CODE_WRITE_FONT_IMAGE_EXCEPTION;
		}
		
		try {
			boolean genFontFntResult = GenFontFnt(packedRects, atlasWidth.intValue, atlasHeight.intValue, outPath, fontName, spaceWidth, defaultHeight);
			if (!genFontFntResult) {
				return ERROR_CODE_WRITE_FONT_CONFIG_EXCEPTION;
			}
		} catch (IOException e) {
			e.printStackTrace();
			return ERROR_CODE_WRITE_FONT_CONFIG_EXCEPTION;
		}
		
		Log.debug(TAG, "GenFont() 字体生成成功");
		
		return ERROR_CODE_SUCCESS;
	}
	
	/**
	 * 生成字体文件（已弃用）
	 * @param fontName
	 * @param inPath
	 * @param outPath
	 * @return
	 */
	/*********************************************************************************
	public static int GenFontOld(String fontName, String inPath, String outPath) {
		Log.debug("字体名称：" + fontName);
		Log.debug("输入路径：" + inPath);
		Log.debug("输出路径：" + outPath);
		
		File directory = new File(inPath);
		String[] files = directory.list(); // 获取图片文件名称
		List<String> pics = new ArrayList<String>();
		for (String filename : files) {
			String ext = GetExtensionName(filename);
			Log.debug("filename=" + filename + ", ext=" + ext);
			if (ext == "png" || ext.equals("png") || ext == "jpg" || ext.equals("jpg")) {
				Log.debug("图片文件");
				pics.add(filename);
			} else {
				Log.debug("非图片文件");
			}
		}
		int len = pics.size();
		if(len < 1) {
			Log.debug("warn: no file in path");
			return ERROR_CODE_NO_FONT_IMAGE;
		}
		File[] src = new File[len]; // 存放临时文件
		BufferedImage[] bufImages = new BufferedImage[len];
		int[][] imageArrays = new int[len][]; // 初始化图片信息
		// 生成图片信息数组
		for(int i = 0; i < len; i++) {
			try {
				src[i] = new File(inPath + pics.get(i));
				bufImages[i] = ImageIO.read(src[i]);
				int width = bufImages[i].getWidth();
				int height = bufImages[i].getHeight();
				imageArrays[i] = new int[width * height];
				imageArrays[i] = bufImages[i].getRGB(0, 0, width, height, imageArrays[i], 0, width);
			} catch(Exception e) {
				Log.error(e.getLocalizedMessage());
				return ERROR_CODE_READ_FONT_IMAGE_EXCEPTION;
			}
		}
		
		Log.debug(">>>>>>>>> 正在生成字体...");
		
		// 生成新图片文件的尺寸
		// 每行10个，行列转换
		//Log.debug(">>>>>>>>> step 2");
		int lineCount = len / LINE_NUM + 1; // 字体行数
		int dstWidth = 0; // 输出图片宽度
		int dstHeight = 0; // 输出图片高度
		int maxWidth = 0; // 单位图片最大宽度
		int maxHeight = 0; // 单位图片最大高度
		for(int i = 0; i < len; i++) {
			maxWidth = maxWidth > bufImages[i].getWidth()?maxWidth : bufImages[i].getWidth();
			maxHeight = maxHeight > bufImages[i].getHeight()?maxHeight : bufImages[i].getHeight();
		}
		if(lineCount > 1) { // 大于一行
			dstWidth = maxWidth * LINE_NUM;
			dstHeight = maxHeight * lineCount;
		} else { // 小于等于一行
			dstWidth = maxWidth * len;
			dstHeight = maxHeight * 1;
		}
		FontPos[] poses = new FontPos[len];
		for(int i = 0; i < len; i++) {
			int index = i % LINE_NUM;
			int line = i / LINE_NUM;
			int x = index * maxWidth;
			int y = line * maxHeight;
			FontPos pos = new FontPos(x, y);
			poses[i] = pos;
			//Log.debug("x=" + x + ", y=" + y);
		}
		//Log.debug("dstWidth=" + dstWidth + ", dstHeight=" + dstHeight);
		if(dstHeight < 1) {
			Log.debug("warn: dstHeight < 1");
		}
		
		// 生成font描述信息
		// info face="宋体" size=24 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0
		String info = GenInfo(fontName, "24", "0", "0", "", "0", "" + maxHeight, "1", "1", "0,0,0,0", "0,0");
		// common lineHeight=29 base=23 scaleW=2048 scaleH=1024 pages=1 packed=0
		String common = GenCommon("" + maxHeight, "24", "" + dstWidth, "" + dstHeight, "1", "0");
		// page id=0 file="font_12.png"
		String page = GenPage("0", fontName + ".png");
		// chars count=2
		String chars = GenChars("" + (len + 1)); // 此处做 + 1 操作，添加空格
		//Log.debug(info + common + page + chars);
		String[] charLines = new String[len + 1];
		// char id=32   x=0     y=0     width=0     height=0     xoffset=0     yoffset=23    xadvance=12     page=0  chnl=0
		// 默认生成第一行空格，空格的宽度为 maxWidth/2
		charLines[0] = GenChar(GetASCII(" "), "0", "0", "0", "0", "0", "0", "" + maxWidth/2, "0", "0");
		
		// 生成新图片
		//Log.debug(">>>>>>>>> step 3");
		try {
			BufferedImage imageNew = new BufferedImage(dstWidth, dstHeight, BufferedImage.TYPE_INT_ARGB_PRE);
			for(int i = 0; i < len; i++) {
				FontPos pos = poses[i];
				imageNew.setRGB(pos.x, pos.y, maxWidth, maxHeight, imageArrays[i], 0, maxWidth);
				
				charLines[i + 1] = GenChar(GetCharId(pics.get(i)), poses[i].x + "", poses[i].y + "", 
						bufImages[i].getWidth() + "", bufImages[i].getHeight() + "", "0", "0", maxWidth + "", "0", "0");
			}
			File outFile = new File(outPath + fontName + ".png");
			ImageIO.write(imageNew, "png", outFile); // 此处恒为png
		} catch(Exception e) {
			e.printStackTrace();
			return ERROR_CODE_WRITE_FONT_IMAGE_EXCEPTION;
		}
		
		String charLine = "\n";
		for(int i = 0; i < charLines.length; i++) {
			//Log.debug(charLines[i]);
			charLine = charLine + charLines[i];
		}
		
		// 生成font文件
		//Log.debug(">>>>>>>>> step 3");
		try {
			FileOutputStream fos = new FileOutputStream(outPath + fontName + ".fnt"); 
			OutputStreamWriter osw = new OutputStreamWriter(fos); 
			BufferedWriter bw = new BufferedWriter(osw); 
			bw.write(info + common + page + chars + charLine); 
			bw.close(); 
		} catch(Exception e) {
			e.printStackTrace();
			return ERROR_CODE_WRITE_FONT_CONFIG_EXCEPTION;
		}
		
		Log.debug(">>>>>>>>> 生成字体成功!");
		
		return ERROR_CODE_SUCCESS;
	}
	*********************************************************************************/
	
	/**
	 * 输出字体描述文件
	 * @param packedRects
	 * @param atlasWidth
	 * @param atlasHeight
	 * @param outPath
	 * @param fontName
	 * @return
	 * @throws IOException 
	 */
	public static boolean GenFontFnt(List<FontRect> packedRects, int atlasWidth, int atlasHeight, String outPath, String fontName, int spaceWidth, int defaultHeight) throws IOException {
		Log.debug(TAG, "GenFontFnt() 生成字体描述文件开始");
		if (packedRects == null) {
			Log.error(TAG, "GenFontFnt() packedRects is null.");
			return false;
		}
			
		
		// 生成font描述信息
		// info face="宋体" size=24 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0
		String info = GenInfo(fontName, "0", "0", "0", "", "0", "0", "1", "1", "0,0,0,0", "0,0");
		// common lineHeight=29 base=23 scaleW=2048 scaleH=1024 pages=1 packed=0
		String common = GenCommon("" + defaultHeight, "0", "" + atlasWidth, "" + atlasHeight, "1", "0");
		// page id=0 file="font_12.png"
		String page = GenPage("0", fontName + ".png");
		// chars count=2
		String chars = GenChars("" + (packedRects.size() + 1)); // 此处做 + 1 操作，添加空格
		//Log.debug(info + common + page + chars);
		String[] charLines = new String[packedRects.size() + 1];
		// char id=32   x=0     y=0     width=0     height=0     xoffset=0     yoffset=23    xadvance=12     page=0  chnl=0
		// 默认生成第一行空格，空格的宽度为 10
		charLines[0] = GenChar(GetASCII(" "), "0", "0", "0", "0", "0", "0", "" + spaceWidth, "0", "0");
		for(int i = 0; i < packedRects.size(); i++) {
			FontRect rect = packedRects.get(i);
			charLines[i + 1] = GenChar(GetCharId(rect.name), rect.x + "", rect.y + "", rect.width + "", rect.height + "", "0", "0", rect.width + "", "0", "0");
		}
		
		String charLine = "\n";
		for(int i = 0; i < charLines.length; i++) {
			charLine = charLine + charLines[i];
		}
		
		FileOutputStream fos = new FileOutputStream(outPath + fontName + ".fnt"); 
		OutputStreamWriter osw = new OutputStreamWriter(fos); 
		BufferedWriter bw = new BufferedWriter(osw); 
		bw.write(info + common + page + chars + charLine); 
		bw.close(); 
		
		return true;
	}
	
	/**
	 * 输出字体图片
	 * @param packedRects
	 * @param atlasWidth
	 * @param atlasHeight
	 * @return
	 * @throws IOException 
	 */
	public static boolean GenFontImage(List<FontRect> packedRects, int atlasWidth, int atlasHeight, String outPath, String fontName) throws IOException {
		Log.debug(TAG, "GenFontImage() 生成字体图片开始");
		if (packedRects == null) {
			Log.error(TAG, "GenFontImage() packedRects is null.");
			return false;
		}
		if (atlasWidth <= 0 ||atlasHeight <= 0) {
			Log.error(TAG, "unexpect atlasWidth=" + atlasWidth + ", atlasHeight=" + atlasHeight);
			return false;
		}
		
		BufferedImage image = new BufferedImage(atlasWidth, atlasHeight, BufferedImage.TYPE_INT_ARGB_PRE);
		for(FontRect rect : packedRects) {
			image.setRGB(rect.x, rect.y, rect.width, rect.height, rect.getRGB(), 0, rect.width);
		}
		File outFile = new File(outPath + fontName + ".png");
		ImageIO.write(image, "png", outFile); // 此处恒为png
		
		return true;
	}
	
	/**
	 * 获取原始矩形数据，根据指定目录的图片生成
	 * @param inPath
	 * @return
	 */
	public static List<FontRect> GetSourceRects(String inPath, FontValue atlasWidth, FontValue atlasHeight) {
		Log.debug(TAG, "GetSourceRects() 获取字体源图片数据开始");
		if (inPath == null || new File(inPath).exists() == false) {
			Log.error(TAG, "in path is null or in path not exist.");
			atlasWidth.intValue = 0;
			atlasHeight.intValue = 0;
			return null;
		}
		File directory = new File(inPath);
		String[] files = directory.list(); // 获取图片文件名称
		List<String> pics = new ArrayList<String>();
		for (String filename : files) {
			String ext = GetExtensionName(filename);
			if (ext == "png" || ext.equals("png") || ext == "jpg" || ext.equals("jpg")) {
				pics.add(filename);
			} else {
				Log.debug(TAG, "非图片文件 filename=" + filename);
			}
		}
		int len = pics.size();
		if(len < 1) {
			Log.error(TAG, "no file in path");
		}
		
		List<FontRect> sourceRects = new ArrayList<FontRect>();
		int totalArea = 0; // 总面积
		// 生成图片信息数组
		for(int i = 0; i < len; i++) {
			try {
				File file = new File(inPath + pics.get(i));
				FontRect rect = new FontRect(i, pics.get(i), ImageIO.read(file));
				sourceRects.add(rect);
				totalArea += rect.width * rect.height;
			} catch(Exception e) {
				Log.error(TAG, e.getLocalizedMessage());
			}
		}
		Log.debug(TAG, "图片总面积=" + totalArea);
		Log.debug(TAG, "总共图片数量=" + sourceRects.size());
		
		// 根据opengl读取图片时，总是按照2的次幂创建图片的原则，计算满足2的次幂的最小总图片大小
		int powerWidth = 1;
		int powerHeight = 1;
		while(true) {
			double area = Math.pow(2, powerWidth) * Math.pow(2, powerHeight);
			if (totalArea > area) {
				if (powerWidth <= powerHeight) {
					powerWidth++;
				} else {
					powerHeight++;
				}
			} else {
				break;
			}
		}
		atlasWidth.intValue = (int) Math.pow(2, powerWidth);
		atlasHeight.intValue = (int) Math.pow(2, powerHeight);
		Log.debug(TAG, "最终输出图片 宽=" + atlasWidth.intValue + ", 高=" + atlasHeight.intValue + ", 横向2的次幂=" + powerWidth + ", 纵向2的次幂=" + powerHeight);
		
		return sourceRects;
	}
	
	/**
	 * Java文件操作 获取文件扩展名 
	 * @param filename
	 * @return
	 */
	public static String GetExtensionName(String filename) {   
        if ((filename != null) && (filename.length() > 0)) {   
            int dot = filename.lastIndexOf('.');   
            if ((dot >-1) && (dot < (filename.length() - 1))) {   
                return filename.substring(dot + 1);   
            }   
        }   
        return filename;   
    }
	
	/**
	 * 
	 * 根据文件名获取文件名对应的ascii码，也即char 中的id
	 * 
	 * @param picName 如 a.png，对应的就是字母a对应的字体图片
	 * @return
	 * 		  ascii 码
	 */
	public static String GetCharId(String picName) {
		
		String id = "";
		String[] array = picName.split(".png");
		//Log.debug("picName=" + picName + ", array.len=" + array.length);
		String word = array[0];
		//Log.debug("word=" + word);
		id = GetASCII(word);
		return id;
	}
	
	/**
	 * 
	 * 将字符串转换为ascii码
	 * 
	 * @param word
	 * @return
	 * 		  ascii 码
	 */
	public static String GetASCII(String str) {
		
		String ascii = "";
		char[] chars = str.toCharArray();
		ascii = ascii + (int)chars[0];
		//Log.debug("str=" + str + ", ascii=" + ascii);
		return ascii;
	}
	
	/**
	 * 
	 * 第一行是对字体的介绍
	 * 
	 * @param face 				face=\"Interaction Times\"  字体名称 互动时代
	 * @param size 				size=32  					大小为32像素
	 * @param bold				bold=0 						不加粗
	 * @param italic			italic=0  					不适用斜体
	 * @param charset			charset=\"\"  				charset是编码字符集，这里没有填写值 即 使用默认
	 * @param unicode			unicode=0  					不适用Unicode
	 * @param stretchH			stretchH=100  				纵向缩放百分比
	 * @param smooth			smooth=1  					开启平滑
	 * @param aa				aa=1  						开启抗锯齿
	 * @param padding			padding=0,0,0,0  			内边距，文字与边框的空隙
	 * @param spacing			spacing=0,0  				外边距，就是相邻边缘的距离
	 * @return
	 * 		  info face="宋体" size=24 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0
	 */
	public static String GenInfo(String face, String size, String bold, 
			String italic, String charset, String unicode, String stretchH, 
			String smooth, String aa, String padding, String spacing) {
		
		String str = "info " +
					 "face=\"" + face + "\" " +
					 "size=" + size + " " +
					 "bold=" + bold + " " +
					 "italic=" + italic + " " +
					 "charset=\"" + charset + "\" " +
					 "unicode=" + unicode + " " +
					 "stretchH=" + stretchH + " " +
					 "smooth=" + smooth + " " +
					 "aa=" + aa + " " +
					 "padding=" + padding + " " +
					 "spacing=" + spacing + "\n";
		return str;
	}
	
	/**
	 * 
	 * 第二行是对应所有字贴图的公共信息
	 * 
	 * @param lineHeight			lineHeight=29	行高，如果遇到换行符时，绘制字体的位置坐标的y值在换行后增加的像素值
	 * @param base					base=23	 		字的基本大小
	 * @param scaleW				scaleW=2048		图片大小
	 * @param scaleH				scaleH=1024		图片大小
	 * @param pages					pages=1			此种字体用到了几张图
	 * @param packed				packed=0		图片不压缩
	 * @return
	 * 		  common lineHeight=29 base=23 scaleW=2048 scaleH=1024 pages=1 packed=0
	 */
	public static String GenCommon(String lineHeight, String base, String scaleW, String scaleH, String pages, String packed) {
		
		String str = "common " +
					 "lineHeight=" + lineHeight + " " +
					 "base=" + base + " " +
					 "scaleW=" + scaleW + " " +
					 "scaleH=" + scaleH + " " +
					 "pages=" + pages + " " +
					 "packed=" + packed + "\n";
		return str;
	}
	
	/**
	 * 
	 * 第三行是对应当前字贴图的信息
	 * 
	 * @param id			id=0				第一页
	 * @param file			file=\"it.png\"		贴图名称
	 * @return
	 * 		  page id=0 file="font_12.png"
	 */
	public static String GenPage(String id, String file) {
		
		String str = "page " +
					 "id=" + id + " " +
					 "file=\"" + file + "\"\n";
		return str;
	}
	
	/**
	 * 
	 * 第四行是字数
	 * 
	 * @param count			count=3593			当前贴图中所容纳的字体数量		
	 * @return
	 * 		  chars count=2
	 */
	public static String GenChars(String count) {
		
		String str = "chars " + 
					 "count=" + count + "\n";
		return str;
	}
	
	/**
	 * 
	 * 数据描述
	 * 
	 * @param id			id=32			第一个字符编码（ascii编码）为32， 也就是空格
	 * @param x				x=0				x位置为0
	 * @param y				y=0				y位置为0
	 * @param width			width=0			宽度为0
	 * @param height		height=0		高度为0
	 * @param xoffset		xoffset=0		绘制到屏幕的相应位置时，x像素偏移0
	 * @param yoffset		yoffset=0		绘制到屏幕的相应位置时，y像素偏移0
	 * @param xadvance		xadvance=12		绘制完成后相应位置的x往后移12个像素再画下一个字符
	 * @param page			page=0			字的图块在第一页上
	 * @param chnl			chnl=0			未知，默认0
	 * @return
	 * 		  char id=32   x=0     y=0     width=0     height=0     xoffset=0     yoffset=23    xadvance=12     page=0  chnl=0
	 */
	public static String GenChar(String id, String x, String y, String width, String height, 
			String xoffset, String yoffset, String xadvance, String page, String chnl) {
		
		String str = "char  " +
					 "id=" + id + "  " +
					 "x=" + x + "  " +
					 "y=" + y + "  " +
					 "width=" + width + "  " +
					 "height=" + height + "  " +
					 "xoffset=" + xoffset + "  " +
					 "yoffset=" + yoffset + "  " +
					 "xadvance=" + xadvance + "  " +
					 "page=" + page + "  " +
					 "chnl=" + chnl + "\n";
		return str;
	}

}
