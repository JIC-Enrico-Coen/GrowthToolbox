function y = roundToOdd( x )
% Round x to the nearest odd integer.
% The result will be the same shape as x.

    y = round( (x-1)/2 )*2 + 1;
    
%     [x;y]
end
