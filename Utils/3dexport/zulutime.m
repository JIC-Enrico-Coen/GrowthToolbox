function z = zulutime( t )
    if nargin < 1
        t = now();
    end
    datecpts = fix(datevec(t));
    z = sprintf('%04d-%02d-%02dT%02d:%02d:%02d', datecpts );
end
