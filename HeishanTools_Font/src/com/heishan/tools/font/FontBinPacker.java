package com.heishan.tools.font;

import java.util.ArrayList;
import java.util.List;

import com.heishan.tools.log.Log;

/**
 * 装箱算法类
 * 使用MaxRect算法实现，时间复杂度高，装箱空间浪费度低
 * 当前的算法，由于是提供给字体文件生成使用，图片不允许被旋转，所以没有做旋转判断
 * @author heishanlaoyao
 *
 */
public class FontBinPacker {
	
	private static final String TAG = FontBinPacker.class.getSimpleName();
	
	public static final int METHOD_RECT_BEST_SORT_SIDE_FIT = 0; 
	public static final int METHOD_RECT_BEST_LONG_SIDE_FIT = 1; 
	public static final int METHOD_RECT_BEST_AREA_FIT = 2;
	public static final int METHOD_RECT_BOTTOM_LEFT_RULE = 3;
	public static final int METHOD_RECT_CONTRACT_POINT_RULE = 4;
	
	private int binWidth = 0; // 装箱宽度
	private int binHeight = 0; // 装箱高度
	private boolean allowRotation = false;
	private List<FontRect> freeRects = new ArrayList<FontRect>(); // 还未使用的矩形
	private List<FontRect> packedRects = new ArrayList<FontRect>(); // 已经装箱的矩形
	
	/**
	 * 构造函数
	 */
	public FontBinPacker() { }
	
	/**
	 * 初始化函数
	 * @param binWidth
	 * @param binHeight
	 * @return 初始化成功，返回true；初始化失败，返回false；
	 */
	public boolean init(int binWidth, int binHeight) {
		// 检查输入参数
		if (binWidth <= 0 || binHeight <= 0) {
			Log.error(TAG, "init() unexpected bin width and height, binWidth=" + binWidth + ", binHeight=" + binHeight);
			return false;
		}
		
		// 输入参数赋值
		this.binWidth = binWidth;
		this.binHeight = binHeight;
		
		// 执行清理
		this.freeRects.clear();
		this.packedRects.clear();
		
		// 初始化第一个空间数据
		FontRect rootRect = new FontRect(0, "", this.binWidth, this.binHeight);
		this.freeRects.add(rootRect);
		
		return true;
	}
	
	/**
	 * 初始化函数
	 * @param binWidth
	 * @param binHeight
	 * @param allowRotation
	 * @return 初始化成功，返回true；初始化失败，返回false；
	 */
	public boolean init(int binWidth, int binHeight, boolean allowRotation) {
		this.allowRotation = allowRotation;
		return this.init(binWidth, binHeight);
	}
	
	/**
	 * 执行装箱
	 * @param rects 需要装箱的矩形
	 * @param method 装箱方法
	 * @return 是否装箱成功
	 */
	public boolean pack(List<FontRect> rects, int method) {
		// 最初记录需要装箱的图片数量
		int totalCount = rects.size();
		
		// 循环执行最优装箱
		while (rects.size() > 0) {
			int bestScore1 = Integer.MAX_VALUE;
			int bestScore2 = Integer.MAX_VALUE;
			int bestRectIndex = -1;
			FontRect bestRect = null;
			
			// 遍历寻找最佳的可放置矩形
			for (int i = 0; i < rects.size(); i++) {
				FontRect rect = rects.get(i);
				FontValue score1 = new FontValue(0);
				FontValue score2 = new FontValue(0);
				FontRect newRect = this.findPositionForNewRect(rect.width, rect.height, method, score1, score2);
				if (score1.intValue < bestScore1 || (score1.intValue == bestScore1 && score2.intValue < bestScore2)) {
					bestScore1 = score1.intValue;
					bestScore2 = score2.intValue;
					bestRect = newRect;
					bestRectIndex = i;
				}
			}
			
			Log.debug("1 this.packedRects.size()=" + this.packedRects.size() + ", totalCount=" + totalCount);
			
			// 没有找到最佳的放置位置，循环结束
			if (bestRectIndex == -1) {
				return (this.packedRects.size() == totalCount);
			}
			
			// 将图片数据进行赋值，否则无法生成图片
			bestRect.id = rects.get(bestRectIndex).id;
			bestRect.name = rects.get(bestRectIndex).name;
			bestRect.bufferedImage = rects.get(bestRectIndex).bufferedImage;
			
			// 将剩余的矩形空间进行切割
			int numRectsToProcess = this.freeRects.size();
			for (int i = 0; i < numRectsToProcess; i++) {
				if (this.splitRect(this.freeRects.get(i), bestRect)) {
					this.freeRects.remove(i);
					i--;
					numRectsToProcess--;
				}
			}
			
			// 将列表重新梳理
			this.pruneFreeRects();
			
			// 将已经装箱的矩形加入数组
			this.packedRects.add(bestRect);
			
			// 将已经装箱的数据移除数组
			rects.remove(bestRectIndex);
		}
		
		Log.debug("2 this.packedRects.size()=" + this.packedRects.size() + ", totalCount=" + totalCount);
		
		return (this.packedRects.size() == totalCount);
	}
	
