%%%%
%%%%动态阈值白平衡
%%%%

clc ; 
clear all ;
read_path = 'D:\图像增强代码\颜色校正\动态阈值白平衡\' ;
store_path = 'D:\图像增强代码\颜色校正\动态阈值白平衡\' ;
img_name =  'under.bmp';

im=imread( img_name);
im2=im;
im1=rgb2ycbcr(im);%将图片的RGB值转换成YCbCr值%
Lu=im1(:,:,1);
Cb=im1(:,:,2);
Cr=im1(:,:,3);
[x y z]=size(im);
tst=zeros(x,y);

%计算Cb、Cr的均值Mb、Mr%
Mb=mean(mean(Cb));
Mr=mean(mean(Cr));

%计算Cb、Cr的均方差%
Db=sum(sum(Cb-Mb))/(x*y);
Dr=sum(sum(Cr-Mr))/(x*y);

%根据阀值的要求提取出near-white区域的像素点%
cnt=1;    
for i=1:x
    for j=1:y
        b1=Cb(i,j)-(Mb+Db*sign(Mb));
        b2=Cr(i,j)-(1.5*Mr+Dr*sign(Mr));
        if (b1<abs(1.5*Db) & b2<abs(1.5*Dr))
           Ciny(cnt)=Lu(i,j);
           tst(i,j)=Lu(i,j);
           cnt=cnt+1;
        end
    end
end
cnt=cnt-1;
iy=sort(Ciny,'descend');%将提取出的像素点从亮度值大的点到小的点依次排列%
nn=round(cnt/10);
Ciny2(1:nn)=iy(1:nn);%提取出near-white区域中10%的亮度值较大的像素点做参考白点%
 
%提取出参考白点的RGB三信道的值% 
mn=min(Ciny2);
for i=1:x
    for j=1:y
        if tst(i,j)<mn
           tst(i,j)=0;
        else
           tst(i,j)=1;
        end
    end
end

R=im(:,:,1);
G=im(:,:,2);
B=im(:,:,3);
R=double(R).*tst;
G=double(G).*tst;
B=double(B).*tst;
 
%计算参考白点的RGB的均值%
Rav=mean(mean(R));
Gav=mean(mean(G));
Bav=mean(mean(B));
Ymax=double(max(max(Lu)))/15;%计算出图片的亮度的最大值%
 
%计算出RGB三信道的增益% 
Rgain=Ymax/Rav;
Ggain=Ymax/Gav;
Bgain=Ymax/Bav;

%通过增益调整图片的RGB三信道%
im(:,:,1)=im(:,:,1)*Rgain;
im(:,:,2)=im(:,:,2)*Ggain;
im(:,:,3)=im(:,:,3)*Bgain;

imwrite(im, [store_path,'under结果图','.bmp']) ;
%显示图片%
figure,imshow(im2,[]),title('原图');
figure,imshow(im,[]),title('color correct');
