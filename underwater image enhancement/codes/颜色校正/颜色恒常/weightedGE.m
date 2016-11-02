%  weightedGE: estimates the illuminant based on weighted Grey-Edge method
%
%
% SYNOPSIS:
%    [white_R ,white_G ,white_B,output_data] = weightedGE(input_data, kappa, mink_norm, sigma, mask_im)
%
% INPUT :
%   input_data    : color input image (NxMx3)
%   kappa         : weight-map construction parameter
%   mink_norm     : minkowski norm used (infinity not implemented).
%   mask_cal      : binary images with zeros on image positions which
%                   should be ignored (e.g. of calibration object)
%
% OUTPUT:
%   [white_R,white_G,white_B]           : illuminant color estimation
%   output_data                         : color corrected image
%

% LITERATURE :
%
% Arjan Gijsenij, Theo Gevers, Joost van de Weijer
% "Improving Color Constancy by Photometric Edge Weighting"
% IEEE Trans. on Pattern Analysis and Machine Intellignece, vol. 34(5):918-929, 2012.
%
% Source-code courtesy of Joost van de Weijer
%
function [white_R ,white_G ,white_B, output_im] = weightedGE( input_im, kappa, mink_norm, sigma, mask_cal )

if( nargin < 2 ), kappa = 1; end
if( nargin < 3 ), mink_norm = 1; end
if( nargin < 4 ), sigma = 1; end
if( nargin < 5 ), mask_cal = zeros( size( input_im, 1 ), size( input_im, 2 ) ); end 

iter = 10;     % number of iterations

tmp_ill = [1/sqrt(3) 1/sqrt(3) 1/sqrt(3)];   % start iteration with white illuminate estimate
final_ill = tmp_ill;

input_im = double( input_im );
tmp_image = input_im;
flag = 1;
while( iter && flag )     % iteratively improve illuminant estimate
    iter = iter - 1;
    tmp_image(:, :, 1) = tmp_image(:, :, 1) ./ ( sqrt(3)*( tmp_ill(1) ) );
    tmp_image(:, :, 2) = tmp_image(:, :, 2) ./ ( sqrt(3)*( tmp_ill(2) ) );
    tmp_image(:, :, 3) = tmp_image(:, :, 3) ./ ( sqrt(3)*( tmp_ill(3) ) );
    
    [sp_var, Rw, Gw, Bw] = compute_spvar( tmp_image, sigma );
    
    mask_zeros = max( Rw, max( Gw, Bw ) ) < eps; % exclude zero gradients
    mask_pixels = ( dilation33( double( max( tmp_image, [], 3) == 255 ) ) ); % exclude saturated pixels
    mask = logical( set_border( double( ( mask_cal | mask_pixels | mask_zeros ) == 0 ), sigma+1, 0 ) );
    
    grad_im = sqrt( Rw.^2 + Gw.^2 + Bw.^2 );
    
    weight_map = ( sp_var./( grad_im ) ).^kappa;
    weight_map( weight_map > 1 ) = 1;
    
    data_Rx = power( Rw.*( weight_map ), mink_norm );
    data_Gx = power( Gw.*( weight_map ), mink_norm );
    data_Bx = power( Bw.*( weight_map ), mink_norm );
    
    tmp_ill(1) = power( sum( data_Rx( mask(:) ) ), 1/mink_norm );
    tmp_ill(2) = power( sum( data_Gx( mask(:) ) ), 1/mink_norm );
    tmp_ill(3) = power( sum( data_Bx( mask(:) ) ), 1/mink_norm );
    
    tmp_ill = tmp_ill ./ norm( tmp_ill );
    final_ill = final_ill.*tmp_ill;
    final_ill = final_ill ./ norm( final_ill );
    if ( ( acos( tmp_ill*( 1/sqrt(3)*[1 1 1]' ) )/pi*180 ) < 0.05 )  %stop iteration if chance smaller 0.05 degree (angular error)
      flag = 0;
    end
end
white_R = final_ill(1);
white_G = final_ill(2);
white_B = final_ill(3);
if ( nargout > 1 )
  output_im(:, :, 1) = input_im(:, :, 1) ./ ( sqrt(3)*( final_ill(1) ) );
  output_im(:, :, 2) = input_im(:, :, 2) ./ ( sqrt(3)*( final_ill(2) ) );
  output_im(:, :, 3) = input_im(:, :, 3) ./ ( sqrt(3)*( final_ill(3) ) );
end
