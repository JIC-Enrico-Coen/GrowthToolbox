function olddir = tryuncd( olddir )
%olddir = tryuncd( olddir )
%   For changing back to a directory one previously cd'd away from.
%   Errors are ignored.

    if ~isempty(olddir)
        try
            cd(olddir);
        catch e %#ok<NASGU>
        end
        olddir = '';
    end
end