	/**
	 * 获取已经装箱的矩形
	 * @return
	 */
	public List<FontRect> getPackedRects() {
		return this.packedRects;
	}
	
	/**
	 * 空间利用率
	 * @return
	 */
	public float occupancy() {
		long usedArea = 0;
		for (FontRect rect : this.packedRects) {
			usedArea += rect.width * rect.height;
		}
		return (float) usedArea / (float) (this.binWidth * this.binHeight);
	}
	
	/**
	 * 浪费的空间
	 * @return
	 */
	public int wastedBinArea() {
		long usedArea = 0;
		for (FontRect rect : this.packedRects) {
			usedArea += rect.width * rect.height;
		}
		return (int) ((long) (this.binWidth * this.binHeight) - usedArea);
	}
	
	/**
	 * 梳理未使用空间的数组，过滤有重叠的数据
	 */
	public void pruneFreeRects() {
		for (int i = 0; i < this.freeRects.size(); i++) {
			FontRect rectI = this.freeRects.get(i);
			for (int j = i + 1; j < this.freeRects.size(); j++) {
				FontRect rectJ = this.freeRects.get(j);
				if (rectI.isContain(rectJ)) {
					this.freeRects.remove(j);
					j--;
				}
				if (rectJ.isContain(rectI)) {
					this.freeRects.remove(i);
					i--;
					break;
				}
			}
		}
	}
	
	/**
	 * 切割矩形
	 * 根据packedRect切割freeRect
	 * @param freeRect
	 * @param packedRect
	 * @return
	 */
	public boolean splitRect(FontRect freeRect, FontRect packedRect) {
		if (packedRect.x >= freeRect.x + freeRect.width || 
				packedRect.x + packedRect.width <= freeRect.x ||
						packedRect.y >= freeRect.y + freeRect.height || 
								packedRect.y + packedRect.height <= freeRect.y) {
			return false;
		}
		
		if (packedRect.x < freeRect.x + freeRect.width && packedRect.x + packedRect.width > freeRect.x) {
			if (packedRect.y > freeRect.y && packedRect.y < freeRect.y + freeRect.height)
			{
				FontRect newRect = freeRect.clone();
				newRect.height = packedRect.y - newRect.y;
				this.freeRects.add(newRect);
			}

			if (packedRect.y + packedRect.height < freeRect.y + freeRect.height)
			{
				FontRect newRect = freeRect.clone();
				newRect.y = packedRect.y + packedRect.height;
				newRect.height = freeRect.y + freeRect.height - (packedRect.y + packedRect.height);
				this.freeRects.add(newRect);
			}
		}
		
		if (packedRect.y < freeRect.y + freeRect.height && packedRect.y + packedRect.height > freeRect.y)
		{
			if (packedRect.x > freeRect.x && packedRect.x < freeRect.x + freeRect.width)
			{
				FontRect newRect = freeRect.clone();
				newRect.width = packedRect.x - newRect.x;
				this.freeRects.add(newRect);
			}

			if (packedRect.x + packedRect.width < freeRect.x + freeRect.width)
			{
				FontRect newRect = freeRect.clone();
				newRect.x = packedRect.x + packedRect.width;
				newRect.width = freeRect.x + freeRect.width - (packedRect.x + packedRect.width);
				this.freeRects.add(newRect);
			}
		}

		return true;
	}
	
