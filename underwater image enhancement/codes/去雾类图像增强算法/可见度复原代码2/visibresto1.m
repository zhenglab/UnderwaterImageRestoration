%
% 17/11/2009
% Author: J.-P. Tarel
% LCPC-INRETS-IFSTTAR copyright
% completed in 06/03/2013, corrected in 08/03/2013
%
% This algorithm is described in details in 
%
%"Improved Visibility of Road Scene Images under Heterogeneous Fog",
% by J.-P. Tarel, N. Hautiere, A. Cord, D. Gruyer and H. Halmaoui,
% in proceedings of IEEE Intelligent Vehicles Symposium (IV'10),
% San Diego, California, USA, p. 478-485, June 21-24, 2010. 
% http://perso.lcpc.fr/tarel.jean-philippe/publis/iv10.html
%
% extra explainations can be also found in 
%
%"Vision Enhancement in Homogeneous and Heterogeneous Fog",
% by J.-P. Tarel, N. Hautiere, L. Caraffa, A. Cord, H. Halmaoui and D. Gruyer
% in IEEE Intelligent Transportation Systems Magazine,
% 4:(2), p. 6-20, Summer 2012. 
% http://perso.lcpc.fr/tarel.jean-philippe/publis/itsm12.html
%
% Beware that slight differences in the obtained results can be observed 
% between the original fast C code and this matlab implementation
%
% INPUTS: 
% orig is the original image in double between O and 1, 
% p is the percentage of restoration
% sv is the maximum size of assumed white objects
% balance is negative for no white balance, 
% balance is 0.0 for global white balance, 
% balance is higher 0.0 for local white balance: 
%      balance=0.1 leads to a strong bias towards (1,1,1), 
%      balance=0.5 can be used as a good starting value, 
%      balance=1.0 remove most of the colors
% smax is the maximum window size for the the adapted filtering
% when smax is 1, no adpated filtering is performed 
% smax can be used for very noisy original images
% gfactor is an extra factor during final gamma correction to achieve 
% more colorful result
% vh is the line number where the horizon line is
% rcalib is the parameter which allows to link a line number v with a distance on the floor
% i.e distance on the floor = rcalib / ( v - vh)
% rcalib can be computed as rcalib = H alpha / cos(theta) where H is the camera height,
% alpha is the inverse of the size of a pixel, and theta is the vertical angle between the
% camera axis and the floor.
% minvd is the minimal visibility distance which can be observed in the scene, usually 50 m
% minvd can be also set to the true visibility distance when known
%
% OUTPUT:
% resto is the obtained image after visibility restoration
%
function resto=visibresto1(orig, sv, p, balance, smax, gfactor, vh, rcalib, minvd)

% default parameters
if (nargin < 9)
   minvd=50.0;      % default value for the minimum observable visibility distance 
end
if (nargin < 8)
   rcalib=1000.0;   % default value for the factor linking pixel heigth to plane distance 
end
if (nargin < 7)
   vh=1;     	    % default value for the height of the horizon line 
end
if (nargin < 6)
   gfactor=1.0;     % default value for extra factor during final gamma correction 
end
if (nargin < 5)
   smax=1;    	    % by default, no adapted filtering
end
if (nargin < 4)
   balance=-1.0;    % by default, no white balance
end
if (nargin < 3)
   p = 0.95;        % by default, percentage of restoration in 95%
end
if (nargin < 2)
   sv = 11;         % by default, white objects are assumed with size sv=11
end
if (nargin < 1)
	msg1 = sprintf('%s: Not input.', upper(mfilename));
        eid = sprintf('%s:NoInputArgument',mfilename);
        error(eid,'%s %s',msg1);
end

% test input arguments
smax=floor(smax);
if (smax < 1)
	msg1 = sprintf('%s: smax is out of bound.', upper(mfilename));
        msg2 = 'It must be an integer higher or equal to 1.';
        eid = sprintf('%s:outOfRangeSMAx',mfilename);
        error(eid,'%s %s',msg1,msg2);
end
if ((p >= 1.0) | (p<=0.0))
	msg1 = sprintf('%s: p is out of bound.', upper(mfilename));
        msg2 = 'It must be an between 0.0 and 1.0';
        eid = sprintf('%s:outOfRangeP',mfilename);
        error(eid,'%s %s',msg1,msg2);
end
sv=floor(sv);
if (sv < 1)
	msg1 = sprintf('%s: sv is out of bound.', upper(mfilename));
        msg2 = 'It must be an integer higher or equal to 1.';
        eid = sprintf('%s:outOfRangeSV',mfilename);
        error(eid,'%s %s',msg1,msg2);
end
iptcheckinput(orig,{'single','double'},{'real', 'nonempty', 'nonsparse'}, mfilename,'orig',1);
if ((max(orig(:))> 1.0) | (min(orig(:))<0.0))
	msg1 = sprintf('%s: image is out of bound.', upper(mfilename));
        msg2 = 'It must be between 0.0 and 1.0';
        eid = sprintf('%s:outOfRangeOrig',mfilename);
        error(eid,'%s %s',msg1,msg2);
end

[dimy,dimx, ncol]=size(orig);

if (ncol==1) 
	w=orig; 
	nbo=orig;
end
if (ncol==3) 
	if (balance==0.0) % global white balance on clear pixels
		w=min(orig,[],3); 
		ival = quantile(w(:),[.99])
		[rind,cind]=find(w>=ival);
		sel(:,1)=orig(sub2ind(size(orig),rind,cind,ones(size(rind))));
		sel(:,2)=orig(sub2ind(size(orig),rind,cind,2*ones(size(rind))));
		sel(:,3)=orig(sub2ind(size(orig),rind,cind,3*ones(size(rind))));
		white=mean(sel,1);
		white=white./max(white)
		orig(:,:,1)=orig(:,:,1)./white(1);
		orig(:,:,2)=orig(:,:,2)./white(2);
		orig(:,:,3)=orig(:,:,3)./white(3);
	end
	if (balance>0.0) % local white balance
		fo(:,:,1)=medfilt2(orig(:,:,1), [sv, sv], 'symmetric');
		fo(:,:,2)=medfilt2(orig(:,:,2), [sv, sv], 'symmetric');
		fo(:,:,3)=medfilt2(orig(:,:,3), [sv, sv], 'symmetric');
		nbfo=mean(fo,3);
		fo(:,:,1)=(fo(:,:,1)./nbfo).^balance;
		fo(:,:,2)=(fo(:,:,2)./nbfo).^balance;
		fo(:,:,3)=(fo(:,:,3)./nbfo).^balance;
		nbfo=mean(fo,3);
		fo(:,:,1)=fo(:,:,1)./nbfo;
		fo(:,:,2)=fo(:,:,2)./nbfo;
		fo(:,:,3)=fo(:,:,3)./nbfo;
		orig(:,:,1)=orig(:,:,1)./fo(:,:,1);
		orig(:,:,2)=orig(:,:,2)./fo(:,:,2);
		orig(:,:,3)=orig(:,:,3)./fo(:,:,3);
	end
	% compute photometric bound
	w=min(orig,[],3); 
	nbo=mean(orig,3);
end

% compute saturation bound
wm=medfilt2(w, [sv, sv], 'symmetric');
sw=abs(w-wm);
swm=medfilt2(sw, [sv, sv], 'symmetric');
b=wm-swm;
%compute planar assumption bound
c=ones(size(b));
for v=1:dimy
	ci=1-exp((log(0.05)*rcalib)/(minvd*max(v-vh,0)));
	c(v,:)=c(v,:)*ci;
end
% combining bounds
b=min(b,c);
% infered athmospheric veil respecting w and b bounds
v=p*max(min(w,b),0);

% restoration with inverse Koschmieder's law
factor=1.0./(1.0-v);
r=zeros(size(orig));
if (ncol==1) 
	r=(orig-v).*factor; 
	nbr=r;
end
if (ncol==3) 
	r(:,:,1)= (orig(:,:,1)-v).*factor; 
	r(:,:,2)= (orig(:,:,2)-v).*factor; 
	r(:,:,3)= (orig(:,:,3)-v).*factor; 
	% restore original light colors
	if (balance==0.0) 
		r(:,:,1)=r(:,:,1).*white(1);
		r(:,:,2)=r(:,:,2).*white(2);
		r(:,:,3)=r(:,:,3).*white(3);
	end
	if (balance>0.0) 
		r(:,:,1)=r(:,:,1).*fo(:,:,1);
		r(:,:,2)=r(:,:,2).*fo(:,:,2);
		r(:,:,3)=r(:,:,3).*fo(:,:,3);
	end
	nbr=mean(r,3);
end

% adapted smoothing with windows of maximum size smax pixels
if (smax~=1) 
	sr= medsmooth(r, smax, factor);
	r=sr;
	nbr=mean(r,3);
end

% final gamma correction 
u=r.^(1.0/gfactor);

% final tone mapping for a gray level between O and 1
mnbu=max(u(:));
resto=u./(1.0+(1.0-1.0/mnbu)*u);

if (nargout==0) 
        imshow(resto);
end

% subfunction for adapted local median smoothing
function res = medsmooth(ima,smax,factors)

% winsizes must be between 1 and smax
winsizes=floor(factors); 
ind = find(factors>smax);
winsizes(ind)=smax;

[dimy,dimx,ncol]=size(ima);
res=ima;

for l = (1:ncol)
   for j = (1:dimy)
      for k = (1:dimx)
         imacrop=ima(max(1,floor(j-winsizes(j,k)/2)):min(dimy,floor(j+winsizes(j,k)/2)),max(1,floor(k-winsizes(j,k)/2)):min(dimx,floor(k+winsizes(j,k)/2)),l);
         res(j,k,l) = median(imacrop(:));
      end
   end
end



