% % % 添加椒盐噪声
% % % %%-------------------------------------------
clc;
clear all;
close all;
% % -----------------------------------------------------
img_path = 'C:\Users\qiqi\Desktop\新建文件夹\椒盐\ ';
img_name = 'under.bmp' ;
A = imread(strcat(img_path,img_name)) ;  
[h,w,c] = size(A);
A1=rgb2hsi(A);  

H = A1(:,:,1) ;
S = A1(:,:,2);
I = A1(:,:,3);
HSI = zeros(h,w,c) ;
HSI(:,:,1) = H ;
HSI(:,:,2) = S ;

%添加椒盐噪声
noi_I=imnoise(I,'salt & pepper',0.02);%加入强度为0.02的椒盐噪声
imwrite(noi_I, strcat(img_path,'salt_',img_name)) 
figure, imshow(noi_I),title('添加椒盐噪声后') 

% % %  采用3×3的平均窗口对它图像作中值滤波
med_I=medfilt2(noi_I,[3 3]);
imwrite(med_I, strcat(img_path,'salt_med_',img_name)) 
figure, imshow(med_I),title('椒盐噪声 中值滤波后') 

% % %  采用3×3的平均窗口对它图像作均值滤波
filt1 = fspecial('average',[4 4]);%生成3*3的均值滤波器
mean_I = imfilter(noi_I,filt1,'replicate');%滤波,通过复制边界值扩展图像边界

imwrite(mean_I , strcat(img_path,'salt_mean_',img_name)) 
figure, imshow(mean_I ),title('椒盐噪声 均值滤波后') 







