
clc ;
clear all;

srcDir=uigetdir('C:\Users\qiqi\Desktop\图像增强代码\颜色校正\颜色恒常\'); %获得选择的文件夹
cd(srcDir) ;
allnames=struct2cell(dir('*.bmp')); 
[k,img_number]=size(allnames); %获得图片文件的个数

store_path2 = 'C:\Users\qiqi\Desktop\图像增强代码\颜色校正\颜色恒常\颜色恒常结果图\' ;

for number=1 : img_number    %逐次取出文件
    
img_name=allnames{1,number};
RGB_img=imread( img_name);
input_im = double( RGB_img ); 

% figure(1);
% imshow( uint8( input_im ) );
% title( 'Input image' );

% Grey-World
[wR, wG, wB, out1] = general_cc( input_im, 0, 1, 0 );
% figure(2);
% imshow( uint8( out1 ) );
% title( 'Grey-World' );
imwrite(uint8( out1 ), [store_path2,  'GW', img_name]) ;

% max-RGB
[wR, wG, wB, out2] = general_cc( input_im, 0, -1, 0 );
% figure(3);
% imshow( uint8( out2 ) );
% title( 'max-RGB' );
imwrite(uint8( out2 ), [store_path2,  'max-RGB', img_name]) ;

% Shades of Grey (mink_norm can be any number between 1 and infinity)
mink_norm = 5;
[wR, wG, wB, out3] = general_cc( input_im, 0, mink_norm, 0);
% figure(4);
% imshow( uint8( out3 ) );
% title( 'Shades of Grey' );
imwrite(uint8( out3 ), [store_path2,  'SG', img_name]) ;

% Grey-Edge (diff_order = 1 or 2, for 1st-order or 2nd-order derivative, using filter-size sigma)
mink_norm = 5;
sigma = 2;
diff_order = 1;
[wR, wG, wB, out4] = general_cc( input_im, diff_order, mink_norm, sigma );
% figure(5);
% imshow( uint8( out4 ) );
% title( 'Grey-Edge' );
imwrite(uint8( out4 ), [store_path2,  'GE', img_name]) ;

% Weighted Grey-Edge (kappa determines the weight given to the weight-map)
mink_norm = 5;
sigma = 2;
diff_order = 1;
kappa = 10; 
[wR, wG, wB, out5] = weightedGE( input_im, kappa, mink_norm, sigma );
% figure(6);
% imshow( uint8( out5 ) );
% title( 'Weighted Grey-Edge' );
imwrite(uint8( out5 ), [store_path2,  'WGE', img_name]) ;

end