	/**
	 * 寻找最佳放置位置
	 * @param width
	 * @param height
	 * @param method
	 * @param score1
	 * @param score2
	 * @return
	 */
	public FontRect findPositionForNewRect(int width, int height, int method, FontValue score1, FontValue score2) {
		FontRect newRect = null;
		score1.intValue = Integer.MAX_VALUE;
		score2.intValue = Integer.MAX_VALUE;
		
		switch (method) {
		case METHOD_RECT_BEST_SORT_SIDE_FIT:
			newRect = this.findPositionForNewRectBestShortSideFit(width, height, score1, score2); 
			break;
		case METHOD_RECT_BEST_LONG_SIDE_FIT:
			newRect = this.findPositionForNewRectBestLongSideFit(width, height, score2, score1);
			break;
		case METHOD_RECT_BEST_AREA_FIT:
			newRect = this.findPositionForNewRectBestAreaFit(width, height, score1, score2);
			break;
		case METHOD_RECT_BOTTOM_LEFT_RULE:
			newRect = this.findPositionForNewRectBottomLeftRule(width, height, score1, score2);
			break;
		case METHOD_RECT_CONTRACT_POINT_RULE:
			newRect = this.findPositionForNewRectContractPointRule(width, height, score1);
			break;
		}
		
		if (newRect == null || newRect.height == 0) {
			score1.intValue = Integer.MAX_VALUE;
			score2.intValue = Integer.MAX_VALUE;
		}
		
		return newRect;
	}
	
	/**
	 * 寻找最佳放置位置-短边优先
	 * @param width
	 * @param height
	 * @param bestShortSideFit
	 * @param bestLongSideFit
	 * @return
	 */
	public FontRect findPositionForNewRectBestShortSideFit(int width, int height, FontValue bestShortSideFit, FontValue bestLongSideFit) {
		FontRect bestRect = new FontRect();
		bestShortSideFit.intValue = Integer.MAX_VALUE;
		
		for (int i = 0; i < this.freeRects.size(); i++) {
			FontRect rect = this.freeRects.get(i);
			if (rect.width >= width && rect.height >= height) {
				int leftOverHoriz = Math.abs(rect.width - width);
				int leftOverVert = Math.abs(rect.height - height);
				int shortSideFit = Math.min(leftOverHoriz, leftOverVert);
				int longSideFit = Math.max(leftOverHoriz, leftOverVert);
				if (shortSideFit < bestShortSideFit.intValue || (shortSideFit == bestShortSideFit.intValue && longSideFit < bestLongSideFit.intValue)) {
					bestRect.x = rect.x;
					bestRect.y = rect.y;
					bestRect.width = width;
					bestRect.height = height;
					bestShortSideFit.intValue = shortSideFit;
					bestLongSideFit.intValue = longSideFit;
				}
			}
			if (this.allowRotation) {
				if (rect.width >= height && rect.height >= width) {
					int flippedLeftOverHoriz = Math.abs(rect.width - height);
					int flippedLeftOverVert = Math.abs(rect.height - width);
					int flippedShortSideFit = Math.min(flippedLeftOverHoriz, flippedLeftOverVert);
					int flippedLongSideFit = Math.max(flippedLeftOverHoriz, flippedLeftOverVert);
					if (flippedShortSideFit < bestShortSideFit.intValue || (flippedShortSideFit == bestShortSideFit.intValue && flippedLongSideFit < bestLongSideFit.intValue)) {
						bestRect.x = rect.x;
						bestRect.y = rect.y;
						bestRect.width = height;
						bestRect.height = width;
						bestShortSideFit.intValue = flippedShortSideFit;
						bestLongSideFit.intValue = flippedLongSideFit;
					}
				}
			}
		}
		
		return bestRect;
	}
	
