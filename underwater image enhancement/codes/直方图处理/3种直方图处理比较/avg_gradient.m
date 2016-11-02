function outval = avg_gradient(img)
%%%%%%%%%%%%%%%%%%%%
% OUTVAL = AVG_GRADIENT(IMG)
%  计算平均梯度
%  其中 img 是 RGB彩色图像
%%%%%%%%%%%%%%%%%%%%

if nargin == 1
   % img
    img = double(img);
    %imshow(img);
    % Get the size of img
    [r,c,b] = size(img);
    dx = 1;
    dy = 1;
    for k = 1 : b
        band = img(:,:,k);
        dzdx=0.0;
        dzdy=0.0;
        [dzdx,dzdy] = gradient(band,dx,dy);
        s = sqrt((dzdx .^ 2 + dzdy .^2) ./ 2);
        g(k) = sum(sum(s)) / ((r - 1) * (c - 1));
    end
    outval = mean(g);
   else
    error('Wrong number of input!');
end