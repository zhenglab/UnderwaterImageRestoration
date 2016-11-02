clear ;
close all ;
clc ;

filter_R = 30;
minAtomsLight = 220;
winR = 15;
dehaze_rate = 0.9;
t_limit =0.1;
eps = 10^-6;

read_path = 'C:\Users\qiqi\Desktop\去雾类图像复原代码\导向滤波暗通道去雾\' ;
store_path = 'C:\Users\qiqi\Desktop\去雾类图像复原代码\导向滤波暗通道去雾\' ;
img_name =  'under.bmp';

img=imread(strcat(read_path,img_name));
% figure,imshow(img), title('original');

[h,w,c] = size(img) ;
R = double(img(:,:,1));
G = double(img(:,:,2));
B = double(img(:,:,3));

%%%%%%%%----计算暗通道 -------%%%%%%%%%%%%%%%%%%%%
minRGB = zeros(h,w);
for y=1:h
    for x=1:w
        minRGB(y,x) = min(img(y,x,:));
    end
end
% figure,imshow(uint8(minRGB)), title('Min(R,G,B)');
darkChannel = minfilt(minRGB, [winR, winR]);
% figure,imshow(uint8(darkChannel)), title('DarkChannel ');

%     %%%%%%%----估算背景光 -------%%%%%%%%%%%%%%%%%%%%
darkNum_estimatA = round(0.001*h*w) ;

[sortDarkChannel,index] = sort(darkChannel(:), 'descend') ;
sumR = 0;
sumG = double(0);
sumB = double(0);
for ii = 1 : darkNum_estimatA
    sumR = R(index(ii))+sumR;
    sumG = G(index(ii))+sumG;
    sumB = B(index(ii))+sumB;  
end
A_R = sumR/darkNum_estimatA;
A_G = sumG/darkNum_estimatA;
A_B = sumB/darkNum_estimatA;

%%%%%%%%-----估算透射率-----%%%%%%%%%%%%%%%%%%%%%%
t_R = 1-dehaze_rate*darkChannel/A_R;       
t_G = 1-dehaze_rate*darkChannel/A_G;      
t_B = 1-dehaze_rate*darkChannel/A_B;       
% figure, imshow(t_R), title('t_R') ;
% figure, imshow(t_G), title('t_G') ;
% figure, imshow(t_B), title('t_B') ;
%%%%^^^^^优化透射率…………………………………………………………………
t_R_filtered = guidedfilter(double(rgb2gray(img))/255, t_R, filter_R , eps);
t_G_filtered = guidedfilter(double(rgb2gray(img))/255, t_G, filter_R , eps);
t_B_filtered = guidedfilter(double(rgb2gray(img))/255, t_B, filter_R , eps);
 %figure, imshow(uint8(t_R_filtered.*255)), title('t_R优化后') ;
%figure, imshow(uint8(t_G_filtered.*255)), title('t_G优化后') ;
%figure, imshow(uint8(t_B_filtered.*255)), title('t_B优化后') ;

%%%%%%%%----复原清晰图像----%%%%%%%%%%%%%%%%%%%%%% 
    J_R = zeros(h, w, 'double') ;
    J_G = zeros(h, w, 'double') ;
    J_B = zeros(h, w, 'double') ;
    
    for i = 1 : h
        for j = 1 : w
            J_R(i, j) = (R(i, j)-A_R)/max(t_R_filtered(i,j),t_limit)+A_R;
            J_G(i, j) = (G(i, j)-A_G)/max(t_G_filtered(i,j),t_limit)+A_G;
            J_B(i, j) = (B(i, j)-A_B)/max(t_B_filtered(i,j),t_limit)+A_B;
        end
    end
    
    J = zeros(h, w, 3) ;
    J(:, :, 1) = J_R ;
    J(:, :, 2) = J_G ;
    J(:, :, 3) = J_B ;
imwrite(uint8(J), [store_path,'under结果图',img_name]) ;
 figure,imshow(uint8(J)), title('J');




