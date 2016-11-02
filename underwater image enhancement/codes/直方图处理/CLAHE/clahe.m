% 本程序对图像 分别在HSV空间和RGB空间 进行限制对比度自适应直方图均衡 

close all
clear all
clc

clip_limit = 0.017 ;%%裁剪比例
tile_num  = [12,6] ;  %%%行列分块数

img_path = 'C:\Users\qiqi\Desktop\图像增强代码\直方图处理\CLAHE\' ;
img_name = '图片3.bmp';

RGB_img = imread(strcat(img_path,img_name));
hsv_img=rgb2hsv(RGB_img);
V = hsv_img; 

% % % % Perform CLAHE
V(:,:,3) = adapthisteq(V(:,:,3),'NumTiles', tile_num,'ClipLimit',clip_limit);
% % % % Convert back to RGB_img color space
RGB_img1=hsv2rgb(V);
% % % %  Display the results
figure, imshow(RGB_img); 
figure, imshow(RGB_img1),title('HSV clahe');
%oldresults(RGB_img,RGB_img1);
% % % % contrast gain

im = double(rgb2gray(RGB_img));
op = double(rgb2gray(RGB_img1));
[M, ~] = size(im);

% RGB_img
RGB_img1(:,:,1) = adapthisteq(RGB_img(:,:,1),'NumTiles', tile_num,'ClipLimit',clip_limit);
RGB_img1(:,:,2) = adapthisteq(RGB_img(:,:,2),'NumTiles', tile_num,'ClipLimit',clip_limit);
RGB_img1(:,:,3) = adapthisteq(RGB_img(:,:,3),'NumTiles', tile_num,'ClipLimit',clip_limit);

figure, imshow(uint8(RGB_img1)),title('RGB clahe');


