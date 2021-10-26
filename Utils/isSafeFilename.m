function ok = isSafeFilename( ff )
%ok = isSafeFilename( f )
%   f must be nonempty and contain only letters, numbers, '_', '-', or '.'.
%   It may not begin with a '.' or a '-'.
%
%   This might be liberalised slightly, but f absolutely must not contain
%   '/', white space, square brackets, curly brackets, control characters,
%   non-ASCII, quote marks, '*', '&', and probably a bunch of other things
%   that don't come to mind. Safer to just go with the list of what is
%   specifically permitted.
%
%   If f is a cell array of strings, ok will be a boolean array.

    if ischar(ff)
        ff = {ff};
    end
    ok = false( 1, length(ff) );
    for i=1:length(ff)
        f = ff{i};
        ok(i) = ~isempty(regexpi( f, '^[-A-Z0-9_.]+$' )) && (f(1) ~= '.') && (f(1) ~= '-');
    end
end
