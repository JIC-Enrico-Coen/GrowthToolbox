function m = leaf_delete_mgen( m, varargin )
%m = leaf_delete_mgen( m, mgen_name, ... )
%   Delete from m the morphogen that has the given name.  If there is no
%   such morphogen, or if the name is one of the reserved morphogen names,
%   this command is ignored.  Any number of names can be given at once.
%
%   Equivalent GUI operation: clicking the "Delete" button in the
%   "Morphogens" panel, which deletes the currently selected morphogen.
%
%   See also:
%       leaf_add_mgen, leaf_rename_mgen
%
%   Topics: Morphogens

    if isempty(m), return; end

    delMgenNames = {};
    varargin = upper(varargin);
    for i=1:length(varargin)
        if ~ischar( varargin{i} )
            fprintf( 1, '%s: Morphogen names must be strings.\n', mfilename() );
        elseif ~isfield( m.mgenNameToIndex, varargin{i} )
            fprintf( 1, '%s: There is no morphogen called "%s".\n', ...
                mfilename(), varargin{i} );
        elseif m.mgenNameToIndex.(varargin{i}) <= length(m.roleNameToMgenIndex)
            fprintf( 1, '%s: Morphogen "%s" is reserved and cannot be deleted.\n', ...
                mfilename(), varargin{i} );
        else
            delMgenNames{ end+1 } = varargin{i};
        end
    end
    
    if ~isempty(delMgenNames)
        m.plotdefaults.morphogen = deleteMgensFromList( m, m.plotdefaults.morphogen, delMgenNames );
        m.plotdefaults.morphogenA = deleteMgensFromList( m, m.plotdefaults.morphogenA, delMgenNames );
        m.plotdefaults.morphogenB = deleteMgensFromList( m, m.plotdefaults.morphogenB, delMgenNames );
        m.plotdefaults.defaultmultiplottissue = deleteMgensFromList( m, ...
            m.plotdefaults.defaultmultiplottissue, delMgenNames );
        m.plotdefaults.defaultmultiplottissueA = deleteMgensFromList( m, ...
            m.plotdefaults.defaultmultiplottissueA, delMgenNames );
        m.plotdefaults.defaultmultiplottissueB = deleteMgensFromList( m, ...
            m.plotdefaults.defaultmultiplottissueB, delMgenNames );

        numMgens = length(m.mgenIndexToName);
        delMgenIndexes = zeros( 1, length(delMgenNames) );
        for i=1:length(delMgenNames)
            delMgenIndexes(i) = m.mgenNameToIndex.(delMgenNames{i});
        end
        retained = true(1,numMgens);
        retained(delMgenIndexes) = false;
        m = deleteMgenValues( m, retained );
        if retained(m.globalProps.displayedGrowth)
            m.globalProps.displayedGrowth = ...
                sum(retained(1:m.globalProps.displayedGrowth));
        else
            m.globalProps.displayedGrowth = ...
                1 + sum(retained(1:m.globalProps.displayedGrowth));
            if m.globalProps.displayedGrowth > (numMgens - length(delMgenNames))
                m.globalProps.displayedGrowth = numMgens - length(delMgenNames);
            end
        end
        m.transportfield = m.transportfield(retained);
        m.mgenIndexToName = m.mgenIndexToName(retained);
        m.mgenNameToIndex = invertDictionary( m.mgenIndexToName );
        
        m = rewriteInteractionSkeleton( m, '', '', mfilename() );
        saveStaticPart( m );
        
        h = getGFtboxHandles( m );
        if (~isempty( h )) && isfield( h, 'mesh' )
%             ud = get( h.drawmulticolor, 'Userdata' );
%             if ~isempty( ud )
%                 ud.morphogens = deleteMgensFromList( m, ud.morphogens, deletedMgenNames );
%                 set( h.drawmulticolor, 'Userdata', ud );
%             end
            h.mesh = m;
            setGUIMgenInfo( h, m );
        end
    end
end

function mgens = deleteMgensFromList( m, mgens, deletedMgenNames )
    if isempty( mgens )
        return;
    end
    mgens = FindMorphogenName( m, mgens );
    xx = struct();
    for i=1:length(mgens)
        mgen = mgens{i};
        xx.(mgen) = 1;
    end
    xx = safermfield( xx, deletedMgenNames{:} );
    mgens = fieldnames(xx);
end
