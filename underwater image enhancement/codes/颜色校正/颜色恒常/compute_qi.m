function [sp_inv, sp_var, ss_inv, ss_var, spss_inv, spss_var] = compute_qi( im, sigma )
% Compute quasi-invariants and variants.
% the other weighting schemes in the [Gijsenij et al., PAMI 2012] are based on 
% these measurements.
% 
% sp - specular
% ss - shadow-shading
% spss - specular & shadow-shading
%

alfa = 1;
beta = 1;
gamma = 1;

%split color channels
R = double( im(:,:,1) );
G = double( im(:,:,2) );
B = double( im(:,:,3) );

% computation of spatial derivatives
Rx = gDer( R, sigma, 1, 0 );
Ry = gDer( R, sigma, 0, 1 );
R  = gDer( R, sigma, 0, 0 );

Gx = gDer( G, sigma, 1, 0 );
Gy = gDer( G, sigma, 0, 1 );
G  = gDer( G, sigma, 0, 0 );

Bx = gDer( B, sigma, 1, 0 );
By = gDer( B, sigma, 0, 1 );
B  = gDer( B, sigma, 0, 0 );

% computation of derivatives in opponent color space
O1_x = ( beta.*Rx - alfa.*Gx ) ./ sqrt( alfa*alfa + beta*beta );
O1_y = ( beta.*Ry - alfa.*Gy ) ./ sqrt( alfa*alfa + beta*beta );
O2_x = ( alfa.*gamma.*Rx + beta.*gamma.*Gx - ( alfa^2 + beta^2 ).*Bx ) ./ ( sqrt( alfa*alfa + beta*beta )*sqrt( alfa*alfa + beta*beta + gamma*gamma ) );
O2_y = ( alfa.*gamma.*Ry + beta.*gamma.*Gy - ( alfa^2 + beta^2 ).*By ) ./ ( sqrt( alfa*alfa + beta*beta )*sqrt( alfa*alfa + beta*beta + gamma*gamma ) );
O3_x = ( alfa.*Rx + beta.*Gx + gamma.*Bx ) / sqrt( alfa*alfa + beta*beta + gamma*gamma );
O3_y = ( alfa.*Ry + beta.*Gy + gamma.*By ) / sqrt( alfa*alfa + beta*beta + gamma*gamma );

%% Spherical_der
intensityL2 = sqrt( R.*R + G.*G + B.*B + eps );
I2 = sqrt( R.*R + G.*G + eps );

theta_x = ( R.*Gx - G.*Rx ) . /I2;
phi_x   = ( G.*( B.*Gx - G.*Bx ) + R.*( B.*Rx - R.*Bx)) ./ ( intensityL2.*I2 );
r_x     = ( R.*Rx + G.*Gx + B.*Bx ) ./ intensityL2;

theta_y = ( R.*Gy - G.*Ry ) ./ I2;
phi_y   = ( G.*( B.*Gy - G.*By ) + R.*( B.*Ry - R.*By ) ) ./ ( intensityL2.*I2 );
r_y     = ( R.*Ry + G.*Gy + B.*By ) ./ intensityL2;


%hsi derivatives - hue saturation intensity
saturation = sqrt( 2*( R.*R + G.*G + B.*B - R.*G - R.*B - G.*B + eps ) );
h_x = ( R.*( Bx - Gx ) + G.*( Rx - Bx ) + B.*( Gx - Rx ) ) ./ saturation;
s_x = ( R.*( 2*Rx - Gx - Bx ) + G.*( 2*Gx - Rx - Bx ) + B.*( 2*Bx - Rx - Gx ) ) ./ ( sqrt(3)*saturation );
i_x = 1 / sqrt(3)*( Rx + Gx + Bx );

h_y = ( R.*( By - Gy ) + G.*( Ry - By ) + B.*( Gy - Ry ) )./saturation;
s_y = ( R.*( 2*Ry - Gy - By ) + G.*( 2*Gy - Ry - By ) + B.*( 2*By - Ry - Gy ) )./( sqrt(3)*saturation );
i_y = 1 / sqrt(3)*( Ry + Gy + By );

saturation=saturation/sqrt(3);

%% Quasi-invariants
sp_inv = sqrt( O1_x.^2 + O1_y.^2 + O2_x.^2 + O2_y.^2 );
sp_var = sqrt( O3_x.^2 + O3_y.^2 );
ss_inv = sqrt( theta_x.^2 + theta_y.^2 + phi_x.^2 + phi_y.^2 );
ss_var = sqrt( r_x.^2 + r_y.^2 );
spss_inv = sqrt( h_x.^2 + h_y.^2 );
spss_var = sqrt( i_x.^2 + i_y.^2 + s_x.^2 + s_y.^2 );

