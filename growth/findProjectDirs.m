function dirstruct = findProjectDirs( dname, depth, readonly )
%dirstruct = findProjectDirs( dname )
%   If dname is not a project directory and contains no project
%   directories (including the case where dname does not exist), return an
%   empty array.
%   Otherwise, return a struct whose elements are:
%       isprojectdir: boolean, true if the node is a project directory.
%           When this is true, there should be no children.
%       name: the full pathname of this directory.
%       children: a struct array describing the children.

    if nargin < 2
        depth = 0;
        dname = fullpath(dname);
    end
    dirstruct = [];

    if ~exist( dname, 'dir' )
        % This is not a directory.
        return;
    end

    if isGFtboxProjectDir( dname )
      % fprintf( 1, '%s %s PROJECT\n', repmat( '  ', 1, depth ), dname );
        dirstruct = struct( 'isprojectdir', true, 'name', dname, 'children', [] );
    else
        % It's not a project directory.  Look for project directories
        % inside it.
        contents = dir( dname );
        for i=1:length(contents)
            ci = contents(i);
            n = ci.name;
            if n(1) ~= '.'
                if ci.isdir
                    substruct = findProjectDirs( fullfile( dname, n ), depth+1, readonly );
                    if ~isempty( substruct )
                      % fprintf( 1, '%s %s\n', char(ones(1,depth*2)*' '), n );
                        if isempty( dirstruct )
                            dirstruct = struct( 'isprojectdir', false, 'name', dname, 'children', substruct );
                        else
                            dirstruct.children(end+1) = substruct;
                        end
                    end
                end
            end
        end
        if isempty( dirstruct ) && (depth==0)
            dirstruct = struct( 'isprojectdir', false, 'name', dname, 'children', [] );
        end
    end
end
