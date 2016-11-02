%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  对 对比度拉伸，直方图均衡，限制对比度自适应均衡
% %  三种图像处理方法 进行比较，
% %  评价方法：熵、对比度、平均梯度
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc ;
clear all;

srcDir=uigetdir('D:\图像复原代码\代码\直方图处理\pipe_1\'); %获得选择的文件夹
cd(srcDir) ;
allnames=struct2cell(dir('*.bmp')); 
[k,img_number]=size(allnames); %获得图片文件的个数

store_path = 'D:\图像复原代码\代码\直方图处理\main-ClaheHeStre结果图\' ;%处理后的图片存储路径

gradient_result = zeros(img_number,4) ;
contrast_result = zeros(img_number,4) ;
entropy_result = zeros(img_number,4) ;

for number=1 : img_number    %逐次取出文件
    
    img_name=allnames{1,number} ;
    RGBimg=imread( img_name) ;
    img_ori = double(RGBimg) ;
    [h, w, c] = size(img_ori) ;
    
    R= img_ori(:,:,1) ;
    G= img_ori(:,:,2) ;    
    B= img_ori(:,:,3) ;
    
% % % --------------直方图均衡--------------------% %
%     %%%%分通道进行均衡%%%%
%     RGB_eq = HistEq(img_ori) ;
%     R_eq = RGB_eq(:,:,1) ;
%     G_eq = RGB_eq(:,:,2) ;
%     B_eq = RGB_eq(:,:,3) ;
%     %%%%%%%%%%%%%%%
    %%%在hsv空间进行均衡%%%
    hsv_img=rgb2hsv(img_ori);
    I = hsv_img(:,:,3) ;
%     hsv_img(:,:,3) = histeq(V)*255;%用MATLAB自带程序
    hsv_img(:,:,3) = HistEq(I);%自编直方图均衡程序
    RGB_eq=hsv2rgb(hsv_img);
% % %---------------------------------------------------------------

% % % -------------对比度拉伸---------------------% %
    reR = reshape(R,h*w,1) ;
    reG = reshape(G,h*w,1) ;
    reB = reshape(B,h*w,1) ;

    [sort_R,index_R] = sort(reR, 'ascend') ;
    [sort_G,index_G] = sort(reG, 'ascend') ;
    [sort_B,index_B] = sort(reB, 'ascend') ;
    
    cutRate = 0.002; %%裁剪比例
    limit = round(cutRate*h*w) ;
    
    R_stretch = ContrastStretch(R, sort_R(1),sort_R(h*w-limit),sort_G(limit),sort_B(h*w)) ;
    G_stretch = ContrastStretch(G, sort_G(limit),sort_R(h*w),sort_R(limit),sort_B(h*w-limit)) ;
    B_stretch = ContrastStretch(B, sort_B(1),sort_B(h*w),sort_R(1),sort_B(h*w-limit)) ;
% % % % --------------------------------------------------------------------------------------

% % % % -------限制对比度自适应直方图均衡----------% % %
    clip_limit = 0.03 ;%设置直方图裁剪上限
    tile_num = [round(h/100),round(w/100)] ;%%分块数
%     tile_num  = [6,8] ;
    if tile_num(1)<2
        tile_num(1)=2;
    end
    if tile_num(2)<2
        tile_num(2)=2;
    end
    
%     %%%%%----------分通道均衡-------------------%%
%     RGB_clahe = zeros(h,w,c,'double') ;
%     RGB_clahe(:,:,1) = adapthisteq(R,'NumTiles', tile_num,'ClipLimit',clip_limit);
%     RGB_clahe(:,:,2) = adapthisteq(G,'NumTiles', tile_num,'ClipLimit',clip_limit);
%     RGB_clahe(:,:,3) = adapthisteq(B,'NumTiles', tile_num,'ClipLimit',clip_limit);
%     %%%%%---------------------------------------------------------------------
    
    %%%%--------在hsv空间进行均衡------------%%
    hsv_img=rgb2hsv(RGBimg);
    hsv_img(:,:,3) = adapthisteq(hsv_img(:,:,3),'NumTiles', tile_num,'ClipLimit',clip_limit);
    RGB_clahe=hsv2rgb(hsv_img);
%     figure, imshow(RGB_clahe),title('HSV clahe');
%%%%-----------------------------------------------------------------------------
   
% % % -----------------存储处理结果-------------------% %
    imwrite(uint8(RGB_eq), strcat(store_path,'eq_',img_name))
   
    RGB_stretch = zeros(h,w,c,'double') ;
    RGB_stretch(:,:,1) = R_stretch ;
    RGB_stretch(:,:,2) = G_stretch ;
    RGB_stretch(:,:,3) = B_stretch ;
    imwrite(uint8(RGB_stretch), strcat(store_path,'stretch_',img_name))
    
    imwrite(RGB_clahe, strcat(store_path,'clahe_',num2str(clip_limit),'_',img_name))
% % % --------------------------------------------------------------------------------------% %

%     subplot(2,2,1), subimage(RGBimg);
%     xlabel('(a)原始图像','FontSize',12,'FontName','楷体','color','b');
%     subplot(2,2,2), subimage(uint8(RGB_eq));
%     xlabel('(b)HE处理','FontSize',12,'FontName','楷体','color','b');
%     subplot(2,2,3), subimage(uint8(RGB_stretch));
%     xlabel('(c)对比度拉伸','FontSize',12,'FontName','楷体','color','b');
%     subplot(2,2,4), subimage(RGB_clahe);
%     xlabel('(a)CLAHE处理','FontSize',12,'FontName','楷体','color','b');
    
% % % %------------------图像质量评价------------------%%%
    %%%%%--------计算平均梯度------------%%%%
    gradient_result(number,1) = avg_gradient(RGBimg) ;
    gradient_result(number,2) = avg_gradient(uint8(RGB_eq)) ;
    gradient_result(number,3) = avg_gradient(uint8(RGB_stretch)) ;
    gradient_result(number,4) = avg_gradient(uint8(RGB_clahe*255)) ;  
    %%%%%%%----------------------------%%%
    
    %%%%%---------计算对比度-----------%%%%
    contrast_result(number,1) = CalculateContrast(RGBimg) ;
    contrast_result(number,2) = CalculateContrast(uint8(RGB_eq)) ;
    contrast_result(number,3) = CalculateContrast(uint8(RGB_stretch)) ;
    contrast_result(number,4) = CalculateContrast(uint8(RGB_clahe*255)) ;
    %%%%--------------------------------%%%%
    
    %%%%%-----------计算熵------------%%%%
    entropy_result(number,1) = entropy(RGBimg) ;
    entropy_result(number,2) = entropy(uint8(RGB_eq)) ;
    entropy_result(number,3) = entropy(uint8(RGB_stretch)) ;
    entropy_result(number,4) = entropy(uint8(RGB_clahe*255)) ;
    %%%%%-------------------------%%%%%
% % % % ------------------------------------------------------%%

end
xlswrite('D:\图像复原代码\代码\直方图处理\结果\ClaheHeStre_gradient.xls',gradient_result);
xlswrite('D:\图像复原代码\代码\直方图处理\结果\ClaheHeStre_contrast.xls',contrast_result);
xlswrite('D:\图像复原代码\代码\直方图处理\结果\ClaheHeStre_entropy.xls',entropy_result);