	/**
	 * 寻找最佳放置位置-长边优先
	 * @param width
	 * @param height
	 * @param bestLongSideFit
	 * @param bestShortSideFit
	 * @return
	 */
	public FontRect findPositionForNewRectBestLongSideFit(int width, int height, FontValue bestLongSideFit, FontValue bestShortSideFit) {
		FontRect bestRect = new FontRect();
		bestLongSideFit.intValue = Integer.MAX_VALUE;
		
		for (int i = 0; i < this.freeRects.size(); i++) {
			FontRect rect = this.freeRects.get(i);
			if (rect.width >= width && rect.height >= height) {
				int leftOverHoriz = Math.abs(rect.width - width);
				int leftOverVert = Math.abs(rect.height - height);
				int shortSideFit = Math.min(leftOverHoriz, leftOverVert);
				int longSideFit = Math.max(leftOverHoriz, leftOverVert);
				if (longSideFit < bestLongSideFit.intValue || (longSideFit == bestLongSideFit.intValue && shortSideFit < bestShortSideFit.intValue)) {
					bestRect.x = rect.x;
					bestRect.y = rect.y;
					bestRect.width = width;
					bestRect.height = height;
					bestShortSideFit.intValue = shortSideFit;
					bestLongSideFit.intValue = longSideFit;
				}
			}
			if (this.allowRotation) {
				if (rect.width >= height && rect.height >= width) {
					int leftOverHoriz = Math.abs(rect.width - height);
					int leftOverVert = Math.abs(rect.height - width);
					int shortSideFit = Math.min(leftOverHoriz, leftOverVert);
					int longSideFit = Math.max(leftOverHoriz, leftOverVert);
					if (longSideFit < bestLongSideFit.intValue || (longSideFit == bestLongSideFit.intValue && shortSideFit < bestShortSideFit.intValue)) {
						bestRect.x = rect.x;
						bestRect.y = rect.y;
						bestRect.width = height;
						bestRect.height = width;
						bestShortSideFit.intValue = shortSideFit;
						bestLongSideFit.intValue = longSideFit;
					}
				}
			}
		}
		
		return bestRect;
	}
	
	/**
	 * 寻找最佳放置位置-面积优先 
	 * @param width
	 * @param height
	 * @param bestAreaFit
	 * @param bestShortSideFit
	 * @return
	 */
	public FontRect findPositionForNewRectBestAreaFit(int width, int height, FontValue bestAreaFit, FontValue bestShortSideFit) {
		FontRect bestRect = new FontRect();
		bestAreaFit.intValue = Integer.MAX_VALUE;
		
		for (int i = 0; i < this.freeRects.size(); i++) {
			FontRect rect = this.freeRects.get(i);
			int areaFit = rect.width * rect.height - width * height;
			if (rect.width >= width && rect.height >= height) {
				int leftOverHoriz = Math.abs(rect.width - width);
				int leftOverVert = Math.abs(rect.height - height);
				int shortSideFit = Math.min(leftOverHoriz, leftOverVert);
				if (areaFit < bestAreaFit.intValue || (areaFit == bestAreaFit.intValue && shortSideFit < bestShortSideFit.intValue)) {
					bestRect.x = rect.x;
					bestRect.y = rect.y;
					bestRect.width = width;
					bestRect.height = height;
					bestShortSideFit.intValue = shortSideFit;
					bestAreaFit.intValue = areaFit;
				}
			}
			if (this.allowRotation) {
				if (rect.width >= height && rect.height >= width) {
					int leftOverHoriz = Math.abs(rect.width - height);
					int leftOverVert = Math.abs(rect.height - width);
					int shortSideFit = Math.min(leftOverHoriz, leftOverVert);
					if (areaFit < bestAreaFit.intValue || (areaFit == bestAreaFit.intValue && shortSideFit < bestShortSideFit.intValue)) {
						bestRect.x = rect.x;
						bestRect.y = rect.y;
						bestRect.width = height;
						bestRect.height = width;
						bestShortSideFit.intValue = shortSideFit;
						bestAreaFit.intValue = areaFit;
					}
				}
			}
		}
		
		return bestRect;
	}
	
