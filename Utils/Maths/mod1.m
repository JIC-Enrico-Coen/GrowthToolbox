function a = mod1( num, denom )
%a = mod1( num, denom )
%   Like a = mod( num, denom ), but NUM is mapped to the range 1..denom
%   instead of 0..denom-1. Useful for casting array subsripts into the
%   correct range.
%
%   NUM and DENOM may be any valid arguments to mod().
%
%   See also: mod.

    a = 1 + mod( num-1, denom );
end