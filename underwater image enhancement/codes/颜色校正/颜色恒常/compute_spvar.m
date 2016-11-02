function [sp_var, Rw, Gw, Bw] = compute_spvar( im, sigma )
% Compute only the specular variant. 
% The weighting scheme returned by this function is the same
% as returned by compute_qi.m but much faster. This function 
% only calculates the specular variant (giving the best results), 
% while compute_qi.m also calculates the other weighting schemes
% used in [Gijsenij et al., PAMI 2012].
%


%split color channels
R = double( im(:,:,1) );
G = double( im(:,:,2) );
B = double( im(:,:,3) );

% computation of spatial derivatives
Rx = gDer( R, sigma, 1, 0 );
Ry = gDer( R, sigma, 0, 1 );
Rw = sqrt( Rx.^2 + Ry.^2 );
 
Gx = gDer( G, sigma, 1, 0 );
Gy = gDer( G, sigma, 0, 1 );
Gw = sqrt( Gx.^2 + Gy.^2 );

Bx = gDer( B, sigma, 1, 0 );
By = gDer( B, sigma, 0, 1 );
Bw = sqrt( Bx.^2 + By.^2 );

% Opponent_der
O3_x = ( Rx + Gx + Bx ) / sqrt(3);
O3_y = ( Ry + Gy + By ) / sqrt(3);

sp_var = sqrt( O3_x.^2 + O3_y.^2 );
