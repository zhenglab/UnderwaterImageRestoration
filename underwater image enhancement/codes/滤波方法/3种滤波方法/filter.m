clc;
clear all;
close all;
% % -----------------------------------------------------
img_path = 'C:\Users\qiqi\Desktop\滤波代码\Guss-conv\ ';
img_name = 'under.bmp' ;
A = imread(strcat(img_path,img_name)) ; 
% figure, imshow(A), title('原始图像')

[h,w,c] = size(A);
A1=rgb2hsi(A);  

H = A1(:,:,1) ;
S = A1(:,:,2);
I = A1(:,:,3);
HSI = zeros(h,w,c) ;
HSI(:,:,1) = H ;
HSI(:,:,2) = S ;

I_img=I;
I_img_1=double(I_img);%保证精度
I_img__=im2uint8(I_img_1);
% img_pro=im2double(img);
G_img=fspecial('gaussian',[8 8],2);%滤波器大小，标准偏差参数为2
Gimage=imfilter(I_img__,G_img,'conv');%模糊图像
Gimage1=imfilter(I_img_1,G_img,'conv');%模糊图像

imwrite(Gimage, strcat(img_path,'Gimage_',img_name)) 
figure, imshow(Gimage),title('模糊图像') 

imwrite(Gimage1, strcat(img_path,'Gimage1_',img_name)) 
figure, imshow(Gimage1),title('模糊图像1') 

%-------------------------逆滤波-----------------------------
[j, p]=deconvblind(Gimage,G_img,10);
B_img=j;
%imwrite(B_img, strcat(img_path,'B_img_',img_name)) 
figure, imshow(B_img),title('逆滤波复原图像') 

%-------------------------维纳滤波---------------------------
W_img=wiener2(Gimage,[3 3],0.1);%信噪比设为0.1
W_img1=deconvwnr(Gimage1,G_img,0.1);%信噪比设为0.1
imwrite(W_img1, strcat(img_path,'W_img1_',img_name)) 
figure, imshow(W_img1),title('维纳滤波复原图像') 

%-------------------------功率谱均衡滤波----------------------
P=sqrt(1./(G_img.^2+0.1));
P_img=filter2(P,Gimage1);
imwrite(P_img, strcat(img_path,'P_img_',img_name)) 
figure, imshow(P_img,[]),title('功率谱均衡复原图像') 

