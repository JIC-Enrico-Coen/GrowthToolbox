function m = leaf_setpolfrozen( m, varargin )
%m = leaf_setpolfrozen( m, frozenA, frozenB )
%
%   This causes the polariser gradient to be frozen or unfrozen.
%
%   If FROZENA and FROZENB are both given, they are interpreted as boolean
%   N*1 lists specifying for the A side and the B side respectively,
%   whether the polariser gradient for each finite element should be
%   frozen.  N can be either the number of finite elements or the number of
%   vertices.  In the latter case a per-FE quantity will be calculated by
%   majority voting on the three vertexes of each FE.
%
%   If all the values of FROZENA (or FROZENB) are equal, then that single
%   value can be given.
%
%   If FROZENA or FROZENB is empty, this is interpreted as meaning that no
%   change should be made to the frozenness of the gradient on that side.
%
%   If only FROZENA is given, then this should be an N*2 array whose two
%   columns are FROZENA and FROZENB respectively.  If it is an N*1 array it
%   will be replicated if necesssary to form an N*2 array.
%
%   If the arguments require the mesh to have two-sided polarisation, but
%   it does not, a warning message will be written to the console, and only
%   the value of FROZENA will be used.  If the arguments require the mesh
%   to have one-sided polarisation, but it does not, then the same values
%   will be applied to both sides.
%
%   Note that independently of this procedire, the polariser gradient can
%   also become frozen by the magnitude of the gradient falling below the
%   threshold set by leaf_setproperty( m, 'mingradient', ... ).  If this is
%   not desired, set that threshold to zero.

    if nargin < 2
        return;
    end
    if nargin < 3
        frozen = varargin{1};
    elseif size(varargin{1},2) > 1
        % Ignore remaining arguments.
        frozen = varargin{1};
    else
        % Combine the two arguments into one.
        frozenA = varargin{1};
        frozenB = varargin{2};
        if isempty( frozenA )
            frozenA = m.polsetfrozen(:,1);
        end
        if isempty( frozenB )
            frozenB = m.polsetfrozen(:,end);
        end
        if numel(frozenA)==1
            frozenA = repmat( frozenA, size(frozenB) );
        elseif numel(frozenB)==1
            frozenB = repmat( frozenB, size(frozenA) );
        end
        if all(size(frozenA)==size(frozenB))
            frozen = [ frozenA, frozenB ];
        else
            % Probably should not happen.  Ignore remaining arguments.
            frozen = frozenA;
        end
    end
    
    if isempty( frozen )
        return;
    end

    numfrozensides = size(frozen,2);
    numpolsides = size(m.polsetfrozen,2);


    if (numfrozensides > 1) && ~m.globalProps.twosidedpolarisation
        icomplain( '"frozen" argument is for a mesh with %d-sided polarisation, but the mesh has single-sided polarisation.', ...
            size(frozen,2) )
        frozen = frozen(:,1);
    end
    
    if (numfrozensides==1) && (numpolsides > 1)
        frozen = repmat( frozen, 1, numpolsides );
    end
    
    if size(frozen,1)==1
        frozen = repmat( frozen, size( m.polsetfrozen, 1 ), 1 );
    end
    
    if all(size(frozen)==size(m.polsetfrozen))
        m.polsetfrozen = frozen;
        return;
    end
    
    numvxs = size(m.nodes,1);
    numfes = size(m.tricellvxs,1);
    isPerFE = size(frozen,1) == numfes;
    
    if ~isPerFE
        if size(frozen,1) ~= numvxs
            icomplain( 'The mesh has %d vertices and %d finite elements, but the argument supplied has %d elements.', ...
                numvxs, numfes, numel(frozen) );
            return;
        end
        newfrozen = false(numfes,size(frozen,2));
        for i=1:numfrozensides
            f1 = frozen(:,i);
            newfrozen(:,i) = sum( f1( m.tricellvxs ), 2 ) > 1.5;
        end
        frozen = newfrozen;
    end
    
    m.polsetfrozen = frozen;

function icomplain( varargin )
    if isinteractive(m)
        queryDialog( 1, [ mfilename(), ': bad argument' ], varargin{:} );
    else
        complain( varargin{:} );
    end
end
end

