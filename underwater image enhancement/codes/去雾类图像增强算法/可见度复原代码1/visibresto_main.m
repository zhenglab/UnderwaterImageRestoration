% Gray level example of visibility restoration
im=double(imread('ª“∂»Õº.pgm'))/255.0;
sv=2*floor(max(size(im))/25)+1;
res=visibresto(im,sv,0.95,-1,1,1.0);
figure;imshow([im, res],[0,1]);


% Color example of visibility restoration
im=double(imread('underwater.bmp'))/255.0;
sv=2*floor(max(size(im))/50)+1;
res=visibresto(im,sv,0.95,0.5);
figure;imshow([im, res],[0,1]);




