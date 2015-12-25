package com.heishan.tools.log;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * 日志打印输出类，可以将日志写入文件
 * @author heishanlaoyao
 *
 */
public class Log {

	private final static String LOG_FILE_NAME = "HSTools.log";
	private final static boolean IS_LOG_FILE = false;

	/**
	 * 打印多个对象信息到文件
	 * 
	 * @param objs
	 */
	/*
	public static void objsToFile(Object... objs) {
		mPrintWriter.println(" Objects start .......");
		for (Object obj : objs) {
			mPrintWriter.println(obj);
		}
		mPrintWriter.println(" Objects end .......");
	}
	*/

	/**
	 * debug日志
	 * @param tag
	 * @param obj
	 */
	public static void debug(Object obj) {
		System.out.println("[ debug ] : " + obj + "");
		// 日志输出到控制台
		//write2file(obj);
	}
	
	/**
	 * debug日志
	 * @param TAG
	 * @param obj
	 */
	public static void debug(String TAG, Object obj) {
		System.out.println("[ debug ][ " + TAG + " ] : " + obj + "");
		// 日志输出到控制台
		//write2file(obj);
	}
	
	/**
	 * warn日志
	 * @param tag
	 * @param obj
	 */
	public static void warn(Object obj) {
		System.out.println("[ warn ] : " + obj + "");
		// 日志输出到控制台
		//write2file(obj);
	}
	
	/**
	 * warn日志
	 * @param TAG
	 * @param obj
	 */
	public static void warn(String TAG, Object obj) {
		System.out.println("[ warn ][ " + TAG + " ] : " + obj + "");
		// 日志输出到控制台
		//write2file(obj);
	}
	
	/**
	 * error日志
	 * @param tag
	 * @param obj
	 */
	public static void error(Object obj) {
		System.err.println("[ error ] : " + obj + "");
		// 日志输出到控制台
		//write2file(obj);
	}
	
	/**
	 * error日志
	 * @param TAG
	 * @param obj
	 */
	public static void error(String TAG, Object obj) {
		System.err.println("[ error ][ " + TAG + " ] : " + obj + "");
		// 日志输出到控制台
		//write2file(obj);
	}
	
	/**
	 * 写入文件
	 * @param obj
	 */
	protected static void write2file(Object obj) {
		if (IS_LOG_FILE) {
			String path = System.getProperty("user.dir");
			String filename = path + "/" + LOG_FILE_NAME;
			File file = new File(filename);  
	        FileWriter fileWriter = null;  
	        PrintWriter printWriter = null;  
	        try {
	        	fileWriter = new FileWriter(file,true);  
	            printWriter = new PrintWriter(fileWriter);  
	            
	        	SimpleDateFormat sdf = new SimpleDateFormat("YYYY/MM/DD HH:mm:ss - ", Locale.SIMPLIFIED_CHINESE);
	        	printWriter.print(sdf.format(new Date()));
				StackTraceElement[] stacks = new Throwable().getStackTrace();
				printWriter.println(stacks[1].getClassName() + "-" + stacks[1].getMethodName() + " line " + stacks[1].getLineNumber() + "  :  " + obj);
				printWriter.flush();
				
				printWriter.close();  
	            fileWriter.close(); 
			} catch (Exception e) {
				error(e.getLocalizedMessage());
			} finally {
				if (printWriter != null){  
	                printWriter.close();  
	            }  
	            if (fileWriter != null){  
	               try {  
	            	   fileWriter.close();  
	               } catch (IOException e) { 
	            	   error(e.getLocalizedMessage());
	               }  
	            }  
			}
		}
	}
}