	public FontRect findPositionForNewRectBottomLeftRule(int width, int height, FontValue bestY, FontValue bestX) {
		FontRect bestRect = new FontRect();
		bestY.intValue = Integer.MAX_VALUE;
		
		for (int i = 0; i < this.freeRects.size(); i++) {
			FontRect rect = this.freeRects.get(i);
			if (rect.width >= width && rect.height >= height) {
				int topSideY = rect.y + height;
				if (topSideY < bestY.intValue || (topSideY == bestY.intValue && rect.x < bestX.intValue)) {
					bestRect.x = rect.x;
					bestRect.y = rect.y;
					bestRect.width = width;
					bestRect.height = height;
					bestY.intValue = topSideY;
					bestX.intValue = rect.x;
				}
			} 
			if (this.allowRotation) {
				if (rect.width >= height && rect.height >= width) {
					int topSideY = rect.y + width;
					if (topSideY < bestY.intValue || (topSideY == bestY.intValue && rect.x < bestX.intValue)) {
						bestRect.x = rect.x;
						bestRect.y = rect.y;
						bestRect.width = height;
						bestRect.height = width;
						bestY.intValue = topSideY;
						bestX.intValue = rect.x;
					}
				}
			}
		}
		
		return bestRect;
	}
	
	public FontRect findPositionForNewRectContractPointRule(int width, int height, FontValue bestContractScore) {
		FontRect bestRect = new FontRect();
		bestContractScore.intValue = -1;
		
		for (int i = 0; i < this.freeRects.size(); i++) {
			FontRect rect = this.freeRects.get(i);
			// Try to place the rectangle in upright (non-flipped) orientation.
			if (rect.width >= width && rect.height >= height) {
				int score = this.contactPointScoreRect(rect.x, rect.y, width, height);
				if (score > bestContractScore.intValue) {
					bestRect.x = rect.x;
					bestRect.y = rect.y;
					bestRect.width = width;
					bestRect.height = height;
					bestContractScore.intValue = score;
				}
			}
			if (this.allowRotation) {
				if (rect.width >= height && rect.height >= width) {
					int score = this.contactPointScoreRect(rect.x, rect.y, width, height);
					if (score > bestContractScore.intValue) {
						bestRect.x = rect.x;
						bestRect.y = rect.y;
						bestRect.width = height;
						bestRect.height = width;
						bestContractScore.intValue = score;
					}
				}
			}
		}
		
		return bestRect;
	}
	
	public int contactPointScoreRect(int x, int y, int width, int height) {
		int score = 0;
		if (x == 0 || x + width == this.binWidth) {
			score += height;
		}
		if (y == 0 || y + height == this.binHeight) {
			score += width;
		}
		for (int i = 0; i < this.packedRects.size(); i++) {
			FontRect rect = this.packedRects.get(i);
			if (rect.x == x + width || rect.x + rect.width == x) {
				score += this.commonIntervalLength(rect.y, rect.y + rect.height, y, y + height);
			}
			if (rect.y == y + height || rect.y + rect.height == y) {
				score += this.commonIntervalLength(rect.x, rect.x + rect.width, x, x + width);
			}
		}
		return score;
	}
	
	public int commonIntervalLength(int i1start, int i1end, int i2start, int i2end) {
		if (i1end < i2start || i2end < i1start) {
			return 0;
		}
		return (Math.min(i1end, i2end) - Math.max(i1start, i2start));
	}
	
}
