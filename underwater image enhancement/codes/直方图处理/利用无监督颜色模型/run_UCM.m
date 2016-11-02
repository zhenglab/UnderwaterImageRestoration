function []=run_UCM()
%%%%%
%%%%程序已调通！！
%%%%%


srcDir=uigetdir('C:\Users\qiqi\Desktop\图像增强代码\直方图处理\利用无监督颜色模型\'); %获得选择的文件夹
cd(srcDir) ;
allnames=struct2cell(dir('*.bmp')); 
[k,img_number]=size(allnames); %获得图片文件的个数

store_path = 'C:\Users\qiqi\Desktop\图像增强代码\直方图处理\利用无监督颜色模型\' ;%处理后的图片存储路径

for number=1 : img_number    %逐次取出文件
    
    img_name=allnames{1,number};
    RGB_img=imread( img_name);
    
     result = my_UCM(RGB_img);
     
%      figure, imshow(result), title('ICM');
     imwrite(result, [store_path,'UCM', img_name, '.bmp']) ;
     
end
end





function result_RGB=my_UCM(RGBimg)%%%%UCM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 根据论文 《Underwater Image Enhancement 
%%% Using an Integrated Colour Model》和
%%%Enhancing The Low Quality Images Using Unsupervised Colour Correction Method
%%%编写
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RGBcutRate = 0.008;
HSIcutRate=0.004; %%裁剪参数设置

setRmax = 250;
setGmax = 250 ;
setBmax = 250 ;
setSmax = 0.9;
setImax = 0.9;%%%%以上是参数设置

img_ori = double(RGBimg) ;
[h, w, ~] = size(img_ori) ; 

GW = GrayWorld(img_ori);%%UCM
% GW = img_ori ;%%%ICM

% % %-------------对比度校正-------------------% % %
% % % %--------------RGB颜色空间------------% % % %
reR = reshape(GW(:,:,1),h*w,1) ;
reG = reshape(GW(:,:,2),h*w,1) ;
reB = reshape(GW(:,:,3),h*w,1) ;

[sort_R,index_R] = sort(reR, 'descend') ;
[sort_G,index_G] = sort(reG, 'descend') ;
[sort_B,index_B] = sort(reB, 'descend') ;
cut_num = round(RGBcutRate*h*w) ;

R_correct = zeros(h,w) ;
G_correct = zeros(h,w) ;
B_correct = zeros(h,w) ;

    for ii = cut_num+1 : h*w-cut_num
        R_correct(index_R(ii))=double(sort_R(ii)-sort_R(h*w-cut_num)) * double(setRmax-sort_R(h*w-cut_num)) / ...
                                          double(sort_R(cut_num)-sort_R(h*w-cut_num))+sort_R(h*w-cut_num);
        B_correct(index_B(ii))=double(sort_B(ii)-sort_B(h*w-cut_num)) * double(setGmax-sort_G(h*w-cut_num))/...
                                          double(sort_B(cut_num)-sort_B(h*w-cut_num))+sort_G(h*w-cut_num);
        G_correct(index_G(ii))=double(sort_G(ii)-sort_G(h*w-cut_num)) * double(setBmax-sort_G(h*w-cut_num)) / ...
                                          double(sort_G(cut_num)-sort_G(h*w-cut_num))+sort_B(h*w-cut_num);
    end
for ii = 1:cut_num
    R_correct(index_R(ii)) = 255-ii*(255-setRmax)/cut_num ;
    B_correct(index_B(ii)) = 255-ii*(255-setGmax)/cut_num ;
    G_correct(index_G(ii)) = 255-ii*(255-setBmax)/cut_num ;
end
for ii = h*w-cut_num+1:h*w
%     R_correct(index_R(ii)) = (ii-h*w+cut_num)*sort_R(h*w-cut_num)/cut_num ;
    R_correct(index_R(ii)) = sort_R(h*w-cut_num) ;
    B_correct(index_B(ii)) = sort_G(h*w-cut_num) ;
    G_correct(index_G(ii)) = sort_B(h*w-cut_num) ;
end

RGB_correct = cat(3,R_correct,G_correct,B_correct);
% % %% ----------------------------------------------------------------------RGB对比度校正完成
% figure, imshow(uint8(RGB_correct)), title('RGB对比度校正后') ;

% % % % % %--------------------HSI 空间校正----------------------% % %
cut_num = round(h*w*HSIcutRate); % 设置裁剪像素数
HSI = rgb2hsi(RGB_correct/255.0) ;
H = HSI(:,:,1) ;
S = HSI(:,:,2) ;
I = HSI(:,:,3) ;
reS = reshape(S,h*w,1) ;
reI = reshape(I,h*w,1) ;
[sort_S,index_S] = sort(reS, 'descend') ;
[sort_I, index_I] = sort(reI, 'descend') ;
S_correct = S ;
I_correct = I ;
for ii = cut_num+1 : h*w-cut_num
     S_correct(index_S(ii))=double(sort_S(ii)-sort_S(h*w-cut_num))* double(setSmax-sort_S(h*w-cut_num+1))/...
                                          double(sort_S(1)-sort_S(h*w-cut_num+1))+sort_S(h*w-cut_num);
     I_correct(index_I(ii))=double(sort_I(ii)-sort_I(h*w-cut_num))*double(setImax-sort_I(h*w-cut_num+1))/...
                                          double(sort_I(1)-sort_I(h*w-cut_num+1))+sort_I(h*w-cut_num);
end
for ii = 1 : cut_num
     S_correct(index_S(ii))=setSmax;
     I_correct(index_I(ii))=setImax;
end
for ii = h*w-cut_num : h*w
     S_correct(index_S(ii))=sort_S(h*w-cut_num);
     I_correct(index_I(ii))=sort_I(h*w-cut_num);
end

HSI_correct = cat(3,H,S_correct,I_correct) ;
result_RGB = hsi2rgb(HSI_correct) ;
% % % % % % ----------------------------------------------------------HSI对比度校正完成
 % result_RGB = uint8(result_RGB*255);
 %imwrite(result_RGB, strcat(store_path,'UCM_',img_name));
% figure, imshow(result_RGB), title('HSI校正后');
end

function y=GrayWorld(Image)%%%灰度世界白平衡
r=Image(:,:,1);
g=Image(:,:,2);
b=Image(:,:,3);
avgR = mean(mean(r));
avgG = mean(mean(g));
avgB = mean(mean(b));
avgRGB = [avgR avgG avgB];
grayValue = (avgR + avgG + avgB)/3 ;
scaleValue = grayValue./avgRGB;
newI(:,:,1) = scaleValue(1) * r;
newI(:,:,2) = scaleValue(2) * g;
newI(:,:,3) = scaleValue(3) * b;
y=newI;
end

function hsi = rgb2hsi(rgb) 
%%%三通道值需归一化到【0，1】

%RGB2HSI Converts an RGB image to HSI. 
%   HSI = RGB2HSI(RGB) converts an RGB image to HSI. The input image 
%   is assumed to be of size M-by-N-by-3, where the third dimension 
%   accounts for three image planes: red, green, and blue, in that 
%   order. If all RGB component images are equal, the HSI conversion 
%   is undefined. The input image can be of class double (with values 
%   in the range [0, 1]), uint8, or uint16.  
% 
%   The output image, HSI, is of class double, where: 
%     hsi(:, :, 1) = hue image normalized to the range [0, 1] by 
%                    dividing all angle values by 2*pi.  
%     hsi(:, :, 2) = saturation image, in the range [0, 1]. 
%     hsi(:, :, 3) = intensity image, in the range [0, 1]. 

%   Copyright 2002-2004 R. C. Gonzalez, R. E. Woods, & S. L. Eddins 
%   Digital Image Processing Using MATLAB, Prentice-Hall, 2004 
%   $Revision: 1.4 $  $Date: 2003/09/29 15:21:54 $ 

% Extract the individual component immages. 
rgb = im2double(rgb); 
r = rgb(:, :, 1); 
g = rgb(:, :, 2); 
b = rgb(:, :, 3); 

% Implement the conversion equations. 
num = 0.5*((r - g) + (r - b)); 
den = sqrt((r - g).^2 + (r - b).*(g - b)); 
theta = acos(num./(den + eps)); 

H = theta; 
H(b > g) = 2*pi - H(b > g); 
H = H/(2*pi); 

num = min(min(r, g), b); 
den = r + g + b; 
den(den == 0) = eps; 
S = 1 - 3.* num./den; 

H(S == 0) = 0; 

I = (r + g + b)/3; 

% Combine all three results into an hsi image. 
hsi = cat(3, H, S, I); 
end
function rgb = hsi2rgb(hsi) 
%HSI2RGB Converts an HSI image to RGB. 
%   RGB = HSI2RGB(HSI) converts an HSI image to RGB, where HSI is 
%   assumed to be of class double with:   
%     hsi(:, :, 1) = hue image, assumed to be in the range 
%                    [0, 1] by having been divided by 2*pi. 
%     hsi(:, :, 2) = saturation image, in the range [0, 1]. 
%     hsi(:, :, 3) = intensity image, in the range [0, 1]. 
% 
%   The components of the output image are: 
%     rgb(:, :, 1) = red. 
%     rgb(:, :, 2) = green. 
%     rgb(:, :, 3) = blue. 

%   Copyright 2002-2004 R. C. Gonzalez, R. E. Woods, & S. L. Eddins 
%   Digital Image Processing Using MATLAB, Prentice-Hall, 2004 
%   $Revision: 1.5 $  $Date: 2003/10/13 01:01:06 $ 

% Extract the individual HSI component images. 
H = hsi(:, :, 1) * 2 * pi; 
S = hsi(:, :, 2); 
I = hsi(:, :, 3); 

% Implement the conversion equations. 
R = zeros(size(hsi, 1), size(hsi, 2)); 
G = zeros(size(hsi, 1), size(hsi, 2)); 
B = zeros(size(hsi, 1), size(hsi, 2)); 

% RG sector (0 <= H < 2*pi/3). 
idx = find( (0 <= H) & (H < 2*pi/3)); 
B(idx) = I(idx) .* (1 - S(idx)); 
R(idx) = I(idx) .* (1 + S(idx) .* cos(H(idx)) ./ ... 
                                          cos(pi/3 - H(idx))); 
G(idx) = 3*I(idx) - (R(idx) + B(idx)); 

% BG sector (2*pi/3 <= H < 4*pi/3). 
idx = find( (2*pi/3 <= H) & (H < 4*pi/3) ); 
R(idx) = I(idx) .* (1 - S(idx)); 
G(idx) = I(idx) .* (1 + S(idx) .* cos(H(idx) - 2*pi/3) ./ ... 
                    cos(pi - H(idx))); 
B(idx) = 3*I(idx) - (R(idx) + G(idx)); 

% BR sector. 
idx = find( (4*pi/3 <= H) & (H <= 2*pi)); 
G(idx) = I(idx) .* (1 - S(idx)); 
B(idx) = I(idx) .* (1 + S(idx) .* cos(H(idx) - 4*pi/3) ./ ... 
                                           cos(5*pi/3 - H(idx))); 
R(idx) = 3*I(idx) - (G(idx) + B(idx)); 

% Combine all three results into an RGB image.  Clip to [0, 1] to 
% compensate for floating-point arithmetic rounding effects. 
rgb = cat(3, R, G, B); 
rgb = max(min(rgb, 1), 0); 
end

