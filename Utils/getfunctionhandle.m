function h = getfunctionhandle( funcname )
%h = getfunctionhandle( funcname )
%   Get a handle to a function which is not on the current path.

    funcfullname = which( funcname );
    if ~isempty( funcfullname )
        [~,basename,~] = fileparts(funcfullname);
        h = str2func( basename );
    else
        funcfullname = fullpath( funcname );
        [funcdir,basename,~] = fileparts(funcfullname);
        olddir = cd( funcdir );
        h = str2func( basename );
        cd( olddir );
    end
end
