function m = leaf_rename_mgen( m, varargin )
% m = leaf_rename_mgen( m, oldMgenName, newMgenName, ... )
%   Rename one or more morphogens.  Any number of old name/new name pairs
%   can be given.  The standard morphogens cannot be renamed, and no
%   morphogen can be renamed to an existing name.
%
%   Equivalent GUI operation: clicking the "Rename" button in the
%   "Morphogens" panel.
%
%   See also:
%       leaf_add_mgen, leaf_delete_mgen
%
%   Topics: Morphogens.

    if isempty(m), return; end

    i = 1;
    numRenames = 0;
    maxrenames = floor(length(varargin)/2);
    oldname = cell(1,maxrenames);
    newname = cell(1,maxrenames);
    varargin = upper(varargin);
    while i < length(varargin)
        if ~ischar( varargin{i} )
            complain( '%s: Morphogen names must be strings.', mfilename() );
        elseif ~isfield( m.mgenNameToIndex, varargin{i} )
            complain( '%s: There is no morphogen called "%s".', ...
                mfilename(), varargin{i} );
        elseif m.mgenNameToIndex.(varargin{1}) <= length(m.roleNameToMgenIndex)
            complain( '%s: Morphogen "%s" is reserved and cannot be renamed.', ...
                mfilename(), varargin{1} );
        elseif ~ischar( varargin{i+1} )
            complain( '%s: Morphogen names must be strings.', mfilename() );
        elseif ~isValidMgenName( varargin{i+1} )
            complain( '%s: "%s" is not a valid morphogen name.', ...
                mfilename(),varargin{i+1} );
        else
            numRenames = numRenames+1;
            oldname{numRenames} = varargin{i};
            newname{numRenames} = varargin{i+1};
        end
        i = i+2;
    end
    if i < length(varargin)
        complain( '%s: Extra argument "%s" ignored.', ...
            mfilename(), varargin{length(arargin)} );
    end
    if numRenames==0
        return;
    end
    
    renameindex = struct();
    for i=1:numRenames
        if isfield( m.mgenNameToIndex, newname{i} )
            complain( '%s: Cannot rename morphogen "%s" to "%s": already exists.', ...
                mfilename(), oldname{i}, newname{i} );
        else
            mgenIndex = m.mgenNameToIndex.(oldname{i});
            m.mgenNameToIndex = rmfield( m.mgenNameToIndex, oldname{i} );
            m.mgenNameToIndex.(newname{i}) = mgenIndex;
            m.mgenIndexToName{mgenIndex} = newname{i};
            fprintf( 1, '%s: Renaming morphogen %s to %s.\n', ...
                mfilename(), oldname{i}, newname{i} );
            renameindex.(oldname{i}) = newname{i};
        end
    end
%     xx = fieldnames(renameindex);
%     for i=1:length(xx)
%         mgenname = xx{i};
%         renameindex.(mgenname) = m.mgenNameToIndex.(renameindex.(mgenname));
%     end

    m.plotdefaults.morphogen = renameStrings( FindMorphogenName( m, m.plotdefaults.morphogen ), renameindex );
    m.plotdefaults.morphogenA = renameStrings( FindMorphogenName( m, m.plotdefaults.morphogenA ), renameindex );
    m.plotdefaults.morphogenB = renameStrings( FindMorphogenName( m, m.plotdefaults.morphogenB ), renameindex );
    m.plotdefaults.defaultmultiplottissue = renameStrings( ...
        FindMorphogenName( m, m.plotdefaults.defaultmultiplottissue ), renameindex );
    m.plotdefaults.defaultmultiplottissueA = renameStrings( ...
        FindMorphogenName( m, m.plotdefaults.defaultmultiplottissueA ), renameindex );
    m.plotdefaults.defaultmultiplottissueB = renameStrings( ...
        FindMorphogenName( m, m.plotdefaults.defaultmultiplottissueB ), renameindex );

    m = rewriteInteractionSkeleton( m, '', '', mfilename() );
    saveStaticPart( m );
end
