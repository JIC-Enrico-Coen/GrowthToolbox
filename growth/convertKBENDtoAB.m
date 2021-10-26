function m = convertKBENDtoAB( m )
% m = convertKBENDtoAB( m )
%   Convert K+BEND morphogens to AB morphogens.
%
%   The K/BEND system is obsolete and no longer supported.  All new meshes
%   are created with A/B morphogens, and all old meshes using K/BEND are
%   automatically converted to A/B by this function, invoked from
%   upgrademesh().
%
%   The formulas relating the two types are implemented in kbend_from_ab
%   and ab_from_kbend.
%
%   See also: kbend_from_ab, ab_from_kbend.

    if m.versioninfo.mgenversion ~= 0
        return;
    end;

    global gLaminarMorphogenNames
    gOLD_MorphogenNames = upper( { ...
        'kpar', 'kperp', 'POLARISER', ...
        'bpar', 'bperp', 'NOTUSED', ...
        'ARREST', 'STRAINRET', 'thickness' } );

    xx = [ gOLD_MorphogenNames; num2cell(1:length(gOLD_MorphogenNames)) ];

    
    kpar = m.morphogens(:,1);
    kper = m.morphogens(:,2);
    pol = m.morphogens(:,3);
    bpar = m.morphogens(:,4);
    bper = m.morphogens(:,5);
    % nu = m.morphogens(:,6);  % This morphogen is reserved, but not used.
    arrest = m.morphogens(:,7);
    strainret = m.morphogens(:,8);
    thickness = m.morphogens(:,9);

    [kapar,kbpar] = ab_from_kbend( kpar, bpar );
    [kaper,kbper] = ab_from_kbend( kper, bper );
    
    ordinaryMgenIndexes = (length(gOLD_MorphogenNames)+1):length(m.mgenIndexToName);
    m.morphogens = [ [kapar, kbpar, kaper, kbper, thickness, pol, strainret, arrest], m.morphogens(:,ordinaryMgenIndexes) ];
    m.mgenIndexToName = [ gLaminarMorphogenNames m.mgenIndexToName(ordinaryMgenIndexes) ];
    n = length(m.mgenIndexToName);
    mgenNameIndexList = [ m.mgenIndexToName; num2cell( 1:n ) ];
    m.mgenNameToIndex = struct( mgenNameIndexList{:} );
    m.versioninfo.mgenversion = 1;
end
