function H_img = entropy(img)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %         计算熵
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[C,R,n] = size(img) ;%求图像的规格
if n ==3
    I = rgb2gray(img) ;
else
    I = img ;
end
%I=double(I);

Img_size=C*R;       %图像像素点的总个数
L=256;              %图像的灰度级
H_img=0;
nk=zeros(L,1);
%%%%%%二重循环可以改为一重循环
for i=0:255
    nk(i+1,1)=sum(sum(I==i));      %统计每个灰度级像素的点数
end
%%%%%%%%%%%%%%%%%%%
for k=1:L
    Ps(k)=nk(k)/Img_size;                  %计算每一个灰度级像素点所占的概率
    if Ps(k)~=0;                           %去掉概率为0的像素点
    H_img=-Ps(k)*log2(Ps(k))+H_img;        %求熵值的公式
    end
end