function indexes = findmultiple( tofind, tofindin, sorted )
%indexes = findmultiple( tofind, tofindin )
%   TOFIND and TOFINDIN are lists of numbers.
%   Find the indexes of the first occurrence of each member of TOFIND in
%   TOFINDIN. For members not found, the index returned is zero.
%   INDEXES always has the same shape as TOFIND.
%indexes = findsorted( tofind, tofindin, sorted )
%   If SORTED is true (the default is false) the lists are assumed to both
%   be sorted. If they are, this avoids some work; if they are not,
%   specifying that they are will give wrong answers.
%
%   If TOFIND has only one element, this function has no advantage over
%   find( tofind==tofindin, 1 ).
%
%   The elements of TOFIND do not have to be all different.

    if nargin < 3
        sorted = false;
    end
    
    sz = size(tofind);
    
% For checks:
    tofind1 = tofind;
    tofindin1 = tofindin;
    
    if ~sorted
        [tofind,~,ptofindc] = unique( tofind );
        % Check:
        % tofind(ptofindc) is identical to tofind1.
        [tofindin,ptofindin] = sort( tofindin );
        % Check:
        % tofindin(invperm(ptofindin)) is identical to tofindin1.
    end
    
    if isempty(tofind) || isempty(tofindin)
        indexes = [];
    else
        indexes = zeros( 1, length(tofind) );
        si = 1;
        ti = 1;
        while (si <= length(tofind)) && (ti <= length(tofindin))
            if tofind(si) > tofindin(ti)
                ti = ti+1;
            else
                if tofind(si) == tofindin(ti)
                    indexes(si) = ti;
                end
                si = si+1;
            end
        end
    end
    
    if ~sorted
        indexes1 = indexes;
        ix2 = indexes1( ptofindc );
        indexes(ix2==0) = 0;
        indexes(ix2 ~= 0) = ptofindin( ix2(ix2 ~= 0) );
        % Check:
        % all( tofind1(indexes~=0)==tofindin1(indexes(indexes~=0)) )
    end
    
    indexes = reshape( indexes, sz );
end


