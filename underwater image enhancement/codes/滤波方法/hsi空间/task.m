clear
clc

img_path = 'C:\Users\qiqi\Desktop\ÂË²¨´úÂë\hsi¿Õ¼ä\ ';
img_name = 'under.bmp' ;
A = imread(strcat(img_path,img_name)) ;  
[h,w,c] = size(A);
A1=rgb2hsi(A);  
subplot(121),imshow(A);  
title('input1');  
subplot(122),imshow(A1);  
title('rgb2hsi'); 
imwrite(A1, strcat(img_path, 'hsi_',img_name)) ;

H = A1(:,:,1) ;
S = A1(:,:,2);
I = A1(:,:,3);
imwrite(H, strcat(img_path, 'h_',img_name)) ;
imwrite(S, strcat(img_path, 's_',img_name)) ;
imwrite(I, strcat(img_path, 'i_',img_name)) ;

eq_H= histeq(H,256) ;
eq_S = histeq(S,256) ;
eq_I = histeq(I,256) ;

eq_HSI = zeros(h,w,c);
eq_HSI(:,:,1) = eq_H ;
eq_HSI(:,:,2) = S ;
eq_HSI(:,:,3) = I ;
eq_RGB = hsi2rgb(eq_HSI) ;
imwrite(eq_RGB, strcat(img_path,'eq_H_',img_name)) ;
figure, imshow(eq_RGB) ;

eq_HSI = zeros(h,w,c);
eq_HSI(:,:,1) = H ;
eq_HSI(:,:,2) = S ;
eq_HSI(:,:,3) = eq_I ;
eq_RGB = hsi2rgb(eq_HSI) ;
imwrite(eq_RGB, strcat(img_path, 'eq_I_',img_name)) ;
figure, imshow(eq_RGB) ;

eq_HSI = zeros(h,w,c);
eq_HSI(:,:,1) = H ;
eq_HSI(:,:,2) = eq_S ;
eq_HSI(:,:,3) = I ;
eq_RGB = hsi2rgb(eq_HSI) ;
imwrite(eq_RGB, strcat(img_path,'eq_S_',img_name)) ;
figure, imshow(eq_RGB) ;

% reS = reshape(S,h*w,1) ;
% reI = reshape(eq_I,h*w,1) ;
% [sort_S,index_S] = sort(reS, 'descend') ;
% [sort_I, index_I] = sort(reI, 'descend') ;
% S_correct = S ;
% I_correct = I ;
% 
% cut_num = 1000;
% for ii = cut_num+1 : h*w-cut_num
%      S_correct(index_S(ii))=double(sort_S(ii)-sort_S(h*w-cut_num))*(1-0)/...
%                                           double(sort_S(cut_num+1)-sort_S(h*w-cut_num))+0;
%      I_correct(index_I(ii))=double(sort_I(ii)-sort_I(h*w-cut_num))*(1-0)/...
%                                           double(sort_I(cut_num+1)-sort_I(h*w-cut_num))+0;
% end
%  
% imp_HSI = zeros(h,w,c);
% imp_HSI(:,:,1) = H ;
% imp_HSI(:,:,2) = S_correct ;
% imp_HSI(:,:,3) = I_correct ;
% 
% eq_RGB = hsi2rgb(eq_HSI) ;
% figure, imshow(eq_RGB)
