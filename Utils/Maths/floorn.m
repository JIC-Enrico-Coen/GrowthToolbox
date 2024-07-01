function x = floorn( x, n )
    x = round( x-(10^(-n)/2), n );
end
