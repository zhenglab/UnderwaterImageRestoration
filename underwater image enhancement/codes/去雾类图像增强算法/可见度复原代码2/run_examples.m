clc ;
clear all;

srcDir=uigetdir('D:\图像复原代码\代码\去雾类\Tarel-visibresto2\'); %获得选择的图片
cd(srcDir) ;
allnames=struct2cell(dir('*.bmp')); %只获取8位的bmp图片
[k,img_number]=size(allnames); %获得图片文件的个数

store_path = 'D:\图像复原代码\代码\去雾类\Tarel-visibresto2\处理后的图片\' ;%处理后的图片存储路径

for number=1 : img_number    %逐次取出文件
    
    img_name=allnames{1,number};
    input=imread( img_name);

% Gray level example of visibility restoration
im=double(imread( img_name))/255.0;
sv=2*floor(max(size(im))/25)+1;
% ICCV'2009 paper result (NBPC)
res=visibresto(im,sv,0.95,-1,1,1.0);
 %figure;imshow([im, res],[0,1]);
% IV'2010 paper result (NBPC+PA)
res2=visibresto1(im,sv,0.95,-1,1,1.0,70,200);
 %figure;imshow([im, res2],[0,1]);


% % Color example of visibility restoration
 %im=double(imread('sweden.jpg'))/255.0;
 %sv=2*floor(max(size(im))/50)+1;
% % ICCV'2009 paper result (NBPC)
%res3=nbpc(im,sv,0.95,0.5,1,1.3);
% figure;imshow([im, res3],[0,1]);
% % IV'2010 paper result (NBPC+PA)
% res4=nbpcpa(im,sv,0.95,0.5,1,1.3,205,300);
% figure;imshow([im, res4],[0,1]);


 imwrite(res, [store_path,'under结果图1',img_name, '.jpg']) ;
imwrite(res2, [store_path,'under结果图2',img_name, '.jpg']) ;
end


