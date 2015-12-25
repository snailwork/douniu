package com.heishan.tools.font;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GridLayout;
import java.awt.Panel;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.JToolBar;

import com.heishan.tools.log.Log;

public class FontMain extends JFrame implements ActionListener {
	
	public static final String VERSION = "V2.0";
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// 启动模拟器
		new Thread(new Runnable() {
			@Override
			public void run() {
				new FontMain();
			}}).start();
	}
	
	//private static final int FONT_SIZE = 30; // 字体大小
	private static final int FRAME_WIDTH = 600; // 窗口宽度
	private static final int FRAME_HEIGHT = 550; // 窗口高度
	private static final long serialVersionUID = 1L; // 其它
	
	private JTextField 	textFieldSpaceWidth, // 空格宽度
						textFieldDefaultHeight, // 字体文件默认高度
    					textFieldInPath, // 输入路径
    					textFieldOutPath, // 输出路径
    					textFieldFontName; // 字体名称
	private JButton btnInPath, // 打开输入路径
					btnOutPath, // 打开输出路径
					btnGenerate; // 生成字体
	
	/**
	 * 构造函数
	 */
	private FontMain() {
		this.setTitle("font字体生成工具" + VERSION);
		this.setSize(FRAME_WIDTH, FRAME_HEIGHT);
		this.setLocation(100, 100);
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setLayout(new BorderLayout());
		this.initPanelConfig();
		this.setVisible(true);
		this.setResizable(false);
		this.setBackground(Color.GRAY);
		
		this.initAbout();
	}
	
	private void initAbout() {  
		JToolBar toolBar = new JToolBar("JToolBar");
		JButton btnAbout = new JButton("About");
		toolBar.add(btnAbout);
		btnAbout.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				JOptionPane.showMessageDialog(null, "Author: 黑山老妖");
			}
		});        
		this.add(toolBar, BorderLayout.NORTH);
		toolBar.setVisible(true);
		toolBar.setFloatable(false);
	}
	
	private void initPanelConfig() {
		// 创建顶部
		Panel panelConfig = new Panel(new GridLayout(10, 1));
		
		Panel panelInfo = new Panel(new GridLayout(1, 4));
		// 空格宽度
		JLabel labelSpaceWidth = new JLabel("  空格宽度:");
		panelInfo.add(labelSpaceWidth);
		this.textFieldSpaceWidth = new JTextField();
		this.textFieldSpaceWidth.setText("0");
		panelInfo.add(this.textFieldSpaceWidth);
		// 字体默认高度
		JLabel labelDefaultHeight = new JLabel("  默认高度:");
		panelInfo.add(labelDefaultHeight);
		this.textFieldDefaultHeight = new JTextField();
		this.textFieldDefaultHeight.setText("0");
		panelInfo.add(this.textFieldDefaultHeight);
		panelConfig.add(panelInfo);
		panelInfo.setVisible(true);
		
		// 输入文件路径
		JLabel labelInPath = new JLabel("  输入文件路径:");
		panelConfig.add(labelInPath);
		Panel panelInPath = new Panel(new BorderLayout());
		this.textFieldInPath = new JTextField("./font_in");
		panelInPath.add(this.textFieldInPath);
		this.btnInPath = new JButton("打开");
		this.btnInPath.addActionListener(this);
		panelInPath.add(this.btnInPath, BorderLayout.EAST);
		panelConfig.add(panelInPath);
		panelInPath.setVisible(true);
		
		// 输出文件路径
		JLabel labelOutPath = new JLabel("  输出文件路径:");
		panelConfig.add(labelOutPath);
		Panel panelOutPath = new Panel(new BorderLayout());
		this.textFieldOutPath = new JTextField("./font_out");
		panelOutPath.add(this.textFieldOutPath);
		this.btnOutPath = new JButton("打开");
		this.btnOutPath.addActionListener(this);
		panelOutPath.add(this.btnOutPath, BorderLayout.EAST);
		panelConfig.add(panelOutPath);
		panelOutPath.setVisible(true);
		
		// 输入font名称
		JLabel labelFontName = new JLabel("  字体名称:");
		panelConfig.add(labelFontName);
		Panel panelFontName = new Panel(new GridLayout(1, 2));
		this.textFieldFontName = new JTextField("heishan");
		panelFontName.add(this.textFieldFontName);
		this.btnGenerate = new JButton("生成字体");
		this.btnGenerate.addActionListener(this);
		panelFontName.add(this.btnGenerate);
		panelConfig.add(panelFontName);
		panelFontName.setVisible(true);
		
		// 帮助信息
		Panel panelHelp = new Panel(new BorderLayout());
		JTextArea textAreaHelp = new JTextArea();
		textAreaHelp.setLineWrap(true);
		textAreaHelp.append("使用说明:\n");
		textAreaHelp.append("1.本软件功能是将散碎的字体图片整合为.fnt配置文件和.png图片文件。设置输入文件路径，设置输出文件路径，输入字体名称，生成的字体名称同输入字体名称，点击“生成字体”按钮生成字体。\n");
		textAreaHelp.append("2.在输入文件路径中存放的散碎字体图片，最好保证所有的图片大小相同，文件名称为.fnt文件中对应图片的唯一标识（ASCII码），例如a.png，在使用.fnt文件时输入“a”即可显示对应的a.png图片。\n");
		textAreaHelp.append("3.空格宽度是你希望空格占用的宽度，默认为0.默认高度是最终生成的字体文件加载到界面中BMFont的默认高度，由于此高度是统一设定，不能根据显示字体的不同而动态修改，到底设置为多少需要自己斟酌实际的应用场景，默认高度为0，生成的BMFont的高度将为0。注意，字体图片（不是BMFont控件）的默认锚点是左上角，所以字体图片将以BMFont的左上角为顶点进行显示。\n");
		textAreaHelp.append("4.选定输入路径之后，会根据路径中图片自动生成‘空格宽度’和‘默认高度’，生成规则是查找图片中最宽图片宽度为‘空格宽度’，查找图片中最高高度为‘默认高度’。‘空格宽度’顾名思义，就是空格所占的像素宽度。‘默认高度’指的是生成的fnt描述文件头中‘lineHeight’属性值，这个值定义了最终显示的UI控件（cocos2dx中BMFontLabel）的默认高度，这个属性可以根据自己的需要自定义。建议生成字体使用的碎图，最好是统一的高度和宽度，否则会出现莫名其妙的坐标偏差。\n");
		textAreaHelp.append("5.注意，散碎图片的命名将决定最终在BMFont控件的显示规则，比如数字1的图片最好命名为1.png，命名只支持单词，不支持词组，比如命名为“猪八戒”，最终图片对应的汉字的ASCII只有“猪”。\n");
		textAreaHelp.setEditable(false);
		textAreaHelp.setBounds(5, 0, FRAME_WIDTH - 10, FRAME_HEIGHT / 2);
		textAreaHelp.setFocusable(false);
		textAreaHelp.setBackground(this.getBackground());
		panelHelp.add(textAreaHelp, BorderLayout.CENTER);
		
		panelHelp.add(new JLabel("  "), BorderLayout.WEST);
		panelHelp.add(new JLabel(""), BorderLayout.EAST);
		
		this.add(panelHelp, BorderLayout.SOUTH);
		panelHelp.setVisible(true);
		
		this.add(panelConfig, BorderLayout.CENTER);
		panelConfig.setVisible(true);
		
		String inPath = System.getProperty("user.dir") + "/font_in/";
		this.refreshFontInfo(inPath);
	}
	
	private void refreshFontInfo(String inPath) {
		File directory = new File(inPath);
		String[] files = directory.list(); // 获取图片文件名称
		List<String> pics = new ArrayList<String>();
		for (String filename : files) {
			String ext = FontUtil.GetExtensionName(filename);
			if (ext == "png" || ext.equals("png") || ext == "jpg" || ext.equals("jpg")) {
				pics.add(filename);
			}
		}
		int len = pics.size();
		if(len < 1) {
			//Log.error("no file in path, inPath=" + inPath);
			return;
		}
		int spaceWidth = 0;
		int fontHeight = 0;
		// 生成图片信息数组
		for(int i = 0; i < len; i++) {
			try {
				File file = new File(inPath + "/" + pics.get(i));
				BufferedImage bufferedImage = ImageIO.read(file);
				if (bufferedImage.getWidth() > spaceWidth) {
					spaceWidth = bufferedImage.getWidth();
				}
				if (bufferedImage.getHeight() > fontHeight) {
					fontHeight = bufferedImage.getHeight();
				}
			} catch(Exception e) {
				System.out.println(inPath);
				e.printStackTrace();
			}
		}
		this.textFieldSpaceWidth.setText(spaceWidth + "");
		this.textFieldDefaultHeight.setText(fontHeight + "");
	}
	
	@Override
	public void actionPerformed(ActionEvent ae) {
		if(ae.getSource() == btnInPath) {
			JFileChooser fc = new JFileChooser();
			fc.setCurrentDirectory(new File("."));
			fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
			fc.showOpenDialog(null);
			File file = fc.getSelectedFile();
			if (file != null) {
				Log.debug("输入文件路径: " + file.getAbsolutePath());
				this.textFieldInPath.setText(file.getAbsolutePath());
				
				this.refreshFontInfo(file.getAbsolutePath());
			}
		} else if (ae.getSource() == btnOutPath) {
			JFileChooser fc = new JFileChooser();
			fc.setCurrentDirectory(new File("."));
			fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
			fc.showOpenDialog(null);
			File file = fc.getSelectedFile();
			if (file != null) {
				Log.debug("输出文件路径: " + file.getAbsolutePath());
				this.textFieldOutPath.setText(file.getAbsolutePath());
			}
		} else if (ae.getSource() == btnGenerate) {
			String spaceWidthStr = this.textFieldSpaceWidth.getText();
			int spaceWidth = 0;
			try {
				spaceWidth = Integer.valueOf(spaceWidthStr);
				if (spaceWidth < 0) {
					JOptionPane.showMessageDialog(null, "请输入正确的空格宽度，必须正整数", "错误提示", JOptionPane.ERROR_MESSAGE);
					return;
				}
			} catch (Exception e) {
				JOptionPane.showMessageDialog(null, "请输入正确的空格宽度，必须正整数", "错误提示", JOptionPane.ERROR_MESSAGE);
				return;
			}

			String defaultHeightStr = this.textFieldDefaultHeight.getText();
			int defaultHeight = 0; 
			try {
				defaultHeight = Integer.valueOf(defaultHeightStr);
				if (defaultHeight < 0) {
					JOptionPane.showMessageDialog(null, "请输入正确的字体默认高度，必须正整数", "错误提示", JOptionPane.ERROR_MESSAGE);
					return;
				}
			} catch(Exception e) {
				JOptionPane.showMessageDialog(null, "请输入正确的字体默认高度，必须正整数", "错误提示", JOptionPane.ERROR_MESSAGE);
				return;
			}
			
			if (this.textFieldInPath.getText() == "" || this.textFieldInPath.getText().equals("")) {
				Log.debug("输入文件路径为空");
				JOptionPane.showMessageDialog(null, "输入文件路径为空", "错误提示", JOptionPane.ERROR_MESSAGE);
			} else if (this.textFieldOutPath.getText() == "" || this.textFieldOutPath.getText().equals("")) {
				Log.debug("输出文件路径为空");
				JOptionPane.showMessageDialog(null, "输出文件路径为空", "错误提示", JOptionPane.ERROR_MESSAGE);
			} else if (this.textFieldFontName.getText() == "" || this.textFieldFontName.getText().equals("")) {
				Log.debug("字体名称为空");
				JOptionPane.showMessageDialog(null, "字体名称为空", "错误提示", JOptionPane.ERROR_MESSAGE);
			} else {
				if (new File(this.textFieldInPath.getText()).exists()) {
					if (new File(this.textFieldInPath.getText()).isDirectory()) {
						if (new File(this.textFieldOutPath.getText()).exists()) {
							if (new File(this.textFieldOutPath.getText()).isFile()) {
								new File(this.textFieldOutPath.getText()).delete();
								new File(this.textFieldOutPath.getText()).mkdir();
							}
						} else {
							new File(this.textFieldOutPath.getText()).mkdir();
						}
						
						String fontName = this.textFieldFontName.getText();
						String inPath = this.textFieldInPath.getText() + "/";
						String outPath = this.textFieldOutPath.getText() + "/";
						int errorCode = FontUtil.GenFont(fontName, inPath, outPath, spaceWidth, defaultHeight);
						if (errorCode == FontUtil.ERROR_CODE_SUCCESS) {
							JOptionPane.showMessageDialog(null, "字体生成成功！", "完成提示", JOptionPane.PLAIN_MESSAGE);
						} else if (errorCode == FontUtil.ERROR_CODE_NO_FONT_IMAGE) {
							JOptionPane.showMessageDialog(null, "输入文件路径中没有字体图片文件", "错误提示", JOptionPane.ERROR_MESSAGE);
						} else if (errorCode == FontUtil.ERROR_CODE_READ_FONT_IMAGE_EXCEPTION) {
							JOptionPane.showMessageDialog(null, "读取字体图片文件出现错误，请确保输入字体图片格式正确", "错误提示", JOptionPane.ERROR_MESSAGE);
						} else if (errorCode == FontUtil.ERROR_CODE_WRITE_FONT_IMAGE_EXCEPTION) {
							JOptionPane.showMessageDialog(null, "生成字体图片文件出现错误，请确保输入字体图片格式正确", "错误提示", JOptionPane.ERROR_MESSAGE);
						} else if (errorCode == FontUtil.ERROR_CODE_WRITE_FONT_CONFIG_EXCEPTION) {
							JOptionPane.showMessageDialog(null, "生成字体文件fnt出现错误，请确保输入字体图片文件名正确", "错误提示", JOptionPane.ERROR_MESSAGE);
						} else {
							JOptionPane.showMessageDialog(null, "生成字体文件出现错误", "错误提示", JOptionPane.ERROR_MESSAGE);
						}
					} else {
						Log.debug("不是文件夹");
						JOptionPane.showMessageDialog(null, "输入文件路径不是文件夹", "错误提示", JOptionPane.ERROR_MESSAGE);
					}
				} else {
					Log.debug("文件夹不存在");
					JOptionPane.showMessageDialog(null, "输入文件路径不存在", "错误提示", JOptionPane.ERROR_MESSAGE);
				}
			}
		}
	}
	
}
