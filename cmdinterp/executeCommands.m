function m = executeCommands( m, c, ploteach, h )
%m = executeCommands( m, c, ploteach, h )
%   M is a mesh.  C is a list of commands to execute.
%   C is an array of structures with fields 'cmd' and
%   'args', being respectively the name of a script command and a cell
%   array of its arguments.
%   H, if given, is the handle structure of the GUI.

    if ~exist( 'ploteach', 'var' ), ploteach = false; end
    haveHandles = nargin >= 4;
    for i=1:length(c)
        fprintf( 1, 'Executing %d of %d deferred commands after step %d.\n', ...
            i, length(c), m.globalDynamicProps.currentIter );
        if iscell(c(i).args)
            % fprintf( 1, 'executeCommands: cell args %d, args "%s"\n', ...
            %     length(c(i).args), argToScriptString( c(i).args ) );
            if c(i).requiresMesh
                m = scriptcommand( m, c(i).cmd, c(i).args{:} );
            else
                m = scriptcommand( [], c(i).cmd, c(i).args{:} );
            end
        else
            % fprintf( 1, 'executeCommands: noncell args %d, args "%s"\n', ...
            %     length(c(i).args), argToScriptString( c(i).args ) );
            if c(i).requiresMesh
                m = scriptcommand( m, c(i).cmd, c(i).args );
            else
                m = scriptcommand( [], c(i).cmd, c(i).args );
            end
        end
        if ploteach && ~strcmp( c(i).cmd, 'leaf_plot' )
            m = leaf_plot( m );
        end
    end
  % if haveHandles && ~isempty(c)
  %     updateGUIFromMesh( h, m );
  % end
end
