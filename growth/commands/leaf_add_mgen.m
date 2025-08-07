function [m,mgenNames,mgenIndexes] = leaf_add_mgen( m, varargin )
%[m,newMgenNames,newMgenIndexes] = leaf_add_mgen( m, mgen_name, ... )
%   Add a new morphogen to m with the given name.  If there is already a
%   morphogen with that name, this command is ignored.  Any number of names
%   can be given at once.
%
%   The morphogen names will be converted to upper case, and these and
%   their indexes are returned. If a given morphogen name is invalid, the
%   corresponding returned name will be empty and the index will be zero.
%
%   Equivalent GUI operation: the "New" button on the "Morphogens" panel.
%   A dialog will appear in which the user chooses a name for the new
%   morphogen.
%
%[m,newMgenNames,newMgenIndexes] = leaf_add_mgen( m, m1 )
%   Add to m all of the morphogens of m1, ignoring duplicates.
%
%   See also:
%       leaf_delete_mgen, leaf_rename_mgen
%
%   Topics: Morphogens.

    if isempty(m), return; end
    if (length(varargin)==1) && isGFtboxMesh(varargin{1})
        givenmgens = varargin{1}.mgenIndexToName;
    else
        givenmgens = varargin;
    end
    numgivenmgens = length(givenmgens);
    mgenNames = cell(1,numgivenmgens);
    mgenIndexes = zeros(1,numgivenmgens);
    numexistingmgens = getNumberOfMorphogens(m);
    newMgenNames = {};
    firstNewMgenIndex = numexistingmgens+1;
    givenmgens = upper(givenmgens);
    for i=1:length(givenmgens)
        mgenname = givenmgens{i};
        if ~ischar( mgenname )
            fprintf( 1, '%s: Morphogen names must be strings.\n', mfilename() );
        else
            try
                % Test that mgenname is a valid field name.
                x.(mgenname) = 0; %#ok<STRNU>
                
                mgenNames{i} = mgenname;
                if isfield( m.mgenNameToIndex, mgenname )
                    mgenIndexes(i) = m.mgenNameToIndex.(mgenname);
                    fprintf( 1, '%s: There is already a morphogen called "%s".\n', ...
                        mfilename(), mgenname );
                else
                    newMgenNames{ 1 + length(newMgenNames) } = mgenname; %#ok<AGROW>
                    mgenIndexes(i) = numexistingmgens + length( newMgenNames );
                end
            catch
                fprintf( 1, '%s: Morphogen name ''%s'' is invalid.\n', mfilename(), mgenname );
            end
        end
    end

    if ~isempty(newMgenNames)
        numMgens = length(m.mgenIndexToName);
        newMgenIndexes = numMgens + (1:length(newMgenNames));
        for ai=1:length(newMgenNames)
            m.mgenIndexToName{numMgens+ai} = newMgenNames{ai};
            m.mgenNameToIndex.(newMgenNames{ai}) = numMgens+ai;
        end
        m = applyMgenDefaults( m, newMgenIndexes );
        m.plotdefaults.morphogen = firstNewMgenIndex;
        m = rewriteInteractionSkeleton( m, '', '', mfilename() );
        saveStaticPart( m );
    end
end
