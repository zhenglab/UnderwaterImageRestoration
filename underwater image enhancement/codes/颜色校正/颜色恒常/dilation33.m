function out = dilation33( in, it )

if ( nargin<2 )
    it = 1;
end

hh = size( in, 1 );
ll = size( in, 2 );
out = zeros( hh, ll, 3 );

while( it > 0 )
    it = it - 1;
    out(:,:,1) = [in(2:hh, :); in(hh, :)];
    out(:,:,2) = in;
    out(:,:,3) = [in(1, :); in(1:hh-1, :)];
    out2 = max( out, [], 3 );
    out(:,:,1) = [out2(:, 2:ll), out2(:, ll)];
    out(:,:,2) = out2;
    out(:,:,3) = [out2(:, 1), out2(:, 1:ll-1)];
    out = max( out, [], 3 );
    in = out;
end
