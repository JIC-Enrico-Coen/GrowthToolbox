function [cs,fs] = tensorsToComponents( ts, preferredframes, maxmin )
% [cs,fs] = tensorsToComponents( ts, preferredframes )
%   Convert a set of growth tensors ts given as an N*6 matrix into an N*3
%   matrix cs of the growth amounts and a 3*3*N matrix of the axis frames.
%   preferredframes is an optional argument.  If not supplied, then the
%   values in cs will be in descending order.  If supplied and maxmin is
%   false or absent, the columns of the matrices in fs will be permuted to
%   lie as close as possible to those of preferredframes, and cs will be
%   permuted likewise.  If preferredframes is supplied and maxmin is true,
%   then the first two elements in each row of cs will be permuted to place
%   the largest first, and the corresponding axes likewise permuted.

    havePreferredFrames = (nargin >= 2) && ~isempty( preferredframes );
    if (~havePreferredFrames) || (nargin < 3)
        maxmin = false;
    end
    numtensors = size( ts, 1 );
    cs = zeros( numtensors, 3 );
    fs = zeros( 3, 3, numtensors );
    for i=1:numtensors
        [c,f] = tensorComponents( ts(i,:) );
        if havePreferredFrames
            perm = alignFrames( preferredframes(:,:,i), f );
            c = c(perm);
            f = f(:,perm);
            if maxmin && (c(1) < c(2))
                c([1 2]) = c([2 1]);
                f(:,[1 2]) = f(:,[2 1]);
            end
        end
        cs(i,:) = c;
        fs(:,:,i) = f;
    end
end
