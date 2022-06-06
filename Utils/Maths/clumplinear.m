function [cnum,cmin,cstep,csz,clumpindex,clumpcounts] = clumplinear( v, bigness )
%[cnum,cmin,cstep,csz,clumpindex] = clumplinear( v, bigness )
%   v is a vector which is expected to consist of a large number of values
%   that fall into clumps clustered around a smaller number of values.
%   These clump values are expected to be in arithmetic progression.
%   This routine finds the best-fit description of this form.
%   Results:
%       cnum    The number of clumps
%       cmin    The central value of the zeroth clump.
%       cstep   The distance between central values of consecutive clumps.
%       csz     The maximum difference of any clump member from its central
%               value.
%       clumpindex  A row vector the same length as v, mapping each index
%                   of v to the index of the clump it belongs to.
%       clumpcounts  A row vector of the number of elements in each clump.
%
%   Thus v(i) is approximated by cmin + cstep*clumpindex(i), and the error
%   is bounded by csz.
%
%   v can also be a matrix of any size and number of dimensions.
%   clumpindex will have the same size and shape as v.
%
%   See also: clumpsize, clumpseparation, clumpsepsize.

    if nargin < 2
        bigness = 1;
    end
    
    [vs,vperm] = sort(v(:));    % vs is a column vector.
    vdiff1 = diffs(vs);
    midDiff = (max(vdiff1) + min(vdiff1))/2;
    bigdiffs = find(vdiff1(:) > midDiff*bigness)';    % bigdiffs is a row vector.
    if isempty(bigdiffs)
        bigdiffs = 1:length(vdiff1);
    end
    begins = [ 1, (bigdiffs+1) ];
    ends = [ bigdiffs, length(vs) ];
    ranges = vs(ends) - vs(begins);
    cnum = length(ranges);
    
    cmiddles = (vs(begins) + vs(ends))/2;    % cmiddles is a column vector.
    A = cnum*(cnum+1)/2;
    B = cnum*(cnum+1)*(cnum*2+1)/6;
    C = cnum;
    E = sum(cmiddles(:)'.*(1:cnum));
    F = sum(cmiddles);
    det = A*A-B*C;
    a = (A*E - B*F)/det;
    b = (-C*E + A*F)/det;
    cstep = b;
    cmin = a;
    clumpindex = zeros(size(v));    % clumpindex has the same shape as v.
    csz = 0;
    for i=1:length(ranges)
        clumpindex( begins(i):ends(i) ) = i;
        clumpcentre = a + b*i;
        beginerr = vs(begins(i)) - clumpcentre;
        enderr = vs(ends(i)) - clumpcentre;
        csz = max( [ csz, abs(beginerr), abs(enderr) ] );
    end
    clumpindex(vperm) = clumpindex;
    clumpcounts = ends-begins+1;
    
    % Check: every element of v should be within csz of its clump's central
    % value, and at least one value precisely csz away.
  % errs = abs( v - (a + b*clumpindex) ) - csz
  % minerr = min(errs(:))
  % maxerr = max(errs(:)) % Should be exactly zero.
end
