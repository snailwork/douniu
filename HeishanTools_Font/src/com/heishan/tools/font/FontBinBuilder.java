package com.heishan.tools.font;

import java.util.ArrayList;
import java.util.List;

import com.heishan.tools.log.Log;

/**
 * 装箱执行者，反复执行装箱算法以求最佳的装箱结果，时间复杂度高
 * @author heishanlaoyao
 *
 */
public class FontBinBuilder {
	
	private static final String TAG = FontBinBuilder.class.getSimpleName();
	
	public int atlasWidth = 0; // 输出图片宽度
	public int atlasHeight = 0; // 输出图片高度
	public List<FontRect> sourceRects;// 源数据
	public List<FontRect> packedRects;// 已装箱
 	
	public FontBinBuilder() {}
	
	public void init(int atlasWidth, int atlasHeight, List<FontRect> rects) {
		this.atlasWidth = atlasWidth;
		this.atlasHeight = atlasHeight;
		this.sourceRects = new ArrayList<FontRect>(rects);
	}
	
	/**
	 * 执行最佳装箱，返回未装箱成功的数据
	 */
	public boolean build() {
		FontBinPacker binPacker = this.findBestBinPacker(this.atlasWidth, this.atlasHeight, this.sourceRects);
		if (binPacker == null) {
			Log.error(TAG, "build() build fail.");
			return false;
		} else {
			this.packedRects = new ArrayList<FontRect>(binPacker.getPackedRects());
			return true;
		}
	}
	
	/**
	 * 寻找最佳的装箱算法
	 * @param width
	 * @param height
	 * @param currentRects
	 * @param allUsed
	 * @return
	 */
	public FontBinPacker findBestBinPacker(int width, int height, List<FontRect> currentRects) {
		List<FontBinPacker> binPackers = new ArrayList<FontBinPacker>();
		Integer[] binPackerMethods = {
				FontBinPacker.METHOD_RECT_BEST_AREA_FIT,
				FontBinPacker.METHOD_RECT_BEST_SORT_SIDE_FIT,
				FontBinPacker.METHOD_RECT_BEST_LONG_SIDE_FIT,
				FontBinPacker.METHOD_RECT_BOTTOM_LEFT_RULE,
				FontBinPacker.METHOD_RECT_CONTRACT_POINT_RULE
		};
		boolean[] binPackerSuccesseds = new boolean[binPackerMethods.length];
		
		for (int i = 0; i < binPackerMethods.length; i++) {
			List<FontRect> rects = new ArrayList<FontRect>(currentRects);
			FontBinPacker binPack = new FontBinPacker();
			boolean initResult = binPack.init(width, height);
			if (initResult) {
				binPackerSuccesseds[i] = binPack.pack(rects, binPackerMethods[i]);
				binPackers.add(binPack);
			}
		}
		
		int leastWastedArea = Integer.MAX_VALUE;
		int leastWastedIndex = -1;
		for (int i = 0; i < binPackers.size(); i++) {
			FontBinPacker binPacker = binPackers.get(i);
			int wastedArea = binPacker.wastedBinArea();
			if (wastedArea < leastWastedArea && binPackerSuccesseds[i]) {
				leastWastedIndex = i;
			}
		}
		
		if (leastWastedIndex == -1) {
			Log.error(TAG, "findBestBinPacker() fail to find best packer.");
			return null;
		} else {
			return binPackers.get(leastWastedIndex);
		}
	}
	
	/**
	 * 获取装箱后的数据
	 * @return
	 */
	public List<FontRect> getPackedRects() {
		return this.packedRects;
	}

}
