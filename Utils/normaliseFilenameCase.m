function [fn,fns] = normaliseFilenameCase( fn )
%[fn,fns] = normaliseFilenameCase( fn )
%   Matlab's DIR function, at least on MacOS, ignores case in filenames. So
%   does EXIST. This function will find the version of a filename that
%   exactly matches the actual name.

    candidates = dir( [ fn, '*' ] );
    if isempty( candidates )
        fn = '';
        fns = [];
    else
        names = { candidates.name };
        oknames = true( size(names) );
        for fi=1:length(names)
            oknames(fi) = endsWith( fn,candidates.name,'IgnoreCase',true );
        end
        names = names(oknames);
        if length(names)==1
            fn = names{1};
            fns = {fn};
        else
            names = sort( names );
            fn = names{1};
            fns = namse;
        end
    end 
end
