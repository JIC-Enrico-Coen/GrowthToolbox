function pi = fencepostindex( position, firstpost, fencelength, numposts )
%pi = pixelindex( position, firstpost, fencelength, numposts )
%   Given a set of numposts fenceposts, beginning at firstpost and with
%   total extent fencelength, compute which fencepost position is closest to.
    pi = round( (position-firstpost)/fencelength * (numposts-1) + 1 );
end

