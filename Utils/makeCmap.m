function cmap = makeCmap( colors, nsteps, frac )
%cmap = makeCmap( colors, nsteps, frac )
%   Create a list of colours by interpolating in the given set of colours.
%   The number of intervals in the list (one less than the number of rows)
%   is nsteps.  The output colours will occupy a fraction frac of the whole
%   scale.
%
%   The default number of steps is 50.  The default fraction is 1.

    if (nargin < 2) || isempty(nsteps)
        nsteps = 50;
    end
    if nsteps <= 0
        cmap = zeros(0,3);
        return;
    end
    if (nargin < 3) || isempty(frac)
        frac = 1;
    end
    cmap = zeros( nsteps+1, 3 );
    ncsteps = size(colors,1)-1;
    a = (0:nsteps)*frac;
    b = a*(ncsteps/nsteps);
    c = floor(b);
    d = b-c;
    e = 1-d;
    if c(end)+1 == size(colors,1)
        colors(end+1,:) = colors(end,:);
    end
    for i=1:nsteps+1
        ci = c(i);
        cmap(i,:) = colors(ci+1,:)*e(i) + colors(ci+2,:)*d(i);
    end
end
