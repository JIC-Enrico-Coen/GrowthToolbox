function olddir = trymkdircd( targetdir )
%ok = trymkdircd( targetdir )
%   Create the directory TARGETDIR if it does not exist, then cd to it.
%   On success, olddir will be set to the previous current directory.
%   On failure for any reason, olddir will be set to the empty string.

    if trymkdir( targetdir )
        olddir = trycd( targetdir );
    else
        olddir = '';
    end
end
