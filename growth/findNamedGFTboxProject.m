function [fp,pn,m] = findNamedGFTboxProject( projectname )
%[fp,pn,m] = findNamedGFTboxProject( s )
%   Given the name of a project, in the form of a bare name, a relative
%   path, or an absolute path, get a full pathname for the project
%   directory, and the base name of the project. If the third output
%   argument is requested, it will be the initial stage of the project.
%
%   If no such project is found, then pn is returned as empty.  fn will be
%   empty if s was a bare name and nothing to match it was found in the
%   project directories list.  Otherwise, fp will be the full path name
%   corresponding to s.

    fp = [];
    pn = [];
    m = [];
    if any(projectname==filesep)
        fp = fullfile( projectname );
        if isGFtboxProjectDir( fp )
            [~,pn,ext] = fileparts( fp );
            pn = [ pn, ext ];
        end
    else
        % Search project directory list.
        c = readGFtboxConfig();
        pdirs = [ '.', c.projectsdir ];
        pdirs = unique( pdirs, 'stable' );
        fps = fullfile( pdirs, projectname );
        validprojects = isGFtboxProjectDir( fps );
        pdirs = pdirs( validprojects );
        fps( validprojects );
%         fps = {};
%         for i=1:length(pdirs)
%             fp1 = fullfile( pdirs{i}, s );
%             if isGFtboxProjectDir( fp1 )
%                 fps{end+1} = fp1;
%             end
%         end
        if ~isempty(fps)
            pns = cell(1,length(fps));
            for i=1:length(fps)
                [~,pn1,ext] = fileparts( fps{i} );
                pns{i} = [ pn1, ext ];
            end
            if length(fps) == 1
                fp = fps{1};
                pn = pns{1};
            else
                % Multiple candidates. What to do?
                % Return all of them, but only return the mesh (if asked
                % for) for the first.
                fp = fps;
                pn = pns;
            end
            if nargout >= 3
                % Load the mesh
                m = leaf_loadmodel( [], pns{1}, pdirs{1} );
            end
        end
    end
end
